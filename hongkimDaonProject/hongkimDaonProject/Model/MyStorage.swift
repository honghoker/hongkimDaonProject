import Foundation
import RealmSwift

class MyStorage: Object {
    @objc dynamic var uploadTime = 0
    @objc dynamic var imageUrl = ""
    @objc dynamic var storageTime = 0
}
