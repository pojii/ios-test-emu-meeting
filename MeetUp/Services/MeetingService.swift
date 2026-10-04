import Foundation

/// สัญญา (protocol) ของระบบจัดการการประชุม
@MainActor
protocol MeetingService {
    func fetchMeetings() async throws -> [Meeting]
    func findMeeting(code: String) async throws -> Meeting
    func scheduleMeeting(
        title: String,
        agenda: String,
        startDate: Date,
        durationMinutes: Int,
        passcode: String?,
        host: User
    ) async throws -> Meeting
}

enum MeetingError: LocalizedError {
    case invalidCode

    var errorDescription: String? {
        switch self {
        case .invalidCode: "รหัสการประชุมไม่ถูกต้อง (ต้องเป็นตัวเลข 9–11 หลัก)"
        }
    }
}

/// เก็บการประชุมไว้ในหน่วยความจำ (หายเมื่อปิดแอป)
/// ใช้ instance เดียว (shared) เพื่อให้การประชุมที่นัดใหม่ไปโผล่ในหน้า Home
@MainActor
final class MockMeetingService: MeetingService {
    static let shared = MockMeetingService()

    private var meetings: [Meeting] = MockData.meetings

    func fetchMeetings() async throws -> [Meeting] {
        try await Task.sleep(for: .milliseconds(400))
        return meetings.sorted { $0.startDate < $1.startDate }
    }

    func findMeeting(code: String) async throws -> Meeting {
        try await Task.sleep(for: .milliseconds(600))
        let digits = code.filter(\.isNumber)

        if let found = meetings.first(where: { $0.meetingCode.filter(\.isNumber) == digits }) {
            return found
        }
        guard (9...11).contains(digits.count) else {
            throw MeetingError.invalidCode
        }
        // ไม่พบใน mock → เปิดห้องใหม่ให้ เพื่อให้เดโมด้วยรหัสอะไรก็ได้
        let code = Meeting.format(code: digits)
        let meeting = Meeting(
            title: "ห้องประชุม \(code)",
            meetingCode: code,
            host: MockData.users[1],
            startDate: .now,
            durationMinutes: 60,
            participants: Array(MockData.users[1...3])
        )
        meetings.append(meeting)
        return meeting
    }

    func scheduleMeeting(
        title: String,
        agenda: String,
        startDate: Date,
        durationMinutes: Int,
        passcode: String?,
        host: User
    ) async throws -> Meeting {
        try await Task.sleep(for: .milliseconds(500))
        let meeting = Meeting(
            title: title,
            meetingCode: Meeting.randomCode(),
            passcode: passcode,
            host: host,
            startDate: startDate,
            durationMinutes: durationMinutes,
            participants: [host],
            agenda: agenda
        )
        meetings.append(meeting)
        return meeting
    }
}
