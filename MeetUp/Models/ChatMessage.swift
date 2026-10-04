import Foundation

/// ข้อความแชทระหว่างประชุม
struct ChatMessage: Identifiable, Hashable {
    let id: UUID
    let sender: User
    let text: String
    let sentAt: Date

    init(id: UUID = UUID(), sender: User, text: String, sentAt: Date = .now) {
        self.id = id
        self.sender = sender
        self.text = text
        self.sentAt = sentAt
    }
}
