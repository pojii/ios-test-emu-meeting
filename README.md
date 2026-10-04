# MeetUp - iOS Video Calling App (SwiftUI & iOS 17+)

**MeetUp** เป็นแอปพลิเคชัน Video Call สไตล์ Zoom พัฒนาด้วย **SwiftUI บน iOS 17 ขึ้นไป** โดยไม่ใช้ Library ภายนอก (Zero Dependencies) ออกแบบด้วยสถาปัตยกรรม **MVVM (Model-View-ViewModel)** พร้อมระบบนำทางด้วย `NavigationStack` และ `@Observable`

พร้อมติดตั้งระบบ **CI/CD Build `.ipa` อัตโนมัติและส่งตรงไปยัง BrowserStack App Live** ผ่าน GitHub Actions

---

## 📱 ฟีเจอร์หลัก (Key Features)

- **หน้าเข้าสู่ระบบ & ลงทะเบียน (Login & Sign Up)**: มีปุ่ม *“ใช้บัญชีทดลอง (Somchai Jaidee)”* สำหรับกดทดสอบฟังก์ชันทั้งหมดได้ใน 1 วินาที
- **หน้าหลัก (Home Dashboard)**: รวม 4 ปุ่มลัดสไตล์ Zoom (เริ่มประชุมทันที, เข้าร่วม, นัดหมาย, แชร์หน้าจอ) พร้อมรายการประชุมที่มีป้ายสถานะสด (Live / Upcoming / Ended)
- **ห้องประชุม Video Call (Zoom-like Calling Screen)**:
  - วิดีโอ Grid ปรับขนาดอัตโนมัติตามจำนวนผู้เข้าร่วม
  - จำลองระบบตรวจจับคนพูด (**Active Speaker Simulation**) สลับกรอบสีเขียวล้อมรอบคนที่กำลังพูด
  - ตัวจับเวลาการประชุมแบบสด (Timer)
  - แถบเครื่องมือควบคุม: เปิด/ปิดไมค์, เปิด/ปิดกล้อง, โหมดแชร์หน้าจอ, ยกมือ (✋)
  - ปุ่มออกจากห้อง / จบการประชุมสำหรับ Host
- **แชทในห้องประชุม (In-Meeting Chat)**: ส่งข้อความ, แถบ Emoji ปฏิกิริยาด่วน (👍, ❤️, 👏, 🎉) พร้อมจำลองคนในห้องตอบกลับอัตโนมัติ
- **รายชื่อผู้เข้าร่วม (Participants)**: ดูสถานะไมค์/กล้องของแต่ละคน พร้อมปุ่ม *“ปิดไมค์ทุกคน (Mute All)”* สำหรับ Host
- **โปรไฟล์ & การตั้งค่า (Profile & Settings)**: รหัส Personal Meeting ID (PMI) พร้อมปุ่มคัดลอก และตั้งค่าการเข้าประชุมผ่าน `@AppStorage`

---

## 🎨 ธีมและโทนสีของแอป (Design System)

- **Primary**: `#1B2A4A` (สีกรมท่าเข้ม - สำหรับหัวข้อและปุ่มหลัก)
- **Accent**: `#2A9D8F` (สีเขียวอมฟ้า - สำหรับปุ่ม Action และสถานะสด)
- **Background**: `#F4F6F5` (สีพื้นหลังสว่าง สะอาดตา)
- **Danger**: `#D64545` (สีแดง - สำหรับปุ่มวางสายและปิดไมค์)
- **Call Background**: `#0F1A2E` (สีน้ำเงินมืด - สำหรับห้องประชุม)

---

## 🚀 การนำขึ้น GitHub และเชื่อมต่อกับ BrowserStack

โปรเจกต์นี้มีไฟล์ GitHub Actions Workflow อยู่ที่ `.github/workflows/browserstack.yml` ซึ่งจะ Build แอปเป็น `.ipa` บน macOS Runner ฟรีของ GitHub และอัปโหลดไปยัง **BrowserStack App Live** อัตโนมัติทุกครั้งที่ Push

### 1. นำโค้ดขึ้น GitHub Public Repository
```bash
git init
git add .
git commit -m "feat: initial MeetUp iOS 17 app"
git branch -M main
git remote add origin https://github.com/<YOUR_USERNAME>/MeetUp.git
git push -u origin main
```

### 2. ตั้งค่า BrowserStack Secrets บน GitHub
1. เข้าไปที่ [BrowserStack Account Settings](https://www.browserstack.com/) เพื่อดู `Username` และ `Access Key`
2. ไปที่ GitHub Repository ของคุณ > **Settings** > **Secrets and variables** > **Actions**
3. กด **New repository secret** และเพิ่ม 2 ค่านี้:
   - `BROWSERSTACK_USERNAME`: ชื่อผู้ใช้ BrowserStack ของคุณ
   - `BROWSERSTACK_ACCESS_KEY`: Access Key ของคุณ

### 3. เปิดทดสอบบน iPhone จริง
เมื่อ GitHub Actions ทำงานเสร็จสิ้น:
1. เข้าไปที่ [BrowserStack App Live Dashboard](https://app-live.browserstack.com/)
2. คุณจะเห็นแอป **MeetUp** ปรากฏอยู่ในหมวด **Uploaded Apps**
3. เลือกอุปกรณ์ iPhone รุ่นที่ต้องการ (เช่น iPhone 15 Pro, iPhone 14) เพื่อเริ่มทดสอบบนเครื่องจริงได้ทันที!
