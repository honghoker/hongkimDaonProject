import Foundation
import RealmSwift

class Today: Object {
    @objc dynamic var id = 0
    @objc dynamic var url = ""
//    let dataList: List<String> = List<String>()
//    var dataArray: [String] {
//        get {
//            return dataList.map{$0}
//        }
//        set {
//            dataList.removeAll()
//            dataList.append(objectsIn: )
//        }
//    }
    
}

class TodayList: Object {
    let stringList = List<Today>() // Workaround
}
