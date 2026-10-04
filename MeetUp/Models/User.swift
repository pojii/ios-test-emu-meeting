import Foundation

/// ผู้ใช้ในระบบ
struct User: Identifiable, Hashable {
    let id: UUID
    var name: String
    var email: String
    var jobTitle: String

    init(id: UUID = UUID(), name: String, email: String, jobTitle: String = "") {
        self.id = id
        self.name = name
        self.email = email
        self.jobTitle = jobTitle
    }

    /// ชื่อแรก ใช้ทักทายในหน้า Home
    var firstName: String {
        name.split(separator: " ").first.map { String($0) } ?? name
    }
}
