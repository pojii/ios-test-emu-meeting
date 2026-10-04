import SwiftUI

extension View {
    /// ใส่ environment ที่ทุกหน้าต้องใช้ สำหรับ #Preview เท่านั้น
    /// ห่อด้วย NavigationStack เพื่อให้เห็น title/toolbar เหมือนตอนใช้งานจริง
    @MainActor
    func previewEnvironment(loggedIn: Bool = true) -> some View {
        NavigationStack {
            self.navigationDestination(for: Route.self) { route in
                route.destination(currentUser: MockData.currentUser)
            }
        }
        .environment(AppRouter())
        .environment(loggedIn ? SessionStore.preview : SessionStore())
        .tint(Theme.accent)
    }
}
