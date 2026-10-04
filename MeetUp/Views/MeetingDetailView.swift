import SwiftUI

/// หน้ารายละเอียดการประชุม (Meeting Details)
/// - แสดงข้อมูลทั้งหมดของการประชุม (เวลา, Meeting ID, รหัสผ่าน, วาระ)
/// - ปุ่มเข้าร่วมการประชุมทันที
/// - ปุ่ม ShareLink สำหรับแชร์คำเชิญประชุมให้ผู้อื่น
struct MeetingDetailView: View {
    @Environment(AppRouter.self) private var router

    let meeting: Meeting

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // ข้อมูลหลักของการประชุม
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        MeetingStatusBadge(status: meeting.status)
                        Spacer()
                        Text("\(meeting.durationMinutes) นาที")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Theme.textSecondary)
                    }

                    Text(meeting.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Theme.primary)

                    HStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .foregroundStyle(Theme.accent)
                        Text(meeting.startDate.formatted(date: .long, time: .shortened))
                            .font(.subheadline)
                            .foregroundStyle(Theme.textPrimary)
                    }

                    if !meeting.agenda.isEmpty {
                        Divider()
                        VStack(alignment: .leading, spacing: 4) {
                            Text("วาระการประชุม:")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Theme.textSecondary)
                            Text(meeting.agenda)
                                .font(.subheadline)
                                .foregroundStyle(Theme.textPrimary)
                        }
                    }
                }
                .cardStyle()

                // รหัสการประชุมและรหัสผ่าน
                VStack(spacing: 12) {
                    DetailRow(
                        title: "Meeting ID",
                        value: meeting.meetingCode,
                        icon: "number"
                    )

                    if let passcode = meeting.passcode {
                        Divider()
                        DetailRow(
                            title: "รหัสผ่านห้อง",
                            value: passcode,
                            icon: "lock.fill"
                        )
                    }

                    Divider()
                    DetailRow(
                        title: "ผู้จัดประชุม (Host)",
                        value: meeting.host.name,
                        icon: "person.crop.circle.badge.checkmark"
                    )
                }
                .cardStyle()

                // รายชื่อผู้เข้าร่วมประชุม
                VStack(alignment: .leading, spacing: 12) {
                    Text("ผู้เข้าร่วม (\(meeting.participants.count) คน)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)

                    ForEach(meeting.participants) { user in
                        HStack(spacing: 12) {
                            AvatarView(name: user.name, size: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Theme.textPrimary)
                                if !user.jobTitle.isEmpty {
                                    Text(user.jobTitle)
                                        .font(.caption2)
                                        .foregroundStyle(Theme.textSecondary)
                                }
                            }
                            Spacer()
                            if user.id == meeting.host.id {
                                Text("Host")
                                    .font(.caption2.bold())
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Theme.accent.opacity(0.15), in: Capsule())
                                    .foregroundStyle(Theme.accent)
                            }
                        }
                    }
                }
                .cardStyle()

                // ปุ่มแอ็กชัน
                VStack(spacing: 12) {
                    PrimaryButton(
                        title: "เข้าร่วมการประชุมตอนนี้",
                        systemImage: "video.fill",
                        style: .accent
                    ) {
                        router.push(.meetingRoom(meeting))
                    }

                    ShareLink(
                        item: meeting.invitationText,
                        subject: Text("คำเชิญเข้าร่วมประชุม: \(meeting.title)"),
                        message: Text(meeting.invitationText)
                    ) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("ส่งต่อคำเชิญประชุม")
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.primary)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                                .stroke(Theme.border, lineWidth: 1)
                        )
                    }
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, Theme.padding)
            .padding(.vertical, 16)
        }
        .background(Theme.background)
        .navigationTitle("รายละเอียด")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// แถวแสดงข้อมูลรายละเอียด พร้อมปุ่มกดคัดลอก (Copy)
struct DetailRow: View {
    let title: String
    let value: String
    let icon: String

    @State private var copied = false

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Theme.textSecondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.textPrimary)
            }

            Spacer()

            Button {
                UIPasteboard.general.string = value
                copied = true
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    copied = false
                }
            } label: {
                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                    .font(.caption)
                    .foregroundStyle(copied ? Theme.accent : Theme.textSecondary)
                    .padding(8)
                    .background(Theme.background, in: Circle())
            }
        }
    }
}

#Preview {
    MeetingDetailView(meeting: MockData.meetings[0])
        .previewEnvironment(loggedIn: true)
}
