import Foundation

/// key ของ @AppStorage (UserDefaults) ที่ใช้ร่วมกันหลายหน้า
/// เช่น SettingsView ตั้งค่า แล้ว MeetingRoomViewModel อ่านไปใช้ตอนเข้าห้อง
enum SettingsKey {
    static let muteOnJoin = "settings.muteOnJoin"
    static let cameraOffOnJoin = "settings.cameraOffOnJoin"
    static let showMeetingTimer = "settings.showMeetingTimer"
    static let notifications = "settings.notifications"
    static let videoQuality = "settings.videoQuality"
}

/// คุณภาพวิดีโอ (เก็บใน @AppStorage ได้เพราะเป็น String RawRepresentable)
enum VideoQuality: String, CaseIterable, Identifiable {
    case auto, hd, fullHD

    var id: String { rawValue }

    var label: String {
        switch self {
        case .auto: "อัตโนมัติ"
        case .hd: "HD 720p"
        case .fullHD: "Full HD 1080p"
        }
    }
}
