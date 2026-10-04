import SwiftUI

/// ช่องกรอกข้อมูลพร้อมหัวข้อ ไอคอน และข้อความ error
/// ถ้า isSecure = true จะเป็นช่องรหัสผ่านพร้อมปุ่มรูปตาให้กดดูรหัสได้
struct InputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var systemImage: String? = nil
    var isSecure = false
    var keyboard: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .never
    var errorMessage: String? = nil

    @State private var isRevealed = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Theme.textPrimary)

            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .foregroundStyle(isFocused ? Theme.accent : Theme.textSecondary)
                        .frame(width: 20)
                }

                Group {
                    if isSecure && !isRevealed {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .keyboardType(keyboard)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
                .focused($isFocused)

                if isSecure {
                    Button {
                        isRevealed.toggle()
                    } label: {
                        Image(systemName: isRevealed ? "eye.slash" : "eye")
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .accessibilityLabel(isRevealed ? "ซ่อนรหัสผ่าน" : "แสดงรหัสผ่าน")
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: isFocused ? 1.5 : 1)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(Theme.danger)
            }
        }
        .animation(.easeOut(duration: 0.15), value: isFocused)
    }

    /// สีขอบ: แดงถ้ามี error, เขียวตอนกำลังพิมพ์, เทาตอนปกติ
    private var borderColor: Color {
        if errorMessage != nil { return Theme.danger }
        return isFocused ? Theme.accent : Theme.border
    }
}

#Preview {
    VStack(spacing: 16) {
        InputField(title: "อีเมล", placeholder: "you@example.com", text: .constant(""), systemImage: "envelope")
        InputField(title: "รหัสผ่าน", placeholder: "อย่างน้อย 6 ตัวอักษร", text: .constant("123456"), systemImage: "lock", isSecure: true)
        InputField(title: "ยืนยันรหัสผ่าน", placeholder: "", text: .constant("12"), systemImage: "lock", isSecure: true, errorMessage: "รหัสผ่านไม่ตรงกัน")
    }
    .padding()
    .background(Theme.background)
}
