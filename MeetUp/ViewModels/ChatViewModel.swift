import Foundation
import Observation

/// ViewModel จัดการระบบแชทในห้องประชุม
/// - แสดงรายการข้อความแชท
/// - ส่งข้อความใหม่ และปุ่มแสดงความคิดเห็นด่วน (Quick Reaction)
/// - จำลองข้อความตอบกลับอัตโนมัติจากผู้เข้าร่วมคนอื่น
@Observable
@MainActor
final class ChatViewModel {
    let meeting: Meeting
    let currentUser: User

    var messages: [ChatMessage] = []
    var inputText = ""

    init(meeting: Meeting, currentUser: User) {
        self.meeting = meeting
        self.currentUser = currentUser
        self.messages = MockData.messages
    }

    // MARK: - Actions

    /// ส่งข้อความแชท
    func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newMsg = ChatMessage(sender: currentUser, text: trimmed, sentAt: .now)
        messages.append(newMsg)
        inputText = ""

        // จำลองให้คนอื่นตอบกลับอัตโนมัติหลังผ่านไป 1.5 วินาที
        simulateReply()
    }

    /// ส่งอีโมจิด่วน เช่น 👍 ❤️ 👏 🎉
    func sendQuickReaction(_ reaction: String) {
        let reactionMsg = ChatMessage(sender: currentUser, text: reaction, sentAt: .now)
        messages.append(reactionMsg)
    }

    // MARK: - Simulation

    private func simulateReply() {
        // หาผู้เข้าร่วมคนอื่นที่ไม่ใช่ตัวเรา
        let others = meeting.participants.filter { $0.id != currentUser.id }
        guard let responder = others.randomElement() else { return }

        Task {
            try? await Task.sleep(for: .milliseconds(1500))
            guard let autoText = MockData.autoReplies.randomElement() else { return }

            let replyMsg = ChatMessage(sender: responder, text: autoText, sentAt: .now)
            self.messages.append(replyMsg)
        }
    }
}
