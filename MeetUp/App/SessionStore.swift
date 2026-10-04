import Observation

/// เก็บสถานะการเข้าสู่ระบบของทั้งแอป
/// RootView ดูค่า isLoggedIn เพื่อสลับระหว่างหน้า Login กับหน้า Home
@MainActor @Observable
final class SessionStore {
    private(set) var currentUser: User?

    var isLoggedIn: Bool { currentUser != nil }

    init(currentUser: User? = nil) {
        self.currentUser = currentUser
    }

    func signIn(_ user: User) {
        currentUser = user
    }

    func signOut() {
        currentUser = nil
    }

    /// session ที่ล็อกอินไว้แล้ว ใช้ใน #Preview
    static var preview: SessionStore {
        SessionStore(currentUser: MockData.currentUser)
    }
}
