import SwiftUI

/// หน้าห้องประชุม Video Call (Zoom-like Call Screen)
/// - พื้นหลังสีเข้ม (Theme.callBackground)
/// - แถบด้านบน: ตัวจับเวลา, สลับลำโพง, รหัสห้อง, และปุ่มออกจากห้อง
/// - Grid วิดีโอของผู้เข้าร่วม แสดงภาพจำลองหรือรูป Avatar พร้อมกรอบเขียวคนพูด
/// - แถบเครื่องมือควบคุมด้านล่าง (Call Controls): ไมค์, กล้อง, แชร์จอ, ยกมือ, แชท, รายชื่อ
struct MeetingRoomView: View {
    @Environment(AppRouter.self) private var router

    let meeting: Meeting
    let currentUser: User

    @State private var viewModel: MeetingRoomViewModel

    init(meeting: Meeting, currentUser: User) {
        self.meeting = meeting
        self.currentUser = currentUser
        _viewModel = State(initialValue: MeetingRoomViewModel(meeting: meeting, currentUser: currentUser))
    }

    var body: some View {
        ZStack {
            Theme.callBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Top Bar
                topBar

                // MARK: - Video Grid
                videoArea
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // MARK: - Bottom Controls Bar
                bottomControlsBar
            }
        }
        .navigationBarBackButtonHidden(true)
        .confirmationDialog(
            "ออกจากห้องประชุม",
            isPresented: $viewModel.showLeaveConfirmation,
            titleVisibility: .visible
        ) {
            Button("ออกจากห้องประชุม", role: .destructive) {
                leaveMeeting()
            }
            if meeting.host.id == currentUser.id {
                Button("สิ้นสุดการประชุมสำหรับทุกคน", role: .destructive) {
                    leaveMeeting()
                }
            }
            Button("ยกเลิก", role: .cancel) {}
        } message: {
            Text("คุณต้องการออกจากห้องประชุมนี้หรือไม่?")
        }
        .sheet(isPresented: $viewModel.showChatSheet) {
            ChatView(meeting: meeting, currentUser: currentUser)
        }
        .sheet(isPresented: $viewModel.showParticipantsSheet) {
            ParticipantsView(meeting: meeting, currentUser: currentUser)
        }
    }

    // MARK: - Subviews

    private var topBar: some View {
        HStack {
            // ลำโพง
            Button {
                viewModel.isSpeakerOn.toggle()
            } label: {
                Image(systemName: viewModel.isSpeakerOn ? "speaker.wave.3.fill" : "speaker.slash.fill")
                    .font(.body)
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(Color.white.opacity(0.12), in: Circle())
            }

            Spacer()

            // ข้อมูลการประชุม & ตัวจับเวลา
            VStack(spacing: 2) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Theme.accent)
                        .frame(width: 8, height: 8)
                    Text(meeting.title)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                Text("\(meeting.meetingCode) · \(viewModel.formattedDuration)")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            // ปุ่มออกจากห้อง
            Button {
                viewModel.showLeaveConfirmation = true
            } label: {
                Text("ออก")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Theme.danger, in: Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private var videoArea: some View {
        GeometryReader { geometry in
            let count = viewModel.participants.count

            if viewModel.isScreenSharing {
                // หน้าจอจำลองตอนแชร์หน้าจอ
                screenSharingBanner
            } else if count <= 2 {
                // 1-2 คน จัดเป็นแนวตั้งแบ่งครึ่ง
                VStack(spacing: 12) {
                    ForEach(viewModel.participants) { participant in
                        VideoTileView(
                            participant: participant,
                            isSelf: participant.user.id == currentUser.id,
                            isSpeaking: viewModel.activeSpeakerId == participant.id
                        )
                    }
                }
                .padding(.horizontal, 16)
            } else {
                // 3 คนขึ้นไป จัดเป็น Grid 2 คอลัมน์
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                        ForEach(viewModel.participants) { participant in
                            VideoTileView(
                                participant: participant,
                                isSelf: participant.user.id == currentUser.id,
                                isSpeaking: viewModel.activeSpeakerId == participant.id
                            )
                        }
                    }
                    .padding(12)
                }
            }
        }
    }

    private var screenSharingBanner: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.on.rectangle")
                .font(.system(size: 64))
                .foregroundStyle(Theme.accent)

            Text("คุณกำลังแชร์หน้าจอ")
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text("ผู้เข้าร่วมทุกคนสามารถมองเห็นหน้าจอของคุณได้ในขณะนี้")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            Button("หยุดแชร์หน้าจอ") {
                viewModel.toggleScreenShare()
            }
            .font(.subheadline.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Theme.danger, in: Capsule())
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.tileBackground, in: RoundedRectangle(cornerRadius: 16))
        .padding(16)
    }

    private var bottomControlsBar: some View {
        HStack(spacing: 4) {
            // ไมค์
            CallControlButton(
                systemImage: viewModel.isMuted ? "mic.slash.fill" : "mic.fill",
                title: viewModel.isMuted ? "เปิดไมค์" : "ปิดไมค์",
                fill: viewModel.isMuted ? Theme.danger : nil
            ) {
                viewModel.toggleMute()
            }

            // กล้อง
            CallControlButton(
                systemImage: viewModel.isVideoOn ? "video.fill" : "video.slash.fill",
                title: viewModel.isVideoOn ? "ปิดกล้อง" : "เปิดกล้อง",
                fill: !viewModel.isVideoOn ? Theme.danger : nil
            ) {
                viewModel.toggleVideo()
            }

            // แชร์จอ
            CallControlButton(
                systemImage: "rectangle.on.rectangle",
                title: "แชร์จอ",
                isActive: viewModel.isScreenSharing
            ) {
                viewModel.toggleScreenShare()
            }

            // ผู้เข้าร่วม
            CallControlButton(
                systemImage: "person.2.fill",
                title: "ผู้เข้าร่วม",
                badge: viewModel.participants.count
            ) {
                viewModel.showParticipantsSheet = true
            }

            // แชท
            CallControlButton(
                systemImage: "bubble.left.and.bubble.right.fill",
                title: "แชท",
                badge: viewModel.unreadMessagesCount
            ) {
                viewModel.showChatSheet = true
            }

            // ยกมือ
            CallControlButton(
                systemImage: "hand.raised.fill",
                title: viewModel.isHandRaised ? "เอามือลง" : "ยกมือ",
                isActive: viewModel.isHandRaised
            ) {
                viewModel.toggleHandRaise()
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 14)
        .background(Color.black.opacity(0.4))
    }

    private func leaveMeeting() {
        viewModel.stopSession()
        router.pop()
    }
}

#Preview {
    MeetingRoomView(
        meeting: MockData.meetings[0],
        currentUser: MockData.currentUser
    )
    .previewEnvironment(loggedIn: true)
}
