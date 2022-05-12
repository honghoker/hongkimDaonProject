import Foundation
import Firebase
import FirebaseFirestoreSwift
import RealmSwift

struct Daon: Codable {
    let imageUrl: String
    let storageUser: [String: Int64]
    let uploadTime: Int64
}
