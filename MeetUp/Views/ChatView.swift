import SwiftUI

/// หน้าต่างแชทระหว่างการประชุม (In-Meeting Chat)
/// - แสดงรายการข้อความแชททั้งหมด
/// - จำแนกข้อความของตนเอง (สีเขียว Theme.accent) และของผู้อื่น
/// - มีปุ่มสำหรับส่ง Emoji ความคิดเห็นด่วน (Quick Reaction)
/// - จำลองข้อความตอบกลับอัตโนมัติจากผู้เข้าร่วมคนอื่น
struct ChatView: View {
    @Environment(\.dismiss) private var dismiss

    let meeting: Meeting
    let currentUser: User

    @State private var viewModel: ChatViewModel

    init(meeting: Meeting, currentUser: User) {
        self.meeting = meeting
        self.currentUser = currentUser
        _viewModel = State(initialValue: ChatViewModel(meeting: meeting, currentUser: currentUser))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // รายการข้อความแชท
                messagesList

                // แถบส่ง Emoji ปฏิกิริยาด่วน
                quickReactionRow

                // ช่องกรอกข้อความแชท
                inputBar
            }
            .background(Theme.background)
            .navigationTitle("แชทในการประชุม")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("ปิด") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.accent)
                }
            }
        }
    }

    // MARK: - Subviews

    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageBubble(
                            message: message,
                            isSelf: message.sender.id == currentUser.id
                        )
                        .id(message.id)
                    }
                }
                .padding(16)
            }
            .onChange(of: viewModel.messages.count) {
                if let last = viewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var quickReactionRow: some View {
        HStack(spacing: 12) {
            ForEach(["👍", "❤️", "👏", "🎉", "🔥"], id: \.self) { emoji in
                Button {
                    viewModel.sendQuickReaction(emoji)
                } label: {
                    Text(emoji)
                        .font(.title3)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Theme.surface, in: Capsule())
                        .shadow(color: Theme.primary.opacity(0.04), radius: 3, y: 1)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("พิมพ์ข้อความในห้องประชุม...", text: $viewModel.inputText)
                .padding(.horizontal, 14)
                .frame(height: 44)
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: 22))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Theme.border))

            Button {
                viewModel.sendMessage()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty ? Theme.textSecondary : Theme.accent, in: Circle())
            }
            .disabled(viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Theme.surface)
    }
}

/// กล่องข้อความแชท
struct MessageBubble: View {
    let message: ChatMessage
    let isSelf: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isSelf { Spacer(minLength: 40) }

            if !isSelf {
                AvatarView(name: message.sender.name, size: 30)
            }

            VStack(alignment: isSelf ? .trailing : .leading, spacing: 3) {
                if !isSelf {
                    Text(message.sender.name)
                        .font(.caption2.bold())
                        .foregroundStyle(Theme.textSecondary)
                }

                Text(message.text)
                    .font(.subheadline)
                    .foregroundStyle(isSelf ? .white : Theme.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        isSelf ? Theme.accent : Theme.surface,
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelf ? .clear : Theme.border, lineWidth: 1)
                    )

                Text(message.sentAt, format: .dateTime.hour().minute())
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.textSecondary)
            }

            if isSelf {
                AvatarView(name: message.sender.name, size: 30)
            }

            if !isSelf { Spacer(minLength: 40) }
        }
    }
}

#Preview {
    ChatView(
        meeting: MockData.meetings[0],
        currentUser: MockData.currentUser
    )
}
