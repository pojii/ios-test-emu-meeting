import Foundation
import Observation

/// ViewModel สำหรับหน้านัดหมายการประชุมล่วงหน้า (Schedule Meeting)
/// - จัดการฟอร์ม: หัวข้อ, วาระ, วันและเวลา, ระยะเวลา, รหัสผ่าน
@Observable
@MainActor
final class ScheduleMeetingViewModel {
    // MARK: - Form States
    var title = ""
    var agenda = ""
    var startDate: Date = Date.now.addingTimeInterval(3600) // ค่าเริ่มต้นคืออีก 1 ชม.
    var durationMinutes = 30
    var hasPasscode = true
    var passcode = "1234"

    var isLoading = false
    var errorMessage: String? = nil

    private let meetingService: MeetingService

    init(meetingService: MeetingService = MockMeetingService.shared) {
        self.meetingService = meetingService
    }

    // MARK: - Actions

    /// บันทึกและสร้างการประชุมใหม่
    func schedule(host: User) async -> Meeting? {
        errorMessage = nil

        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else {
            errorMessage = "กรุณากรอกหัวข้อการประชุม"
            return nil
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let meeting = try await meetingService.scheduleMeeting(
                title: trimmedTitle,
                agenda: agenda.trimmingCharacters(in: .whitespaces),
                startDate: startDate,
                durationMinutes: durationMinutes,
                passcode: hasPasscode ? passcode : nil,
                host: host
            )
            return meeting
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
