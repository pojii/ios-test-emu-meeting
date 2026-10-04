import SwiftUI

/// สีและค่าพื้นฐานของดีไซน์ทั้งแอป
/// ทุกหน้าดึงสีจากที่นี่ (ไม่ hard-code สีในหน้าจอ) เพื่อให้เปลี่ยนธีมได้จากที่เดียว
enum Theme {
    // MARK: - สีหลักตาม brand
    static let primary = Color(hex: 0x1B2A4A)     // น้ำเงินเข้ม: ปุ่มหลัก, หัวข้อ
    static let accent = Color(hex: 0x2A9D8F)      // เขียวอมฟ้า: ไฮไลต์, สถานะ "กำลังประชุม"
    static let background = Color(hex: 0xF4F6F5)  // พื้นหลังทั่วไป
    static let danger = Color(hex: 0xD64545)      // วางสาย, ปิดไมค์, ข้อความ error

    // MARK: - สีรอง
    static let surface = Color.white
    static let textPrimary = Theme.primary
    static let textSecondary = Color(hex: 0x6B7280)
    static let border = Color(hex: 0xDDE2E0)
    static let highlight = Color(hex: 0xE76F51)
    static let callBackground = Color(hex: 0x0F1A2E)  // พื้นหลังห้องประชุม (เข้มกว่า primary)
    static let tileBackground = Color(hex: 0x24365C)  // พื้นหลังช่องวิดีโอ

    /// ชุดสีพื้นหลังของ AvatarView (เลือกจากชื่อ เพื่อให้คนเดิมได้สีเดิมเสมอ)
    static let avatarPalette: [Color] = [
        Theme.primary, Theme.accent, Theme.highlight,
        Color(hex: 0x6D597A), Color(hex: 0x457B9D), Color(hex: 0xC08B2C)
    ]

    // MARK: - ขนาด
    static let cornerRadius: CGFloat = 14
    static let padding: CGFloat = 20
}

extension Color {
    /// สร้างสีจากเลขฐาน 16 เช่น Color(hex: 0x1B2A4A)
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

#Preview("Theme") {
    let swatches: [(String, Color)] = [
        ("primary", Theme.primary), ("accent", Theme.accent),
        ("background", Theme.background), ("danger", Theme.danger)
    ]
    VStack(spacing: 12) {
        ForEach(swatches, id: \.0) { name, color in
            HStack {
                RoundedRectangle(cornerRadius: 8).fill(color).frame(width: 56, height: 40)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.border))
                Text(name).font(.headline)
                Spacer()
            }
        }
    }
    .padding()
}
