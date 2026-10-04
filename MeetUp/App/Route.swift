import SwiftUI

/// รายชื่อทุกหน้าในแอป ใช้กับ NavigationStack(path:)
/// หน้าที่ต้องรู้ว่าเป็นการประชุมไหนจะส่ง Meeting ติดไปด้วย
enum Route: Hashable {
    case login
    case signUp
    case home
    case joinMeeting
    case scheduleMeeting
    case meetingDetail(Meeting)
    case meetingRoom(Meeting)
    case chat(Meeting)
    case participants(Meeting)
    case profile
    case settings
}

extension Route {
    /// แปลง Route เป็นหน้าจอจริง (เรียกจาก navigationDestination ใน RootView)
    /// currentUser มาจาก SessionStore เพื่อให้หน้าประชุมรู้ว่า "เรา" คือใคร
    @MainActor @ViewBuilder
    func destination(currentUser: User) -> some View {
        switch self {
        case .login:
            LoginView()
        case .signUp:
            SignUpView()
        case .home:
            HomeView()
        case .joinMeeting:
            JoinMeetingView()
        case .scheduleMeeting:
            ScheduleMeetingView()
        case .meetingDetail(let meeting):
            MeetingDetailView(meeting: meeting)
        case .meetingRoom(let meeting):
            MeetingRoomView(meeting: meeting, currentUser: currentUser)
        case .chat(let meeting):
            ChatView(meeting: meeting, currentUser: currentUser)
        case .participants(let meeting):
            ParticipantsView(meeting: meeting, currentUser: currentUser)
        case .profile:
            ProfileView()
        case .settings:
            SettingsView()
        }
    }
}
