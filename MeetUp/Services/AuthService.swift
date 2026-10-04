import Foundation

/// สัญญา (protocol) ของระบบล็อกอิน
/// ตอนนี้ใช้ MockAuthService ภายหลังเปลี่ยนเป็นตัวที่เรียก API จริงได้เลย
protocol AuthService {
    func signIn(email: String, password: String) async throws -> User
    func signUp(name: String, email: String, password: String) async throws -> User
}

enum AuthError: LocalizedError {
    case invalidCredentials

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: "อีเมลหรือรหัสผ่านไม่ถูกต้อง"
        }
    }
}

/// ล็อกอินจำลอง: หน่วงเวลาเหมือนเรียกเซิร์ฟเวอร์ แล้วคืนผู้ใช้ทดลอง
struct MockAuthService: AuthService {
    func signIn(email: String, password: String) async throws -> User {
        try await Task.sleep(for: .milliseconds(800))
        guard email.contains("@"), password.count >= 6 else {
            throw AuthError.invalidCredentials
        }
        var user = MockData.currentUser
        user.email = email
        return user
    }

    func signUp(name: String, email: String, password: String) async throws -> User {
        try await Task.sleep(for: .milliseconds(1000))
        return User(name: name, email: email, jobTitle: "สมาชิกใหม่")
    }
}
