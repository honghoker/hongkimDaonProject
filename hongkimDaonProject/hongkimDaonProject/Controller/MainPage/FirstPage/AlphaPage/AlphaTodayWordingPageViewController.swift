import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Kingfisher
import RealmSwift
import Toast_Swift
import MobileCoreServices
import FirebaseDynamicLinks

class AlphaTodayWordingPageViewController: UIViewController {
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var backgroundUIView: UIView!
    var realm: Realm!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    // MARK: set UI
    func setUI() {
        let imageClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapImage(_:)))
        backgroundUIView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        backgroundUIView.isUserInteractionEnabled = true
        backgroundUIView.addGestureRecognizer(imageClick)
        imageView.image = UIImage(named: "testPage")
        // MARK: 성훈 위에 주석하고 밑에 작업
        //        let imageClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapImage(_:)))
        //        backgroundUIView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        //        backgroundUIView.isUserInteractionEnabled = true
        //        backgroundUIView.addGestureRecognizer(imageClick)
        //        imageView.image = UIImage(data: mainImageData)
        //        saveBtn.addTarget(self, action: #selector(daonStorageSave), for: .touchUpInside)
        //        downloadBtn.addTarget(self, action: #selector(imageDownload), for: .touchUpInside)
        //        shareBtn.addTarget(self, action: #selector(shareInfo), for: .touchUpInside)
    }
}

// MARK: btns action
extension AlphaTodayWordingPageViewController {
    @objc
    func onTapImage(_ gesture: UITapGestureRecognizer) {
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "FirstMainPageContainerViewController")
        nextView.modalPresentationStyle = .fullScreen
        self.present(nextView, animated: false, completion: nil)
    }
    @objc
    func imageDownload() {
        LoadingIndicator.showLoading()
        UIImageWriteToSavedPhotosAlbum(UIImage(data: mainImageData)!, self, nil, nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            LoadingIndicator.hideLoading()
            self.backgroundUIView.makeToast("사진첩에 저장되었습니다", duration: 1.5, position: .center)
        }
    }
    @objc
    func shareInfo() {
        let link = URL(string: "https://hongkimDaonProject.page.link")
        let referralLink = DynamicLinkComponents(link: link!, domainURIPrefix: "https://hongkimDaonProject.page.link")
        // iOS 설정
        referralLink?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.green.hongkimDaonProject")
        referralLink?.iOSParameters?.minimumAppVersion = "1.0.1"
        referralLink?.iOSParameters?.appStoreID = "1440705745" // 나중에 수정하세요
        // Android 설정
        //        referralLink?.androidParameters = DynamicLinkAndroidParameters(packageName: "com.green.hongkimDaonProject")
        //        referralLink?.androidParameters?.minimumVersion = 811
        // 단축 URL 생성
        referralLink?.shorten { (shortURL, warnings, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let url: String = shortURL?.absoluteString {
                var objectsToShare = [String]()
                objectsToShare.append(url)
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                activityVC.popoverPresentationController?.sourceView = self.view
                // 공유하기 기능 중 제외할 기능이 있을 때 사용
                //        activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
                self.present(activityVC, animated: true, completion: nil)
                // SMS 전송
                //            guard MFMessageComposeViewController.canSendText() else {
                //                print("SMS services are not available")
                //                return
                //            }
                //            let composeViewController = MFMessageComposeViewController()
                //            composeViewController.messageComposeDelegate = self
                //            composeViewController.recipients = ["01033555940"]
                //            composeViewController.body = shortURL?.absoluteString ?? ""
                //            self.present(composeViewController, animated: true, completion: nil)
            }
        }
    }
    @objc
    func daonStorageSave() {
        DatabaseManager.shared.daonStorageSave(docId: "\(mainUploadTime)") { result in
            switch result {
            case .success(let success):
                print("\(success)")
            case .failure(let error):
                print("\(error)")
            }
        }
        realm = try? Realm()
        let list = realm.objects(MyStorage.self).filter("uploadTime == \(mainUploadTime)")
        if list.isEmpty == true {
            let myStorage = MyStorage()
            myStorage.uploadTime = mainUploadTime
            myStorage.imageData = mainImageData
            myStorage.storageTime = Int(Date().millisecondsSince1970)
            try? self.realm.write {
                self.realm.add(myStorage)
            }
            self.backgroundUIView.makeToast("보관함에 추가되었습니다", duration: 1.5, position: .center)
        } else {
            try? realm.write {
                realm.delete(list)
            }
            self.backgroundUIView.makeToast("보관함에서 삭제되었습니다", duration: 1.5, position: .center)
        }
    }
}
