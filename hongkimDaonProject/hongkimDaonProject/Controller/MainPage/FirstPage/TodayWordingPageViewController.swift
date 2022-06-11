import UIKit
import FirebaseStorage
import Kingfisher
import RealmSwift
import FirebaseMessaging

public var mainImageUrl = ""
public var mainUploadTime = 0

class TodayWordingPageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
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
    func storeImage(_ url: String, _ uploadTime: Int64) {
        let myDaon = Daon(imageUrl: url, storageUser: [:], uploadTime: uploadTime)
        database.collection("daon").document("\(myDaon.uploadTime)").setData(["imageUrl": myDaon.imageUrl, "storageUser": myDaon.storageUser, "uploadTime": myDaon.uploadTime])
    }
}
