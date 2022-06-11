import Foundation
import FirebaseFirestoreSwift

struct Daon: Codable {
    let imageUrl: String
    let storageUser: [String: Int64]
    let uploadTime: Int64
}
