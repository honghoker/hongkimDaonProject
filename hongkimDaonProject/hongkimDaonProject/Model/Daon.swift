import Foundation
import Firebase
import FirebaseFirestoreSwift
import RealmSwift

struct Daon {
    let imageUrl: String
    let storageUser: [String: Int64]
    let uploadTime: Int64
}

class RealmDaon: Object {
    @objc dynamic var uploadTime = 0
    @objc dynamic var imageData = Data()
    @objc dynamic var imageUrl = ""
    override static func primaryKey() -> String? {
        return "uploadTime"
    }
}

class RecentlyAccess: Object {
    @objc dynamic var accessTime = 0
    @objc dynamic var imageData = Data()
}
