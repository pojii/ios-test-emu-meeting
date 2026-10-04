import Observation

/// ตัวควบคุมการนำทางหลักของแอป
/// เก็บ path ของ NavigationStack เป็น array ของ Route ทำให้ push/pop ได้จากทุกหน้า
@Observable
final class AppRouter {
    var path: [Route] = []

    /// ไปหน้าใหม่
    func push(_ route: Route) {
        path.append(route)
    }

    /// ย้อนกลับ 1 หน้า
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// กลับไปหน้าแรกสุด (เช่น ตอนออกจากห้องประชุม หรือออกจากระบบ)
    func popToRoot() {
        path.removeAll()
    }

    /// แทนที่หน้าปัจจุบัน เช่น หน้า Join → ห้องประชุม โดยกด back แล้วไม่วนกลับมาหน้า Join
    func replaceTop(with route: Route) {
        if !path.isEmpty { path.removeLast() }
        path.append(route)
    }
}
