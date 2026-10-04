import SwiftUI

/// รูปโปรไฟล์แบบวงกลม แสดงอักษรย่อของชื่อ เช่น "Somchai Jaidee" → "SJ"
/// สีพื้นหลังเลือกจากชื่อ คนเดิมจึงได้สีเดิมทุกครั้ง
struct AvatarView: View {
    let name: String
    var size: CGFloat = 44
    var showsOnlineBadge = false

    var body: some View {
        Text(Self.initials(from: name))
            .font(.system(size: size * 0.38, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(Self.color(for: name), in: Circle())
            .overlay(alignment: .bottomTrailing) {
                if showsOnlineBadge {
                    Circle()
                        .fill(Theme.accent)
                        .frame(width: size * 0.28, height: size * 0.28)
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                }
            }
            .accessibilityLabel(name)
    }

    /// เอาตัวอักษรแรกของ 2 คำแรก
    static func initials(from name: String) -> String {
        let words = name.split(whereSeparator: \.isWhitespace).prefix(2)
        let letters = words.compactMap { $0.first }.map { String($0) }
        return letters.isEmpty ? "?" : letters.joined().uppercased()
    }

    /// ใช้ผลรวมรหัสตัวอักษร (ไม่ใช้ hashValue เพราะสุ่มใหม่ทุกครั้งที่เปิดแอป)
    static func color(for name: String) -> Color {
        let sum = name.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return Theme.avatarPalette[sum % Theme.avatarPalette.count]
    }
}

#Preview {
    HStack(spacing: 12) {
        AvatarView(name: "Somchai Jaidee", size: 64, showsOnlineBadge: true)
        AvatarView(name: "Kanya Wong")
        AvatarView(name: "Napat Srisuk", size: 32)
        AvatarView(name: "สมหญิง ใจงาม")
    }
    .padding()
}
