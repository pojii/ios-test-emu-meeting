import SwiftUI

/// หน้ารายชื่อผู้เข้าร่วมประชุม (Participants List)
/// - แสดงรายชื่อทุกคนที่อยู่ในสาย
/// - แสดงสถานะไมโครโฟน, กล้อง, และการยกมือของแต่ละคน
/// - หากเป็น Host จะมีปุ่ม "ปิดไมค์ทุกคน (Mute All)"
struct ParticipantsView: View {
    @Environment(\.dismiss) private var dismiss

    let meeting: Meeting
    let currentUser: User

    @State private var participants: [Participant]
    @State private var showMuteAllAlert = false

    init(meeting: Meeting, currentUser: User) {
        self.meeting = meeting
        self.currentUser = currentUser
        _participants = State(initialValue: MockData.participants(for: meeting))
    }

    private var isHost: Bool {
        meeting.host.id == currentUser.id
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // รายชื่อผู้เข้าร่วม
                List {
                    Section {
                        ForEach($participants) { $participant in
                            participantRow(participant)
                        }
                    } header: {
                        Text("ในสายตอนนี้ (\(participants.count))")
                    }
                }
                .listStyle(.insetGrouped)

                // แถบควบคุมสำหรับ Host
                if isHost {
                    hostControlsBar
                }
            }
            .background(Theme.background)
            .navigationTitle("ผู้เข้าร่วม (\(participants.count))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("ปิด") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.accent)
                }
            }
            .alert("ปิดไมค์ทุกคน", isPresented: $showMuteAllAlert) {
                Button("ปิดไมค์ทุกคน", role: .destructive) {
                    muteAllParticipants()
                }
                Button("ยกเลิก", role: .cancel) {}
            } message: {
                Text("ผู้เข้าร่วมทุกคนจะถูกปิดไมโครโฟน แต่ยังสามารถเปิดไมค์ได้เองเมื่อต้องการพูด")
            }
        }
    }

    // MARK: - Subviews

    private func participantRow(_ participant: Participant) -> some View {
        HStack(spacing: 12) {
            AvatarView(name: participant.user.name, size: 40)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(participant.user.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)

                    if participant.user.id == currentUser.id {
                        Text("(คุณ)")
                            .font(.caption2)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

                if participant.isHost {
                    Text("Host")
                        .font(.caption2.bold())
                        .foregroundStyle(Theme.accent)
                }
            }

            Spacer()

            // สถานะยกมือ
            if participant.isHandRaised {
                Text("✋")
                    .font(.body)
                    .padding(4)
            }

            // สถานะกล้อง
            Image(systemName: participant.isVideoOn ? "video.fill" : "video.slash.fill")
                .foregroundStyle(participant.isVideoOn ? Theme.textSecondary : Theme.danger)
                .frame(width: 24)

            // สถานะไมค์
            Image(systemName: participant.isMuted ? "mic.slash.fill" : "mic.fill")
                .foregroundStyle(participant.isMuted ? Theme.danger : Theme.accent)
                .frame(width: 24)
        }
        .padding(.vertical, 4)
    }

    private var hostControlsBar: some View {
        HStack {
            Button {
                showMuteAllAlert = true
            } label: {
                HStack {
                    Image(systemName: "mic.slash.fill")
                    Text("ปิดไมค์ทุกคน (Mute All)")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.danger)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border))
            }
        }
        .padding(16)
        .background(Theme.surface)
    }

    private func muteAllParticipants() {
        for index in participants.indices {
            if participants[index].user.id != currentUser.id {
                participants[index].isMuted = true
            }
        }
    }
}

#Preview {
    ParticipantsView(
        meeting: MockData.meetings[0],
        currentUser: MockData.currentUser
    )
}
