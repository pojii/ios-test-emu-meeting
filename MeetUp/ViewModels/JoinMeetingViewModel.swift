import Foundation
import Observation

/// ViewModel สำหรับหน้าเข้าร่วมการประชุม (Join Meeting)
/// - จัดการรหัสการประชุม (Meeting ID) และชื่อที่ต้องการให้แสดง
/// - ควบคุมการตั้งค่าเบื้องต้นก่อนเข้าห้อง เช่น ปิดไมค์ / ปิดกล้อง
@Observable
@MainActor
final class JoinMeetingViewModel {
    // MARK: - States
    var meetingCode = ""
    var displayName = ""
    var isMutedOnEntry = false
    var isVideoOffOnEntry = false

    var isLoading = false
    var errorMessage: String? = nil

    private let meetingService: MeetingService

    init(meetingService: MeetingService = MockMeetingService.shared, defaultName: String = "") {
        self.meetingService = meetingService
        self.displayName = defaultName
    }

    // MARK: - Actions

    /// เข้าร่วมการประชุมด้วยรหัสห้อง
    func join() async -> Meeting? {
        errorMessage = nil

        let digits = meetingCode.filter(\.isNumber)
        guard digits.count >= 9 else {
            errorMessage = "กรุณากรอกรหัสการประชุม 9-11 หลัก"
            return false ? nil : nil
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let meeting = try await meetingService.findMeeting(code: meetingCode)
            return meeting
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    /// อัปเดตและจัดฟอร์แมตตัวเลขรหัสห้องอัตโนมัติ
    func updateCode(_ newValue: String) {
        let digits = newValue.filter(\.isNumber)
        if digits.count <= 11 {
            meetingCode = Meeting.format(code: String(digits))
        }
    }
}
