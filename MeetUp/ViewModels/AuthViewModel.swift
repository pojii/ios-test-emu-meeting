import Foundation
import Observation

/// ViewModel ควบคุมกระบวนการเข้าสู่ระบบและการสมัครสมาชิกใหม่
/// - จัดการ State ของฟอร์ม (อีเมล, รหัสผ่าน, ชื่อ)
/// - ตรวจสอบความถูกต้องของข้อมูล (Validation)
/// - สื่อสารกับ AuthService เพื่อยืนยันตัวตน
@Observable
@MainActor
final class AuthViewModel {
    // MARK: - Form States
    var email = ""
    var password = ""
    var name = ""
    var confirmPassword = ""

    // MARK: - UI States
    var isLoading = false
    var errorMessage: String? = nil

    private let authService: AuthService

    init(authService: AuthService = MockAuthService()) {
        self.authService = authService
    }

    // MARK: - Actions

    /// ตรวจสอบและเข้าสู่ระบบ
    func signIn() async -> User? {
        errorMessage = nil

        guard validateSignIn() else { return nil }

        isLoading = true
        defer { isLoading = false }

        do {
            let user = try await authService.signIn(email: email.trimmingCharacters(in: .whitespaces), password: password)
            return user
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    /// ตรวจสอบและสร้างบัญชีใหม่
    func signUp() async -> User? {
        errorMessage = nil

        guard validateSignUp() else { return nil }

        isLoading = true
        defer { isLoading = false }

        do {
            let user = try await authService.signUp(
                name: name.trimmingCharacters(in: .whitespaces),
                email: email.trimmingCharacters(in: .whitespaces),
                password: password
            )
            return user
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    /// กรอกข้อมูลบัญชีทดลองให้อัตโนมัติ สำหรับกดทดสอบได้อย่างรวดเร็ว
    func fillDemoAccount() {
        email = MockData.currentUser.email
        password = MockData.demoPassword
        errorMessage = nil
    }

    // MARK: - Validation

    private func validateSignIn() -> Bool {
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "กรุณากรอกอีเมล"
            return false
        }
        if !email.contains("@") {
            errorMessage = "รูปแบบอีเมลไม่ถูกต้อง"
            return false
        }
        if password.isEmpty {
            errorMessage = "กรุณากรอกรหัสผ่าน"
            return false
        }
        return true
    }

    private func validateSignUp() -> Bool {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "กรุณากรอกชื่อ-นามสกุล"
            return false
        }
        if !validateSignIn() {
            return false
        }
        if password.count < 6 {
            errorMessage = "รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร"
            return false
        }
        if password != confirmPassword {
            errorMessage = "รหัสผ่านยืนยันไม่ตรงกัน"
            return false
        }
        return true
    }
}
