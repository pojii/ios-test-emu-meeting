import SwiftUI

/// หน้าตั้งค่าแอปพลิเคชัน (Settings)
/// - จัดเก็บการตั้งค่าลง @AppStorage (UserDefaults)
/// - ตัวเลือกการประชุม: ปิดไมค์/ปิดกล้องเมื่อเข้าห้อง, แสดงตัวจับเวลา
/// - ตัวเลือกวิดีโอ: ปรับระดับคุณภาพวิดีโอ (Auto / HD / Full HD)
/// - ข้อมูลเวอร์ชันแอป
struct SettingsView: View {
    @AppStorage(SettingsKey.muteOnJoin) private var muteOnJoin = false
    @AppStorage(SettingsKey.cameraOffOnJoin) private var cameraOffOnJoin = false
    @AppStorage(SettingsKey.showMeetingTimer) private var showMeetingTimer = true
    @AppStorage(SettingsKey.notifications) private var notifications = true
    @AppStorage(SettingsKey.videoQuality) private var videoQuality = VideoQuality.hd.rawValue

    var body: some View {
        List {
            // หมวดการประชุม
            Section {
                Toggle("ปิดไมโครโฟนอัตโนมัติเมื่อเข้าห้อง", isOn: $muteOnJoin)
                Toggle("ปิดกล้องอัตโนมัติเมื่อเข้าห้อง", isOn: $cameraOffOnJoin)
                Toggle("แสดงตัวจับเวลาในการประชุม", isOn: $showMeetingTimer)
            } header: {
                Text("การประชุม")
            } footer: {
                Text("การตั้งค่าเหล่านี้จะมีผลทุกครั้งที่คุณเข้าร่วมหรือเริ่มการประชุมใหม่")
            }

            // หมวดวิดีโอ
            Section {
                Picker("คุณภาพวิดีโอ", selection: $videoQuality) {
                    ForEach(VideoQuality.allCases) { quality in
                        Text(quality.label).tag(quality.rawValue)
                    }
                }
            } header: {
                Text("คุณภาพวิดีโอ")
            } footer: {
                Text("การเลือก Full HD อาจใช้ปริมาณอินเทอร์เน็ตมากขึ้น")
            }

            // หมวดการแจ้งเตือน
            Section {
                Toggle("การแจ้งเตือนเตือนประชุม", isOn: $notifications)
            } header: {
                Text("การแจ้งเตือน")
            }

            // หมวดข้อมูลแอป
            Section {
                HStack {
                    Text("เวอร์ชัน")
                    Spacer()
                    Text("1.0.0 (Build 2026)")
                        .foregroundStyle(Theme.textSecondary)
                }

                HStack {
                    Text("นักพัฒนา")
                    Spacer()
                    Text("MeetUp Team")
                        .foregroundStyle(Theme.textSecondary)
                }

                HStack {
                    Text("นโยบายความเป็นส่วนตัว")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            } header: {
                Text("เกี่ยวกับ MeetUp")
            }
        }
        .tint(Theme.accent)
        .navigationTitle("การตั้งค่า")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
