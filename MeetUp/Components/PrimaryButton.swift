import SwiftUI

/// ปุ่มหลักของแอป กว้างเต็มแถว มี 4 สไตล์ และแสดงสถานะ loading ได้
/// ปิดการกดด้วย .disabled(...) จากภายนอก แล้วปุ่มจะจางลงเอง
struct PrimaryButton: View {
    enum Style {
        case primary, accent, danger, outline
    }

    let title: String
    var systemImage: String? = nil
    var style: Style = .primary
    var isLoading = false
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView().tint(textColor)
                } else if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title).fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(textColor)
            .background(fillColor, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .overlay {
                if style == .outline {
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Theme.primary, lineWidth: 1.5)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(isLoading)
        .opacity(isEnabled ? 1 : 0.45)
    }

    private var fillColor: Color {
        switch style {
        case .primary: Theme.primary
        case .accent: Theme.accent
        case .danger: Theme.danger
        case .outline: .clear
        }
    }

    private var textColor: Color {
        style == .outline ? Theme.primary : .white
    }
}

/// ย่อปุ่มลงเล็กน้อยตอนกด ให้รู้สึกตอบสนอง
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 12) {
        PrimaryButton(title: "เข้าสู่ระบบ") {}
        PrimaryButton(title: "เริ่มประชุม", systemImage: "video.fill", style: .accent) {}
        PrimaryButton(title: "ออกจากการประชุม", systemImage: "phone.down.fill", style: .danger) {}
        PrimaryButton(title: "ยกเลิก", style: .outline) {}
        PrimaryButton(title: "กำลังโหลด", isLoading: true) {}
        PrimaryButton(title: "ปิดใช้งาน") {}.disabled(true)
    }
    .padding()
    .background(Theme.background)
}
