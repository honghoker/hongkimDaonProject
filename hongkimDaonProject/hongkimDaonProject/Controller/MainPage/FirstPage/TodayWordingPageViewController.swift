import UIKit
import FirebaseStorage
import Kingfisher
import RealmSwift
import FirebaseMessaging

public var mainImageUrl = ""
public var mainUploadTime = 0

class TodayWordingPageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
//    var realm: Realm!
    let database = DatabaseManager.shared.fireStore
    var imageUploadTime: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
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
        if mainImageUrl == "" {
            let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let nowDayString = dateFormatter.string(from: now)
            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            let nowDayDate: Date = dateFormatter.date(from: nowDayString)!
            self.database.document("daon/\(nowDayDate.millisecondsSince1970)").getDocument {snaphot, error in
                if let error = error {
                    print("DEBUG: \(error.localizedDescription)")
                    return
                }
                guard let imageUrl = snaphot?.data()?["imageUrl"] else { return }
                guard let uploadTime = snaphot?.data()?["uploadTime"] else { return }
                mainImageUrl = String(describing: imageUrl)
                mainUploadTime = Int(String(describing: uploadTime))!
                self.imageView.kf.indicatorType = .activity
                let url = URL(string: String(describing: imageUrl))
                self.imageView.kf.setImage(with: url, options: nil)
                self.imageView.isUserInteractionEnabled = true
                self.imageView.addGestureRecognizer(imageClick)
            }
        } else {
            let url = URL(string: String(describing: mainImageUrl))
            self.imageView.kf.setImage(with: url, options: nil)
            self.imageView.isUserInteractionEnabled = true
            self.imageView.addGestureRecognizer(imageClick)
        }
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
     }
}
