import Foundation

/// ผู้เข้าร่วมที่อยู่ในห้องประชุมตอนนี้ (สถานะไมค์/กล้อง/ยกมือ)
struct Participant: Identifiable, Hashable {
    let user: User
    var isHost: Bool
    var isMuted: Bool
    var isVideoOn: Bool
    var isHandRaised: Bool = false

    var id: UUID { user.id }
}
