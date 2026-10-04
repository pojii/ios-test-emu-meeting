import SwiftUI

/// หน้าโปรไฟล์ผู้ใช้งาน (User Profile)
/// - แสดงรูป Avatar, ชื่อ, อีเมล, และตำแหน่ง
/// - รหัสห้องประชุมส่วนตัว (Personal Meeting ID: PMI) พร้อมปุ่มคัดลอก
/// - ปุ่มออกจากระบบ (Sign Out)
struct ProfileView: View {
    @Environment(SessionStore.self) private var session
    @Environment(AppRouter.self) private var router

    @State private var copiedPMI = false
    @State private var showSignOutAlert = false

    private var currentUser: User {
        session.currentUser ?? MockData.currentUser
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // ข้อมูลส่วนตัว
                VStack(spacing: 12) {
                    AvatarView(name: currentUser.name, size: 88, showsOnlineBadge: true)
                        .padding(.top, 8)

                    Text(currentUser.name)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Theme.primary)

                    Text(currentUser.email)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)

                    if !currentUser.jobTitle.isEmpty {
                        Text(currentUser.jobTitle)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.accent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Theme.accent.opacity(0.12), in: Capsule())
                    }
                }
                .frame(maxWidth: .infinity)
                .cardStyle()

                // ข้อมูล Personal Meeting ID (PMI)
                VStack(alignment: .leading, spacing: 12) {
                    Text("ห้องประชุมส่วนตัว (PMI)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Personal Meeting ID")
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                            Text(MockData.personalMeetingID)
                                .font(.headline.monospacedDigit())
                                .foregroundStyle(Theme.primary)
                        }

                        Spacer()

                        Button {
                            UIPasteboard.general.string = MockData.personalMeetingID
                            copiedPMI = true
                            Task {
                                try? await Task.sleep(for: .seconds(2))
                                copiedPMI = false
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: copiedPMI ? "checkmark" : "doc.on.doc")
                                Text(copiedPMI ? "คัดลอกแล้ว" : "คัดลอก")
                            }
                            .font(.caption.bold())
                            .foregroundStyle(copiedPMI ? Theme.accent : Theme.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Theme.background, in: Capsule())
                        }
                    }
                }
                .cardStyle()

                // สถิติการใช้งานจำลอง
                HStack(spacing: 12) {
                    StatCard(title: "การประชุมทั้งหมด", value: "28", icon: "video.fill")
                    StatCard(title: "เวลาในสาย (ชม.)", value: "42", icon: "clock.fill")
                }

                // ปุ่มออกจากระบบ
                PrimaryButton(
                    title: "ออกจากระบบ",
                    systemImage: "rectangle.portrait.and.arrow.right",
                    style: .danger
                ) {
                    showSignOutAlert = true
                }
                .padding(.top, 12)
            }
            .padding(.horizontal, Theme.padding)
            .padding(.vertical, 16)
        }
        .background(Theme.background)
        .navigationTitle("โปรไฟล์")
        .navigationBarTitleDisplayMode(.inline)
        .alert("ออกจากระบบ", isPresented: $showSignOutAlert) {
            Button("ออกจากระบบ", role: .destructive) {
                session.signOut()
            }
            Button("ยกเลิก", role: .cancel) {}
        } message: {
            Text("คุณต้องการออกจากระบบ MeetUp หรือไม่?")
        }
    }
}

/// การ์ดสถิติการใช้งาน
struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Theme.accent)
                .font(.title3)

            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.primary)

            Text(title)
                .font(.caption2)
                .foregroundStyle(Theme.textSecondary)
        }
        .cardStyle()
    }
}

#Preview {
    ProfileView()
        .previewEnvironment(loggedIn: true)
}
