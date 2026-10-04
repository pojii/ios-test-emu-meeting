import SwiftUI

/// กรอบการ์ดพื้นขาว มุมมน มีเงาจาง ใช้ซ้ำหลายหน้า
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .shadow(color: Theme.primary.opacity(0.06), radius: 8, y: 3)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}

#Preview {
    Text("เนื้อหาในการ์ด")
        .cardStyle()
        .padding()
        .background(Theme.background)
}
