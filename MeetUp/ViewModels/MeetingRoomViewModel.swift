import Foundation
import Observation

/// ViewModel ควบคุมห้องประชุมแบบ Video Call สไตล์ Zoom
/// - ควบคุมสถานะไมค์ / กล้อง / การแชร์จอ / การยกมือ
/// - จำลองตัวจับเวลาการประชุม (Elapsed Timer)
/// - จำลองคนพูดในห้อง (Active Speaker Simulation)
/// - จัดการรายชื่อผู้เข้าร่วมในสาย
@Observable
@MainActor
final class MeetingRoomViewModel {
    let meeting: Meeting
    let currentUser: User

    // MARK: - Local User Call Controls
    var isMuted = false
    var isVideoOn = true
    var isScreenSharing = false
    var isHandRaised = false
    var isSpeakerOn = true

    // MARK: - Meeting States
    var participants: [Participant] = []
    var activeSpeakerId: UUID? = nil
    var elapsedSeconds = 0
    var unreadMessagesCount = 0

    // MARK: - Modals
    var showChatSheet = false
    var showParticipantsSheet = false
    var showLeaveConfirmation = false

    private var timerTask: Task<Void, Never>? = nil

    init(meeting: Meeting, currentUser: User) {
        self.meeting = meeting
        self.currentUser = currentUser

        // เตรียมรายชื่อผู้เข้าร่วมจาก mock
        var list = MockData.participants(for: meeting)

        // ตรวจสอบว่ามี currentUser อยู่ในรายชื่อหรือไม่ ถ้าไม่มีให้เพิ่มเข้ามา
        if !list.contains(where: { $0.user.id == currentUser.id }) {
            let selfParticipant = Participant(
                user: currentUser,
                isHost: meeting.host.id == currentUser.id,
                isMuted: isMuted,
                isVideoOn: isVideoOn,
                isHandRaised: false
            )
            list.insert(selfParticipant, at: 0)
        }
        self.participants = list

        startSession()
    }

    deinit {
        timerTask?.cancel()
    }

    // MARK: - Formatted Timer

    /// แสดงเวลาการประชุมในรูปแบบ "MM:SS" หรือ "HH:MM:SS"
    var formattedDuration: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    // MARK: - Actions

    func toggleMute() {
        isMuted.toggle()
        updateSelfParticipant { $0.isMuted = self.isMuted }
    }

    func toggleVideo() {
        isVideoOn.toggle()
        updateSelfParticipant { $0.isVideoOn = self.isVideoOn }
    }

    func toggleScreenShare() {
        isScreenSharing.toggle()
    }

    func toggleHandRaise() {
        isHandRaised.toggle()
        updateSelfParticipant { $0.isHandRaised = self.isHandRaised }
    }

    /// สั่งปิดไมค์ทุกคน (ฟังก์ชันเฉพาะ Host)
    func muteAll() {
        for index in participants.indices {
            // ปิดไมค์ทุกคนยกเว้นตัวเอง
            if participants[index].user.id != currentUser.id {
                participants[index].isMuted = true
            }
        }
    }

    /// อัปเดตข้อมูลของผู้ใช้ปัจจุบันในรายชื่อผู้เข้าร่วม
    private func updateSelfParticipant(_ update: (inout Participant) -> Void) {
        if let index = participants.firstIndex(where: { $0.user.id == currentUser.id }) {
            update(&participants[index])
        }
    }

    // MARK: - Background Simulation

    /// เริ่มจับเวลาและจำลองคนพูดในห้อง
    func startSession() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self else { return }

                self.elapsedSeconds += 1

                // ทุก 5 วินาที สลับจำลองคนที่กำลังพูด
                if self.elapsedSeconds % 5 == 0 {
                    self.simulateSpeakerChange()
                }
            }
        }
    }

    func stopSession() {
        timerTask?.cancel()
        timerTask = nil
    }

    /// สุ่มเลือกคนที่ไม่ได้ปิดไมค์ ให้ขึ้นกรอบเขียวพูด
    private func simulateSpeakerChange() {
        let unmuted = participants.filter { !$0.isMuted }
        if !unmuted.isEmpty {
            let nextSpeaker = unmuted.randomElement()
            activeSpeakerId = nextSpeaker?.id
        } else {
            activeSpeakerId = nil
        }
    }
}
