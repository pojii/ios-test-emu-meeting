import SwiftUI

/// การ์ดสรุปการประชุมในหน้า Home: เวลา, หัวข้อ, สถานะ, ผู้เข้าร่วม
struct MeetingCard: View {
    let meeting: Meeting

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // คอลัมน์ซ้าย: เวลาและวันที่
            VStack(spacing: 2) {
                Text(meeting.startDate, format: .dateTime.hour().minute())
                    .font(.headline.monospacedDigit())
                Text(meeting.startDate, format: .dateTime.day().month(.abbreviated))
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            .frame(width: 64)
            .padding(.vertical, 8)
            .background(Theme.background, in: RoundedRectangle(cornerRadius: 10))

            // คอลัมน์ขวา: รายละเอียด
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(meeting.title)
                        .font(.headline)
                        .lineLimit(2)
                    Spacer(minLength: 8)
                    MeetingStatusBadge(status: meeting.status)
                }

                Label("\(meeting.durationMinutes) นาที · ID \(meeting.meetingCode)", systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)

                AvatarStack(users: meeting.participants)
            }
        }
        .foregroundStyle(Theme.textPrimary)
        .cardStyle()
    }
}

/// ป้ายสถานะ: กำลังประชุม / กำลังจะมาถึง / จบแล้ว
struct MeetingStatusBadge: View {
    let status: Meeting.Status

    var body: some View {
        Text(status.label)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(color)
            .background(color.opacity(0.12), in: Capsule())
    }

    private var color: Color {
        switch status {
        case .live: Theme.accent
        case .upcoming: Theme.primary
        case .ended: Theme.textSecondary
        }
    }
}

/// รูปผู้เข้าร่วมซ้อนกัน แสดงสูงสุด 4 คน ที่เหลือแสดงเป็น +n
struct AvatarStack: View {
    let users: [User]
    var maxVisible = 4
    var size: CGFloat = 28

    var body: some View {
        HStack(spacing: -size * 0.3) {
            ForEach(users.prefix(maxVisible)) { user in
                AvatarView(name: user.name, size: size)
                    .overlay(Circle().stroke(.white, lineWidth: 2))
            }
            if users.count > maxVisible {
                Text("+\(users.count - maxVisible)")
                    .font(.caption2.bold())
                    .foregroundStyle(Theme.textPrimary)
                    .frame(width: size, height: size)
                    .background(Theme.border, in: Circle())
                    .overlay(Circle().stroke(.white, lineWidth: 2))
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(MockData.meetings.prefix(3)) { meeting in
            MeetingCard(meeting: meeting)
        }
    }
    .padding()
    .background(Theme.background)
}
