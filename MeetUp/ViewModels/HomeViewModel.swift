import Foundation
import Observation

/// ViewModel สำหรับหน้าหลัก (Home)
/// - จัดการโหลดรายการการประชุม
/// - กรองสถานะการประชุม (Live, Upcoming, Ended)
/// - มีฟังก์ชันเริ่มประชุมด่วน (Instant Meeting)
@Observable
@MainActor
final class HomeViewModel {
    enum MeetingFilter: String, CaseIterable, Identifiable {
        case upcoming = "การประชุมที่กำลังจะมาถึง"
        case history = "ประวัติการประชุม"

        var id: String { rawValue }
    }

    // MARK: - States
    var meetings: [Meeting] = []
    var isLoading = false
    var errorMessage: String? = nil
    var selectedFilter: MeetingFilter = .upcoming

    private let meetingService: MeetingService

    init(meetingService: MeetingService = MockMeetingService.shared) {
        self.meetingService = meetingService
    }

    // MARK: - Computed Properties

    /// การประชุมที่กำลังดำเนินอยู่ ณ ปัจจุบัน
    var liveMeetings: [Meeting] {
        meetings.filter { $0.status == .live }
    }

    /// การประชุมที่กำลังจะมาถึง
    var upcomingMeetings: [Meeting] {
        meetings.filter { $0.status == .upcoming }
    }

    /// การประชุมที่จบลงไปแล้ว
    var pastMeetings: [Meeting] {
        meetings.filter { $0.status == .ended }
    }

    /// รายการประชุมที่จะแสดงตามแท็บที่เลือก
    var filteredMeetings: [Meeting] {
        switch selectedFilter {
        case .upcoming:
            // รวม live + upcoming โดยเอา live ขึ้นก่อน
            return liveMeetings + upcomingMeetings
        case .history:
            return pastMeetings
        }
    }

    // MARK: - Actions

    /// โหลดรายการการประชุมทั้งหมด
    func loadMeetings() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            meetings = try await meetingService.fetchMeetings()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// สร้างและเริ่มการประชุมทันที (Instant Meeting สไตล์ Zoom)
    func startInstantMeeting(currentUser: User) async -> Meeting? {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let instantMeeting = try await meetingService.scheduleMeeting(
                title: "การประชุมด่วนของ \(currentUser.firstName)",
                agenda: "การประชุมด่วนที่เริ่มจากหน้าแรก",
                startDate: .now,
                durationMinutes: 45,
                passcode: nil,
                host: currentUser
            )
            // รีเฟรชรายการ
            await loadMeetings()
            return instantMeeting
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
