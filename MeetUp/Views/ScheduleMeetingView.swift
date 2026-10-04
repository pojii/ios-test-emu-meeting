import SwiftUI

/// หน้านัดหมายการประชุมล่วงหน้า (Schedule Meeting)
/// - กำหนดหัวข้อ, วันที่, เวลา, และระยะเวลาของการประชุม
/// - ตัวเลือกรหัสผ่านความปลอดภัย (Passcode)
/// - บันทึกวาระการประชุม (Agenda)
struct ScheduleMeetingView: View {
    @Environment(AppRouter.self) private var router
    @Environment(SessionStore.self) private var session

    @State private var viewModel = ScheduleMeetingViewModel()

    private var currentUser: User {
        session.currentUser ?? MockData.currentUser
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // ข้อมูลทั่วไป
                VStack(spacing: 16) {
                    InputField(
                        title: "หัวข้อการประชุม",
                        placeholder: "เช่น Sprint Planning หรือ 1:1 Review",
                        text: $viewModel.title,
                        systemImage: "pencil.and.list.clipboard"
                    )

                    InputField(
                        title: "วาระการประชุม (ไม่บังคับ)",
                        placeholder: "หัวข้อที่ต้องการพูดคุย...",
                        text: $viewModel.agenda,
                        systemImage: "text.alignleft"
                    )
                }
                .cardStyle()

                // เวลาและระยะเวลา
                VStack(spacing: 16) {
                    DatePicker(
                        "วันและเวลาเริ่มต้น",
                        selection: $viewModel.startDate,
                        in: Date.now...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .tint(Theme.accent)

                    Divider()

                    HStack {
                        Text("ระยะเวลา")
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                        Picker("ระยะเวลา", selection: $viewModel.durationMinutes) {
                            Text("15 นาที").tag(15)
                            Text("30 นาที").tag(30)
                            Text("45 นาที").tag(45)
                            Text("60 นาที").tag(60)
                            Text("90 นาที").tag(90)
                        }
                        .pickerStyle(.menu)
                        .tint(Theme.accent)
                    }
                }
                .cardStyle()

                // ความปลอดภัย
                VStack(spacing: 16) {
                    Toggle("ต้องใช้รหัสผ่าน (Passcode)", isOn: $viewModel.hasPasscode)
                        .tint(Theme.accent)

                    if viewModel.hasPasscode {
                        InputField(
                            title: "รหัสผ่านห้อง",
                            placeholder: "4 หลัก",
                            text: $viewModel.passcode,
                            systemImage: "key.fill",
                            keyboard: .numberPad
                        )
                    }
                }
                .cardStyle()

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(Theme.danger)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // ปุ่มบันทึกการนัดหมาย
                PrimaryButton(
                    title: "บันทึกการนัดหมาย",
                    systemImage: "calendar.badge.plus",
                    style: .primary,
                    isLoading: viewModel.isLoading
                ) {
                    Task {
                        if let meeting = await viewModel.schedule(host: currentUser) {
                            // นัดหมายเสร็จแล้ว นำทางไปยังหน้ารายละเอียดการประชุม
                            router.replaceTop(with: .meetingDetail(meeting))
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, Theme.padding)
            .padding(.vertical, 16)
        }
        .background(Theme.background)
        .navigationTitle("นัดหมายการประชุม")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ScheduleMeetingView()
        .previewEnvironment(loggedIn: true)
}
