import SwiftUI

/// ช่องวิดีโอของผู้เข้าร่วม 1 คนในห้องประชุม
/// ยังไม่ได้ต่อกล้องจริง: ถ้ากล้องเปิดจะแสดงภาพจำลอง ถ้าปิดจะแสดง Avatar
struct VideoTileView: View {
    let participant: Participant
    var isSelf = false
    var isSpeaking = false

    var body: some View {
        Color.clear
            .aspectRatio(3 / 4, contentMode: .fit)
            .overlay { videoContent }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(alignment: .bottomLeading) {
                nameTag.padding(8)
            }
            .overlay(alignment: .topTrailing) {
                if participant.isHandRaised {
                    Text("✋")
                        .font(.title3)
                        .padding(6)
                        .background(.white, in: Circle())
                        .padding(8)
                }
            }
            // กรอบเขียวรอบคนที่กำลังพูด
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Theme.accent, lineWidth: isSpeaking ? 3 : 0)
            }
            .animation(.easeInOut(duration: 0.2), value: isSpeaking)
    }

    @ViewBuilder
    private var videoContent: some View {
        if participant.isVideoOn {
            // ภาพจำลองจากกล้อง
            ZStack {
                LinearGradient(
                    colors: [AvatarView.color(for: participant.user.name).opacity(0.85), Theme.tileBackground],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Image(systemName: "person.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.white.opacity(0.35))
                    .offset(y: 24)
            }
        } else {
            ZStack {
                Theme.tileBackground
                AvatarView(name: participant.user.name, size: 64)
            }
        }
    }

    private var nameTag: some View {
        HStack(spacing: 4) {
            Image(systemName: participant.isMuted ? "mic.slash.fill" : "mic.fill")
                .foregroundStyle(participant.isMuted ? Theme.danger : .white)
            Text(isSelf ? "\(participant.user.firstName) (คุณ)" : participant.user.firstName)
                .lineLimit(1)
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.black.opacity(0.45), in: Capsule())
    }
}

#Preview {
    let participants = MockData.participants(for: MockData.meetings[0])
    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 10) {
        ForEach(participants) { participant in
            VideoTileView(
                participant: participant,
                isSelf: participant.id == MockData.currentUser.id,
                isSpeaking: participant.id == participants[1].id
            )
        }
    }
    .padding()
    .background(Theme.callBackground)
}
