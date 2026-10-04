import SwiftUI

/// จุดเริ่มต้นของแอป MeetUp
/// สร้าง object ส่วนกลาง (router + session) ครั้งเดียว แล้วส่งให้ทุกหน้าผ่าน environment
@main
struct MeetUpApp: App {
    @State private var router = AppRouter()
    @State private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
                .environment(session)
        }
    }
}
