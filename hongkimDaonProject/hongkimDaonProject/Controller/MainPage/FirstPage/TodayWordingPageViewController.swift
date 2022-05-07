import UIKit
import FirebaseStorage
import Kingfisher
import RealmSwift
import FirebaseMessaging

public var mainImageData = Data()
public var mainUploadTime = 0

class TodayWordingPageViewController: UIViewController {
    var realm: Realm!
    let database = DatabaseManager.shared.fireStore
    var imageUploadTime: Int = 0
    @IBOutlet weak var imageView: UIImageView!
    private let storage = Storage.storage().reference()
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: realm db 삭제
        //        try! FileManager.default.removeItem(at:Realm.Configuration.defaultConfiguration.fileURL!)
        //        print(Realm.Configuration.defaultConfiguration.fileURL!)
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                if let user = AuthManager.shared.auth.currentUser {
                    self.database.document("user/\(user.uid)").getDocument {snaphot, error in
                        if let error = error {
                            print("DEBUG: \(error.localizedDescription)")
                            return
                        }
                        guard let userFcmToken = snaphot?.data()?["fcmToken"] else { return }
                        print("user Token \(userFcmToken)")
                        if String(describing: userFcmToken) != token {
                            self.database.document("user/\(user.uid)").updateData(["fcmToken": token])
                        }
                    }
                } else {
                    self.view.makeToast("네트워크 연결을 확인해주세요.", duration: 1.5, position: .bottom)
                }
                print("FCM registration token: \(token)")
            }
        }
        let imageClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapImage(_:)))
        imageView.image = UIImage(named: "testPage")
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageClick)
        // MARK: custom DayDate mil
        //        let dateString:String = "2022-05"
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "yyyy-MM"
        //        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        //        let date:Date = dateFormatter.date(from: dateString)!
        //        print("before date String \(date)")
        //        print("after date String \(date.adding(.month, value: 1))")
        // MARK: nowDayDate mil
        //        let now = Date()
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
        //        dateFormatter.dateFormat = "yyyy-MM-dd"
        //        let nowDayString = dateFormatter.string(from: now)
        //        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        //        let nowDayDate: Date = dateFormatter.date(from: nowDayString)!
        //        print("nowDayDate \(nowDayDate)")
        //        print("nowDayDate mil \(nowDayDate.millisecondsSince1970)")
        // MARK: 성훈 위에 주석하고 밑에 작업
        //                let imageClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapImage(_:)))
        //                let beforeImageData = mainImageData
        //                let beforeUploadTime = mainUploadTime
        //                todayImageCacheSet {imageData, uploadTime in
        //                    if beforeImageData.isEmpty {
        //                        mainImageData = imageData
        //                        mainUploadTime = uploadTime
        //                        self.setImageView(data: mainImageData, imageClick: imageClick)
        //                    } else {
        //                        mainImageData = beforeImageData
        //                        mainUploadTime = beforeUploadTime
        //                        self.setImageView(data: mainImageData, imageClick: imageClick)
        //                    }
        //                    print("call LoadingIndicator")
        //                    LoadingIndicator.hideLoading()
        //                }
    }
    override func viewWillLayoutSubviews() {
        print("sunghun viewWillLayoutSubviews")
        //        if mainImageData.isEmpty {
        //            LoadingIndicator.showLoading()
        //        }
    }
    override func viewDidLayoutSubviews() {
        print("sunghun viewDidLayoutSubviews")
        //        if !mainImageData.isEmpty {
        //            LoadingIndicator.hideLoading()
        //        }
    }
}

extension TodayWordingPageViewController {
    func todayImageCacheSet(completion: @escaping (Data, Int) -> Void) {
        // 내부 db today null check
        // empty -> 해당 월 url 다 가져오기
        // isEmpty -> 최근에 받은 url id랑 비교해서 월 변경됐는지 확인
        // 변경됐으면 변경된 월 1일 ~ 오늘까지 다운
        // 변경안됐으면 최근에 받은 일 ~ 오늘까지 다운
        // MARK: month debug
        //        let mayDayDateString:String = "2022-05-01"
        //        let mayDateString:String = "2022-05"
        //        let mayDateFormatter = DateFormatter()
        //        mayDateFormatter.dateFormat = "yyyy-MM"
        //        mayDateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        //        let mayDate:Date = mayDateFormatter.date(from: mayDateString)!
        realm = try? Realm()
        var daonUploadTime  = 0
        let list = realm.objects(RealmDaon.self)
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
        dateFormatter.dateFormat = "yyyy-MM"
        let nowMonthString = dateFormatter.string(from: now)
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let nowMonthDate: Date = dateFormatter.date(from: nowMonthString)!
        dateFormatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let nowDayString = dateFormatter.string(from: now)
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let nowDayDate: Date = dateFormatter.date(from: nowDayString)!
        if list.count == .zero {
            // empty
            // store 접근 -> date.millisecondsSince1970 이거보다 큰 것들 다 가져와서 db 저장
            self.database.collection("daon").whereField("uploadTime", isGreaterThanOrEqualTo: Int(nowMonthDate.millisecondsSince1970)).whereField("uploadTime", isLessThan: Int(nowMonthDate.adding(.month, value: 1).millisecondsSince1970)).getDocuments { (snapshot, error) in
                if error != nil {
                    print("Error getting documents: \(String(describing: error))")
                } else {
                    for document in (snapshot?.documents)! {
                        guard let uploadTime = document.data()["uploadTime"] else { return }
                        guard let imageUrl = document.data()["imageUrl"] else { return }
                        let daon = RealmDaon()
                        daon.uploadTime = Int(String(describing: uploadTime)) ?? 0
                        daon.imageData = try! Data(contentsOf: URL(string: String(describing: imageUrl))!)
                        try? self.realm.write {
                            self.realm.add(daon)
                        }
                        mainImageData = daon.imageData
                        daonUploadTime = daon.uploadTime
                    }
                    completion(mainImageData, daonUploadTime)
                }
            }
        } else {
            // realm 접근 -> 최근에 받은 url id 확인해서 월 바꼈는지 확인
            guard let realmImageId = list.last?.uploadTime else { return }
            guard let realmImageData = list.last?.imageData else { return }
            let realmMonthDate = Date(timeIntervalSince1970: (Double(Int(realmImageId)) / 1000.0))
            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            dateFormatter.dateFormat = "yyyy-MM"
            let realmMonthString = dateFormatter.string(from: realmMonthDate)
            if nowMonthString.suffix(2) != realmMonthString.suffix(2) {
                try? realm.write {
                    realm.deleteAll()
                }
                self.database.collection("daon").whereField("uploadTime", isGreaterThanOrEqualTo: Int(nowMonthDate.millisecondsSince1970)).whereField("uploadTime", isLessThan: Int(nowMonthDate.adding(.month, value: 1).millisecondsSince1970)).getDocuments { [self] (snapshot, error) in
                    if error != nil {
                        print("Error getting documents: \(String(describing: error))")
                    } else {
                        for document in (snapshot?.documents)! {
                            guard let uploadTime = document.data()["uploadTime"] else { return }
                            guard let imageUrl = document.data()["imageUrl"] else { return }
                            let daon = RealmDaon()
                            daon.imageData = try! Data(contentsOf: URL(string: String(describing: imageUrl))!)
                            daon.uploadTime = Int(String(describing: uploadTime)) ?? 0
                            try? self.realm.write {
                                self.realm.add(daon)
                            }
                            mainImageData = daon.imageData
                            daonUploadTime = daon.uploadTime
                        }
                        completion(mainImageData, daonUploadTime)
                    }
                }
            } else {
                if nowDayString.suffix(2) == "01" {
                    // if nowString == 마지막 날짜 -> 이미 접속했다 -> 다운 x
                    // else -> 월이 바뀌고 첫 접속이다 -> realm 전체 delete -> 다운 해야함
                    if realmImageId == nowMonthDate.millisecondsSince1970 {
                        mainImageData = realmImageData
                        completion(mainImageData, realmImageId)
                    } else {
                        try? realm.write {
                            realm.deleteAll()
                        }
                        self.database.collection("daon").whereField("uploadTime", isGreaterThanOrEqualTo: Int(nowMonthDate.millisecondsSince1970)).whereField("uploadTime", isLessThan: Int(nowMonthDate.adding(.month, value: 1).millisecondsSince1970)).getDocuments { (snapshot, error) in
                            if error != nil {
                                print("Error getting documents: \(String(describing: error))")
                            } else {
                                for document in (snapshot?.documents)! {
                                    guard let uploadTime = document.data()["uploadTime"] else { return }
                                    guard let imageUrl = document.data()["imageUrl"] else { return }
                                    let daon = RealmDaon()
                                    daon.imageData = try! Data(contentsOf: URL(string: String(describing: imageUrl))!)
                                    daon.uploadTime = Int(String(describing: uploadTime)) ?? 0
                                    try? self.realm.write {
                                        self.realm.add(daon)
                                    }
                                    mainImageData = daon.imageData
                                    daonUploadTime = daon.uploadTime
                                }
                                completion(mainImageData, daonUploadTime)
                            }
                        }
                    }
                } else {
                    // if nowString == 마지막 날짜 -> 이미 접속했다 -> 다운 x
                    if realmImageId == nowDayDate.millisecondsSince1970 {
                        mainImageData = realmImageData
                        completion(mainImageData, realmImageId)
                    } else {
                        // else -> 다운 해야함
                        self.database.collection("daon").whereField("uploadTime", isGreaterThan: Int(realmMonthDate.millisecondsSince1970)).whereField("uploadTime", isLessThan: Int(nowMonthDate.adding(.month, value: 1).millisecondsSince1970)).getDocuments { (snapshot, error) in
                            if error != nil {
                                print("Error getting documents: \(String(describing: error))")
                            } else {
                                for document in (snapshot?.documents)! {
                                    guard let uploadTime = document.data()["uploadTime"] else { return }
                                    guard let imageUrl = document.data()["imageUrl"] else { return }
                                    let daon = RealmDaon()
                                    daon.imageData = try! Data(contentsOf: URL(string: String(describing: imageUrl))!)
                                    daon.uploadTime = Int(String(describing: uploadTime)) ?? 0
                                    try? self.realm.write {
                                        self.realm.add(daon)
                                    }
                                    mainImageData = daon.imageData
                                    daonUploadTime = daon.uploadTime
                                }
                                completion(mainImageData, daonUploadTime)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension TodayWordingPageViewController {
    func setImageView(data: Data, imageClick: UITapGestureRecognizer) {
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(imageClick)
        self.imageView.image = UIImage(data: data)
    }
}

extension TodayWordingPageViewController {
    @objc
    func onTapImage(_ gesture: UITapGestureRecognizer) {
        guard let nextView = self.storyboard?.instantiateViewController(identifier: "AlphaMainPageViewController") as? AlphaMainPageViewController else {
            return
        }
        nextView.modalPresentationStyle = .fullScreen
        self.present(nextView, animated: false, completion: nil)
    }
}
