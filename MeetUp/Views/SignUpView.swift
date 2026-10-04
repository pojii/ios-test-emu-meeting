import SwiftUI

/// หน้าสมัครสมาชิกใหม่ (Sign Up)
/// - มีช่องกรอกชื่อ-นามสกุล, อีเมล, รหัสผ่าน, และยืนยันรหัสผ่าน
/// - สมัครสำเร็จแล้วจะเข้าสู่ระบบให้อัตโนมัติ
struct SignUpView: View {
    @Environment(AppRouter.self) private var router
    @Environment(SessionStore.self) private var session

    @State private var viewModel = AuthViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("สร้างบัญชีใหม่")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Theme.primary)

                    Text("กรอกข้อมูลเพื่อเริ่มต้นใช้งาน MeetUp ฟรี")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(.top, 16)

                // Registration Form
                VStack(spacing: 16) {
                    InputField(
                        title: "ชื่อ-นามสกุล",
                        placeholder: "เช่น สมชาย ใจดี",
                        text: $viewModel.name,
                        systemImage: "person.fill"
                    )

                    InputField(
                        title: "อีเมล",
                        placeholder: "you@example.com",
                        text: $viewModel.email,
                        systemImage: "envelope.fill",
                        keyboard: .emailAddress
                    )

                    InputField(
                        title: "รหัสผ่าน",
                        placeholder: "อย่างน้อย 6 ตัวอักษร",
                        text: $viewModel.password,
                        systemImage: "lock.fill",
                        isSecure: true
                    )

                    InputField(
                        title: "ยืนยันรหัสผ่าน",
                        placeholder: "กรอกรหัสผ่านอีกครั้ง",
                        text: $viewModel.confirmPassword,
                        systemImage: "lock.shield.fill",
                        isSecure: true
                    )

                    if let error = viewModel.errorMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text(error)
                        }
                        .font(.footnote)
                        .foregroundStyle(Theme.danger)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    PrimaryButton(
                        title: "ลงทะเบียน",
                        style: .accent,
                        isLoading: viewModel.isLoading
                    ) {
                        Task {
                            if let user = await viewModel.signUp() {
                                session.signIn(user)
                            }
                        }
                    }
                }
                .cardStyle()

                // Back to Login Link
                Button {
                    router.pop()
                } label: {
                    HStack(spacing: 4) {
                        Text("มีบัญชีอยู่แล้ว?")
                            .foregroundStyle(Theme.textSecondary)
                        Text("เข้าสู่ระบบ")
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.accent)
                    }
                    .font(.subheadline)
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, Theme.padding)
        }
        .background(Theme.background)
        .navigationTitle("สมัครสมาชิก")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SignUpView()
        .previewEnvironment(loggedIn: false)
}
