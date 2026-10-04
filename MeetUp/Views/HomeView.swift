import SwiftUI

/// หน้าหลักของแอป (Home Dashboard)
/// - มี 4 ปุ่มลัดสไตล์ Zoom (เริ่มประชุมทันที, เข้าร่วม, นัดหมาย, แชร์หน้าจอ)
/// - แสดงรายการประชุมที่กำลังจะมาถึง พร้อมป้ายสถานะสด
/// - เข้าถึงหน้าโปรไฟล์และการตั้งค่าได้จากแถบด้านบน
struct HomeView: View {
    @Environment(AppRouter.self) private var router
    @Environment(SessionStore.self) private var session

    @State private var viewModel = HomeViewModel()
    @State private var showShareScreenNotice = false

    private var currentUser: User {
        session.currentUser ?? MockData.currentUser
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Header Profile & Actions
                headerSection

                // MARK: - Quick Action Buttons (สไตล์ Zoom)
                quickActionsGrid

                // MARK: - Meeting Section
                meetingsSection
            }
            .padding(.horizontal, Theme.padding)
            .padding(.vertical, 16)
        }
        .background(Theme.background)
        .refreshable {
            await viewModel.loadMeetings()
        }
        .task {
            await viewModel.loadMeetings()
        }
        .alert("แชร์หน้าจอ", isPresented: $showShareScreenNotice) {
            Button("ตกลง", role: .cancel) {}
        } message: {
            Text("หากต้องการแชร์หน้าจอ กรุณาเข้าร่วมห้องประชุมก่อน จากนั้นกดปุ่มแชร์หน้าจอในแถบควบคุมด้านล่าง")
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Subviews

    private var headerSection: some View {
        HStack(spacing: 12) {
            Button {
                router.push(.profile)
            } label: {
                HStack(spacing: 12) {
                    AvatarView(name: currentUser.name, size: 48, showsOnlineBadge: true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("สวัสดี, \(currentUser.firstName) 👋")
                            .font(.headline)
                            .foregroundStyle(Theme.primary)
                        Text(currentUser.jobTitle.isEmpty ? "สมาชิก MeetUp" : currentUser.jobTitle)
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
            }

            Spacer()

            Button {
                router.push(.settings)
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundStyle(Theme.textSecondary)
                    .frame(width: 42, height: 42)
                    .background(Theme.surface, in: Circle())
            }
        }
    }

    private var quickActionsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            // ปุ่มเริ่มประชุมทันที (New Meeting)
            QuickActionButton(
                title: "เริ่มประชุมทันที",
                subtitle: "สร้างห้องใหม่",
                systemImage: "video.fill",
                color: Theme.highlight
            ) {
                Task {
                    if let meeting = await viewModel.startInstantMeeting(currentUser: currentUser) {
                        router.push(.meetingRoom(meeting))
                    }
                }
            }

            // ปุ่มเข้าร่วม (Join)
            QuickActionButton(
                title: "เข้าร่วม",
                subtitle: "ใส่รหัสห้อง",
                systemImage: "plus.square.fill",
                color: Theme.accent
            ) {
                router.push(.joinMeeting)
            }

            // ปุ่มนัดหมาย (Schedule)
            QuickActionButton(
                title: "นัดหมาย",
                subtitle: "วางแผนล่วงหน้า",
                systemImage: "calendar.badge.clock",
                color: Theme.primary
            ) {
                router.push(.scheduleMeeting)
            }

            // ปุ่มแชร์หน้าจอ (Share Screen)
            QuickActionButton(
                title: "แชร์หน้าจอ",
                subtitle: "ส่งภาพหน้าจอ",
                systemImage: "arrow.up.right.video.fill",
                color: Color(hex: 0x457B9D)
            ) {
                showShareScreenNotice = true
            }
        }
    }

    private var meetingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // หัวข้อและตัวกรอง
            HStack {
                Text("การประชุมของฉัน")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Theme.primary)

                Spacer()

                Picker("ตัวกรอง", selection: $viewModel.selectedFilter) {
                    ForEach(HomeViewModel.MeetingFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.menu)
                .tint(Theme.accent)
            }

            if viewModel.isLoading && viewModel.meetings.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else if viewModel.filteredMeetings.isEmpty {
                emptyMeetingState
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filteredMeetings) { meeting in
                        Button {
                            router.push(.meetingDetail(meeting))
                        } label: {
                            MeetingCard(meeting: meeting)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var emptyMeetingState: some View {
        VStack(spacing: 10) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 40))
                .foregroundStyle(Theme.textSecondary.opacity(0.6))
                .padding(.top, 20)

            Text("ไม่มีการประชุมในหมวดนี้")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            Text("คุณสามารถเริ่มประชุมด่วนหรือกดนัดหมายล่วงหน้าได้เลย")
                .font(.footnote)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .cardStyle()
    }
}

/// คอมโพเนนต์ปุ่มลัด 4 ปุ่มสไตล์ Zoom
struct QuickActionButton: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color)
                        .frame(width: 48, height: 48)

                    Image(systemName: systemImage)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .shadow(color: Theme.primary.opacity(0.05), radius: 6, y: 2)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    HomeView()
        .previewEnvironment(loggedIn: true)
}
