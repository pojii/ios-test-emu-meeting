import Foundation

/// ข้อมูลจำลองทั้งหมดของแอป (ยังไม่ต่อฐานข้อมูล)
/// เมื่อมี backend จริง ให้เปลี่ยนไปใช้ Service ตัวจริงแทน Mock*Service โดยไม่ต้องแก้ View
enum MockData {

    // MARK: - ผู้ใช้

    /// ผู้ใช้ที่ล็อกอินอยู่ (บัญชีทดลอง)
    static let currentUser = User(
        name: "Somchai Jaidee",
        email: "somchai@meetup.app",
        jobTitle: "iOS Developer"
    )

    /// รหัสผ่านของบัญชีทดลอง
    static let demoPassword = "123456"

    /// ห้องประชุมส่วนตัวของผู้ใช้ (Personal Meeting ID)
    static let personalMeetingID = "555 123 4567"

    static let users: [User] = [
        currentUser,
        User(name: "Napat Srisuk", email: "napat@meetup.app", jobTitle: "Product Manager"),
        User(name: "Kanya Wong", email: "kanya@meetup.app", jobTitle: "UX Designer"),
        User(name: "Arthit Chai", email: "arthit@meetup.app", jobTitle: "Backend Engineer"),
        User(name: "Pimchanok Lee", email: "pimchanok@meetup.app", jobTitle: "QA Engineer"),
        User(name: "Thanawat Boon", email: "thanawat@meetup.app", jobTitle: "Team Lead")
    ]

    // MARK: - การประชุม (เวลาอิงจากตอนเปิดแอป เพื่อให้มีครบทุกสถานะ)

    static let meetings: [Meeting] = [
        Meeting(
            title: "Daily Standup",
            meetingCode: "823 114 5590",
            passcode: "1234",
            host: users[5],
            startDate: .now.addingTimeInterval(-10 * 60),     // เริ่มไปแล้ว 10 นาที → กำลังประชุม
            durationMinutes: 30,
            participants: Array(users.prefix(5)),
            agenda: "อัปเดตงานเมื่อวาน / งานวันนี้ / ปัญหาที่ติดอยู่"
        ),
        Meeting(
            title: "Design Review – หน้า Onboarding",
            meetingCode: "604 772 1385",
            host: users[2],
            startDate: .now.addingTimeInterval(2 * 60 * 60),  // อีก 2 ชั่วโมง
            durationMinutes: 45,
            participants: [users[0], users[1], users[2]],
            agenda: "รีวิว flow สมัครสมาชิก และสี/ไอคอนชุดใหม่"
        ),
        Meeting(
            title: "Sprint Planning",
            meetingCode: "917 330 2046",
            passcode: "8899",
            host: users[1],
            startDate: date(dayOffset: 1, hour: 10, minute: 0),
            durationMinutes: 90,
            participants: users,
            agenda: "เลือก backlog เข้าสปรินต์ 24 และประเมิน story point"
        ),
        Meeting(
            title: "1:1 กับหัวหน้าทีม",
            meetingCode: "338 501 7712",
            host: users[5],
            startDate: date(dayOffset: 3, hour: 14, minute: 30),
            durationMinutes: 30,
            participants: [users[0], users[5]]
        ),
        Meeting(
            title: "Retrospective",
            meetingCode: "245 908 6631",
            host: users[5],
            startDate: date(dayOffset: -1, hour: 16, minute: 0),  // เมื่อวาน → จบแล้ว
            durationMinutes: 60,
            participants: users
        )
    ]

    // MARK: - แชท

    static let messages: [ChatMessage] = [
        ChatMessage(sender: users[5], text: "สวัสดีทุกคนครับ เริ่มกันเลยนะ", sentAt: .now.addingTimeInterval(-9 * 60)),
        ChatMessage(sender: users[1], text: "วันนี้ขอคุยเรื่อง release 1.2 ด้วยนะคะ", sentAt: .now.addingTimeInterval(-8 * 60)),
        ChatMessage(sender: currentUser, text: "ได้ครับ ผมแก้ bug หน้า login เสร็จแล้ว", sentAt: .now.addingTimeInterval(-6 * 60)),
        ChatMessage(sender: users[2], text: "ส่งลิงก์ Figma ไว้ในห้องแล้วนะ 🎨", sentAt: .now.addingTimeInterval(-3 * 60))
    ]

    /// ข้อความตอบกลับอัตโนมัติ เพื่อให้แชทดูมีชีวิต
    static let autoReplies = [
        "รับทราบครับ 👍",
        "เห็นด้วยค่ะ",
        "เดี๋ยวขอเช็กแล้วแจ้งอีกทีนะครับ",
        "โอเคเลย",
        "ขอบคุณที่แจ้งค่ะ 🙏"
    ]

    // MARK: - ผู้เข้าร่วมในห้อง

    /// สร้างสถานะไมค์/กล้องแบบคละกัน ให้ห้องประชุมดูสมจริง
    static func participants(for meeting: Meeting) -> [Participant] {
        meeting.participants.enumerated().map { index, user in
            Participant(
                user: user,
                isHost: user.id == meeting.host.id,
                isMuted: index % 2 == 1,
                isVideoOn: index % 3 != 2,
                isHandRaised: index == 3
            )
        }
    }

    // MARK: - ตัวช่วย

    /// วันที่แบบ "อีก n วัน เวลา hh:mm"
    private static func date(dayOffset: Int, hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        let day = calendar.date(byAdding: .day, value: dayOffset, to: .now) ?? .now
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
    }
}
