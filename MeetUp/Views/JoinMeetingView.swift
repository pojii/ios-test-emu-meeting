import SwiftUI

/// หน้าใส่รหัสเข้าร่วมการประชุม (Join Meeting)
/// - กรอก Meeting ID 9-11 หลัก
/// - ระบุชื่อที่จะใช้แสดงในห้องประชุม
/// - สวิตช์ตั้งค่าเปิด/ปิดไมค์และกล้องก่อนเข้าห้อง
struct JoinMeetingView: View {
    @Environment(AppRouter.self) private var router
    @Environment(SessionStore.self) private var session

    @State private var viewModel: JoinMeetingViewModel

    init() {
        _viewModel = State(initialValue: JoinMeetingViewModel(defaultName: MockData.currentUser.name))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // ส่วนกรอกรหัสและชื่อ
                VStack(spacing: 16) {
                    InputField(
                        title: "รหัสการประชุม (Meeting ID)",
                        placeholder: "823 114 5590",
                        text: Binding(
                            get: { viewModel.meetingCode },
                            set: { viewModel.updateCode($0) }
                        ),
                        systemImage: "number",
                        keyboard: .numberPad
                    )

                    InputField(
                        title: "ชื่อของคุณที่จะแสดงในห้อง",
                        placeholder: "กรอกชื่อของคุณ",
                        text: $viewModel.displayName,
                        systemImage: "person.text.rectangle"
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
                        title: "เข้าร่วมการประชุม",
                        systemImage: "arrow.right.circle.fill",
                        style: .accent,
                        isLoading: viewModel.isLoading
                    ) {
                        Task {
                            if let meeting = await viewModel.join() {
                                // แทนที่หน้า Join ด้วยห้องประชุม เพื่อไม่ให้กด Back แล้ววนกลับมาหน้านี้
                                router.replaceTop(with: .meetingRoom(meeting))
                            }
                        }
                    }

                    // ปุ่มตัวช่วยใส่รหัสเดโม
                    Button {
                        viewModel.updateCode("8231145590")
                    } label: {
                        Text("ใช้รหัสห้องประชุมตัวอย่าง (823 114 5590)")
                            .font(.caption)
                            .foregroundStyle(Theme.accent)
                    }
                    .padding(.top, 4)
                }
                .cardStyle()

                // สวิตช์ตัวเลือกก่อนเข้าห้องประชุม (Pre-meeting options)
                VStack(spacing: 14) {
                    Text("ตัวเลือกการเข้าร่วม")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Toggle("ปิดเสียงของฉันตอนเข้าห้อง", isOn: $viewModel.isMutedOnEntry)
                        .tint(Theme.accent)

                    Divider()

                    Toggle("ปิดวิดีโอของฉันตอนเข้าห้อง", isOn: $viewModel.isVideoOffOnEntry)
                        .tint(Theme.accent)
                }
                .cardStyle()
            }
            .padding(.horizontal, Theme.padding)
            .padding(.vertical, 16)
        }
        .background(Theme.background)
        .navigationTitle("เข้าร่วมการประชุม")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    JoinMeetingView()
        .previewEnvironment(loggedIn: true)
}
