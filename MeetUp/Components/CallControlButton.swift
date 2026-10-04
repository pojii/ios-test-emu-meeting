import SwiftUI

/// ปุ่มวงกลมในแถบควบคุมของห้องประชุม (ไมค์, กล้อง, แชร์จอ, แชท, ออก)
struct CallControlButton: View {
    let systemImage: String
    let title: String
    /// true = ปุ่มอยู่ในสถานะเปิดใช้งาน (พื้นขาว) เช่น กำลังแชร์หน้าจอ
    var isActive = false
    /// กำหนดสีพื้นเอง เช่น แดงสำหรับปุ่มวางสาย/ไมค์ปิด
    var fill: Color? = nil
    /// ตัวเลขแจ้งเตือนมุมขวาบน (0 = ไม่แสดง)
    var badge = 0
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isActive && fill == nil ? Theme.primary : .white)
                    .frame(width: 52, height: 52)
                    .background(backgroundColor, in: Circle())
                    .overlay(alignment: .topTrailing) {
                        if badge > 0 {
                            Text("\(badge)")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .frame(minWidth: 18, minHeight: 18)
                                .background(Theme.danger, in: Capsule())
                                .offset(x: 4, y: -4)
                        }
                    }
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(title)
    }

    private var backgroundColor: Color {
        if let fill { return fill }
        return isActive ? .white : .white.opacity(0.12)
    }
}

#Preview {
    HStack {
        CallControlButton(systemImage: "mic.slash.fill", title: "เปิดไมค์", fill: Theme.danger) {}
        CallControlButton(systemImage: "video.fill", title: "ปิดกล้อง") {}
        CallControlButton(systemImage: "rectangle.on.rectangle", title: "แชร์จอ", isActive: true) {}
        CallControlButton(systemImage: "bubble.left.fill", title: "แชท", badge: 3) {}
        CallControlButton(systemImage: "phone.down.fill", title: "ออก", fill: Theme.danger) {}
    }
    .padding()
    .background(Theme.callBackground)
}
