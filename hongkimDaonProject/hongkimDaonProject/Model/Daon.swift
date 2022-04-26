import Foundation
import Firebase
import FirebaseFirestoreSwift
import RealmSwift

struct Daon: Codable, Identifiable {
    @DocumentID var id: String?
    let imageUrl: String
    let storageUser: [String: Int64]
    let uploadTime: Int64
}

class RealmDaon: Object {
    @objc dynamic var uploadTime = 0
    @objc dynamic var imageData = Data()
}

// MARK: Realm db에 test용으로 class 들어가있음
// class TodayList: Object {
//    let stringList = List<Today>() // Workaround
// }
//
// class Person: Object {
//    @objc dynamic var name = ""
//    @objc dynamic var age = 0
// }
