import Foundation

/// ข้อมูลการประชุม 1 ห้อง
struct Meeting: Identifiable, Hashable {
    let id: UUID
    var title: String
    var meetingCode: String      // รูปแบบ "823 114 5590"
    var passcode: String?
    var host: User
    var startDate: Date
    var durationMinutes: Int
    var participants: [User]
    var agenda: String

    init(
        id: UUID = UUID(),
        title: String,
        meetingCode: String,
        passcode: String? = nil,
        host: User,
        startDate: Date,
        durationMinutes: Int,
        participants: [User],
        agenda: String = ""
    ) {
        self.id = id
        self.title = title
        self.meetingCode = meetingCode
        self.passcode = passcode
        self.host = host
        self.startDate = startDate
        self.durationMinutes = durationMinutes
        self.participants = participants
        self.agenda = agenda
    }

    var endDate: Date {
        startDate.addingTimeInterval(TimeInterval(durationMinutes * 60))
    }

    // MARK: - สถานะ (คำนวณจากเวลาปัจจุบัน)

    enum Status {
        case upcoming, live, ended

        var label: String {
            switch self {
            case .upcoming: "กำลังจะมาถึง"
            case .live: "กำลังประชุม"
            case .ended: "จบแล้ว"
            }
        }
    }

    var status: Status {
        let now = Date.now
        if now < startDate { return .upcoming }
        if now <= endDate { return .live }
        return .ended
    }

    /// ข้อความเชิญ สำหรับแชร์ผ่าน ShareLink
    var invitationText: String {
        var lines = [
            "\(host.name) เชิญคุณเข้าร่วมประชุม MeetUp",
            "หัวข้อ: \(title)",
            "เวลา: \(startDate.formatted(date: .abbreviated, time: .shortened))",
            "Meeting ID: \(meetingCode)"
        ]
        if let passcode { lines.append("รหัสผ่าน: \(passcode)") }
        return lines.joined(separator: "\n")
    }

    // MARK: - ตัวช่วยจัดรูปแบบรหัสห้อง

    /// "8231145590" → "823 114 5590"
    static func format(code digits: String) -> String {
        var result = ""
        for (index, char) in digits.enumerated() {
            if index == 3 || index == 6 { result.append(" ") }
            result.append(char)
        }
        return result
    }

    /// สุ่มรหัสห้อง 10 หลัก
    static func randomCode() -> String {
        format(code: String((0..<10).map { _ in "0123456789".randomElement()! }))
    }
}
