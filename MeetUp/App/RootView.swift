import SwiftUI

/// หน้าราก: มี NavigationStack ตัวเดียวเป็นตัวนำทางหลักของทั้งแอป
/// - ยังไม่ล็อกอิน → หน้าแรกคือ LoginView
/// - ล็อกอินแล้ว → หน้าแรกคือ HomeView
struct RootView: View {
    @Environment(AppRouter.self) private var router
    @Environment(SessionStore.self) private var session

    var body: some View {
        // @Bindable เพื่อให้ผูก $router.path กับ NavigationStack ได้
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            Group {
                if session.isLoggedIn {
                    HomeView()
                } else {
                    LoginView()
                }
            }
            .navigationDestination(for: Route.self) { route in
                route.destination(currentUser: session.currentUser ?? MockData.currentUser)
            }
        }
        .tint(Theme.accent)
        // ธีมออกแบบมาสำหรับโหมดสว่าง
        .preferredColorScheme(.light)
        // เปลี่ยนสถานะล็อกอินเมื่อไร ให้ล้าง stack เดิมทิ้ง
        .onChange(of: session.isLoggedIn) {
            router.popToRoot()
        }
    }
}

#Preview("ยังไม่ล็อกอิน") {
    RootView()
        .environment(AppRouter())
        .environment(SessionStore())
}

#Preview("ล็อกอินแล้ว") {
    RootView()
        .environment(AppRouter())
        .environment(SessionStore.preview)
}
