import SwiftUI

/// หน้าเข้าสู่ระบบ (Login)
/// - มีช่องกรอกอีเมลและรหัสผ่าน
/// - มีปุ่มสำหรับกรอกข้อมูลบัญชีทดลองทันที (Demo Account)
/// - นำทางไปหน้าสมัครสมาชิกใหม่ได้
struct LoginView: View {
    @Environment(AppRouter.self) private var router
    @Environment(SessionStore.self) private var session

    @State private var viewModel = AuthViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // MARK: - Logo & Welcome Header
                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Theme.accent)
                            .frame(width: 80, height: 80)
                            .shadow(color: Theme.accent.opacity(0.3), radius: 10, y: 5)

                        Image(systemName: "video.fill")
                            .font(.system(size: 38))
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 40)

                    Text("MeetUp")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.primary)

                    Text("เชื่อมต่อทุกการประชุมคุณภาพสูง ได้ทุกที่ทุกเวลา")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                // MARK: - Login Form
                VStack(spacing: 18) {
                    InputField(
                        title: "อีเมล",
                        placeholder: "you@example.com",
                        text: $viewModel.email,
                        systemImage: "envelope.fill",
                        keyboard: .emailAddress
                    )

                    InputField(
                        title: "รหัสผ่าน",
                        placeholder: "กรอกรหัสผ่านของคุณ",
                        text: $viewModel.password,
                        systemImage: "lock.fill",
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
                        title: "เข้าสู่ระบบ",
                        style: .primary,
                        isLoading: viewModel.isLoading
                    ) {
                        Task {
                            if let user = await viewModel.signIn() {
                                session.signIn(user)
                            }
                        }
                    }

                    // ปุ่มล็อกอินด่วนสำหรับทดสอบ
                    Button {
                        viewModel.fillDemoAccount()
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("ใช้บัญชีทดลอง (Somchai Jaidee)")
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Theme.accent)
                    }
                    .padding(.top, 4)
                }
                .cardStyle()

                // MARK: - Register Link
                HStack(spacing: 4) {
                    Text("ยังไม่มีบัญชีผู้ใช้งาน?")
                        .foregroundStyle(Theme.textSecondary)
                    Button {
                        router.push(.signUp)
                    } label: {
                        Text("สมัครสมาชิก")
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.accent)
                    }
                }
                .font(.subheadline)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, Theme.padding)
        }
        .background(Theme.background)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    LoginView()
        .previewEnvironment(loggedIn: false)
}
