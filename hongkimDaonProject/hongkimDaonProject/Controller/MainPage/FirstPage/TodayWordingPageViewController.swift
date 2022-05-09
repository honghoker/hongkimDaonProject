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
        //        let addImageFile: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addImage(_:)))
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
}
