import UIKit
import FirebaseStorage
import Kingfisher
import RealmSwift
import FirebaseMessaging

public var mainImageData = Data()
public var mainUploadTime = 0
public var firstEnter = true

class TodayWordingPageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var realm: Realm!
    let database = DatabaseManager.shared.fireStore
    var imageUploadTime: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapImage(_:)))
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
        if firstEnter {
            firstEnter = false
            let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let nowDayString = dateFormatter.string(from: now)
            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            let nowDayDate: Date = dateFormatter.date(from: nowDayString)!
            realm = try? Realm()
            let list = realm.objects(RecentlyAccess.self)
            if list.count == .zero {
                self.database.document("daon/\(nowDayDate.millisecondsSince1970)").getDocument {snaphot, error in
                    if let error = error {
                        print("DEBUG: \(error.localizedDescription)")
                        return
                    }
                    guard let imageUrl = snaphot?.data()?["imageUrl"] else { return }
                    let recentlyAccess = RecentlyAccess()
                    recentlyAccess.accessTime = Int(nowDayDate.millisecondsSince1970)
                    recentlyAccess.imageData = try! Data(contentsOf: URL(string: String(describing: imageUrl))!)
                    mainImageData = recentlyAccess.imageData
                    mainUploadTime = recentlyAccess.accessTime
                    self.setImageView(data: recentlyAccess.imageData, imageClick: imageClick)
                    try? self.realm.write {
                        self.realm.add(recentlyAccess)
                    }
                }
            } else {
                guard let accessTime = list.last?.accessTime else { return }
                // 최근 접속기록이 오늘 날짜랑 달라서 db 삭제 후 다운
                if accessTime != nowDayDate.millisecondsSince1970 {
                    self.database.document("daon/\(nowDayDate.millisecondsSince1970)").getDocument {snaphot, error in
                        if let error = error {
                            print("DEBUG: \(error.localizedDescription)")
                            return
                        }
                        guard let imageUrl = snaphot?.data()?["imageUrl"] else { return }
                        let lastAccessList = self.realm.objects(RecentlyAccess.self).last
                        try? self.realm.write {
                            self.realm.delete(lastAccessList!)
                        }
                        let recentlyAccess = RecentlyAccess()
                        recentlyAccess.accessTime = Int(nowDayDate.millisecondsSince1970)
                        recentlyAccess.imageData = try! Data(contentsOf: URL(string: String(describing: imageUrl))!)
                        mainImageData = recentlyAccess.imageData
                        mainUploadTime = recentlyAccess.accessTime
                        self.setImageView(data: recentlyAccess.imageData, imageClick: imageClick)
                        try? self.realm.write {
                            self.realm.add(recentlyAccess)
                        }
                    }
                } else {
                    // 최근 접속기록이 오늘 날짜랑 같음
                    guard let realmImageData = list.last?.imageData else {return}
                    mainImageData = realmImageData
                    mainUploadTime = accessTime
                    self.setImageView(data: realmImageData, imageClick: imageClick)
                }
            }
        } else {
            // 처음 접속 x -> tableView에서 다른 daon 클릭 시
            self.setImageView(data: mainImageData, imageClick: imageClick)
        }
    }
    override func viewWillLayoutSubviews() {
        if mainImageData.isEmpty {
            LoadingIndicator.showLoading()
        }
    }
    override func viewDidLayoutSubviews() {
        if !mainImageData.isEmpty {
            LoadingIndicator.hideLoading()
        }
    }
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
    // MARK: addImage
     @objc
     func addImage(_ gesture: UITapGestureRecognizer) {
         let myDaon1 = Daon(imageUrl: "https://firebasestorage.googleapis.com/v0/b/hongkimdaonproject.appspot.com/o/today%2F2022%2F04%2F1651104000000.jpg?alt=media&token=53edc93b-8898-4501-80e1-84ef29610e97", storageUser: [:], uploadTime: 1651104000000)
         database.collection("daon").document("\(myDaon1.uploadTime)").setData(["imageUrl": myDaon1.imageUrl, "storageUser": myDaon1.storageUser, "uploadTime": myDaon1.uploadTime])
         let myDaon2 = Daon(imageUrl: "https://firebasestorage.googleapis.com/v0/b/hongkimdaonproject.appspot.com/o/today%2F2022%2F04%2F1651190400000.jpg?alt=media&token=758490a6-f6f1-4c65-ab5d-99781a5f41b8", storageUser: [:], uploadTime: 1651190400000)
         database.collection("daon").document("\(myDaon2.uploadTime)").setData(["imageUrl": myDaon2.imageUrl, "storageUser": myDaon2.storageUser, "uploadTime": myDaon2.uploadTime])
         let myDaon3 = Daon(imageUrl: "https://firebasestorage.googleapis.com/v0/b/hongkimdaonproject.appspot.com/o/today%2F2022%2F04%2F1651276800000.jpg?alt=media&token=a9492ac9-7aae-4782-903f-eefaed6a66c2", storageUser: [:], uploadTime: 1651276800000)
         database.collection("daon").document("\(myDaon3.uploadTime)").setData(["imageUrl": myDaon3.imageUrl, "storageUser": myDaon3.storageUser, "uploadTime": myDaon3.uploadTime])
         let myDaon4 = Daon(imageUrl: "https://firebasestorage.googleapis.com/v0/b/hongkimdaonproject.appspot.com/o/today%2F2022%2F04%2F1651363200000.jpg?alt=media&token=6d38073b-dc52-4255-a705-287f8716aa55", storageUser: [:], uploadTime: 1651363200000)
         database.collection("daon").document("\(myDaon4.uploadTime)").setData(["imageUrl": myDaon4.imageUrl, "storageUser": myDaon4.storageUser, "uploadTime": myDaon4.uploadTime])
         let myDaon5 = Daon(imageUrl: "https://firebasestorage.googleapis.com/v0/b/hongkimdaonproject.appspot.com/o/today%2F2022%2F04%2F1651449600000.jpg?alt=media&token=a45ae73f-a0f3-4a25-8539-e104ccb9efd1", storageUser: [:], uploadTime: 1651449600000)
         database.collection("daon").document("\(myDaon5.uploadTime)").setData(["imageUrl": myDaon5.imageUrl, "storageUser": myDaon5.storageUser, "uploadTime": myDaon5.uploadTime])
         let myDaon6 = Daon(imageUrl: "https://firebasestorage.googleapis.com/v0/b/hongkimdaonproject.appspot.com/o/today%2F2022%2F05%2F1651536000000.jpg?alt=media&token=0a6f1696-4d9c-4f6b-8f98-e186ed187f04", storageUser: [:], uploadTime: 1651536000000)
         database.collection("daon").document("\(myDaon6.uploadTime)").setData(["imageUrl": myDaon6.imageUrl, "storageUser": myDaon6.storageUser, "uploadTime": myDaon6.uploadTime])
         let myDaon7 = Daon(imageUrl: "https://firebasestorage.googleapis.com/v0/b/hongkimdaonproject.appspot.com/o/today%2F2022%2F05%2F1651622400000.jpg?alt=media&token=01c77df6-ebeb-4709-b289-56670dead0d5", storageUser: [:], uploadTime: 1651622400000)
         database.collection("daon").document("\(myDaon7.uploadTime)").setData(["imageUrl": myDaon7.imageUrl, "storageUser": myDaon7.storageUser, "uploadTime": myDaon7.uploadTime])
         let myDaon8 = Daon(imageUrl: "https://firebasestorage.googleapis.com/v0/b/hongkimdaonproject.appspot.com/o/today%2F2022%2F05%2F1651708800000.jpg?alt=media&token=65fc9bf8-93f8-4afe-a45f-09aedfb1b7bd", storageUser: [:], uploadTime: 1651708800000)
         database.collection("daon").document("\(myDaon8.uploadTime)").setData(["imageUrl": myDaon8.imageUrl, "storageUser": myDaon8.storageUser, "uploadTime": myDaon8.uploadTime])
         let myDaon9 = Daon(imageUrl: "https://firebasestorage.googleapis.com/v0/b/hongkimdaonproject.appspot.com/o/today%2F2022%2F05%2F1651795200000.jpg?alt=media&token=760f4cc3-117c-41e3-9c9b-3bc786ed474a", storageUser: [:], uploadTime: 1651795200000)
         database.collection("daon").document("\(myDaon9.uploadTime)").setData(["imageUrl": myDaon9.imageUrl, "storageUser": myDaon9.storageUser, "uploadTime": myDaon9.uploadTime])
         let myDaon10 = Daon(imageUrl: "https://firebasestorage.googleapis.com/v0/b/hongkimdaonproject.appspot.com/o/today%2F2022%2F05%2F1651881600000.jpg?alt=media&token=bbb829eb-df5a-4617-a9dd-cbd573a8a5e8", storageUser: [:], uploadTime: 1651881600000)
         database.collection("daon").document("\(myDaon10.uploadTime)").setData(["imageUrl": myDaon10.imageUrl, "storageUser": myDaon10.storageUser, "uploadTime": myDaon10.uploadTime])
         let myDaon11 = Daon(imageUrl: "https://firebasestorage.googleapis.com/v0/b/hongkimdaonproject.appspot.com/o/today%2F2022%2F05%2F1651968000000.jpg?alt=media&token=f4222a05-40f8-4b95-aa1f-c3421d19635a", storageUser: [:], uploadTime: 1651968000000)
         database.collection("daon").document("\(myDaon11.uploadTime)").setData(["imageUrl": myDaon11.imageUrl, "storageUser": myDaon11.storageUser, "uploadTime": myDaon11.uploadTime])
         let myDaon12 = Daon(imageUrl: "https://firebasestorage.googleapis.com/v0/b/hongkimdaonproject.appspot.com/o/today%2F2022%2F05%2F1652140800000.jpg?alt=media&token=39288269-9dd2-40cf-9cec-4ed85bb733b8", storageUser: [:], uploadTime: 1652140800000)
         database.collection("daon").document("\(myDaon12.uploadTime)").setData(["imageUrl": myDaon12.imageUrl, "storageUser": myDaon12.storageUser, "uploadTime": myDaon12.uploadTime])
         let myDaon13 = Daon(imageUrl: "https://firebasestorage.googleapis.com/v0/b/hongkimdaonproject.appspot.com/o/today%2F2022%2F05%2F1652054400000.jpg?alt=media&token=114ffb84-2813-485f-9c1b-ff80f9359e97", storageUser: [:], uploadTime: 1652054400000)
         database.collection("daon").document("\(myDaon13.uploadTime)").setData(["imageUrl": myDaon13.imageUrl, "storageUser": myDaon13.storageUser, "uploadTime": myDaon13.uploadTime])
//         let myDaon14 = Daon(imageUrl: "", storageUser: [:], uploadTime: 0)
//         database.collection("daon").document("\(myDaon14.uploadTime)").setData(["imageUrl": myDaon14.imageUrl, "storageUser": myDaon14.storageUser, "uploadTime": myDaon14.uploadTime])
//         let myDaon15 = Daon(imageUrl: "", storageUser: [:], uploadTime: 0)
//         database.collection("daon").document("\(myDaon15.uploadTime)").setData(["imageUrl": myDaon15.imageUrl, "storageUser": myDaon15.storageUser, "uploadTime": myDaon15.uploadTime])
     }
}
