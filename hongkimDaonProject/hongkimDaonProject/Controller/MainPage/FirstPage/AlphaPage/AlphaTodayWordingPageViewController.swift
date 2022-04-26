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
    var uploadTime: Int = 0
    var realm: Realm!
    override func viewDidLoad() {
        super.viewDidLoad()
        //        let imageClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapImage(_:)))
        //        backgroundUIView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        //        backgroundUIView.isUserInteractionEnabled = true
        //        backgroundUIView.addGestureRecognizer(imageClick)
        //        imageView.image = UIImage(named: "testPage")
        // MARK: 성훈 위에 주석하고 밑에 작업
        let imageClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapImage(_:)))
        backgroundUIView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        backgroundUIView.isUserInteractionEnabled = true
        backgroundUIView.addGestureRecognizer(imageClick)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: URL(string: mainImageUrl))
        shareBtn.addTarget(self, action: #selector(shareInfo), for: .touchUpInside)
        saveBtn.addTarget(self, action: #selector(daonStorageSave), for: .touchUpInside)
        downloadBtn.addTarget(self, action: #selector(imageDownload), for: .touchUpInside)
    }
    override func viewWillLayoutSubviews() {
    }
    @objc
    func imageDownload() {
        LoadingIndicator.showLoading()
        let data = try? Data(contentsOf: URL(string: mainImageUrl)!)
        UIImageWriteToSavedPhotosAlbum(UIImage(data: data!)!, self, nil, nil)
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
            print("@@@@@@@@@@@@ shortURL : \(shortURL)")
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
        // 1. 터치 시 내부 db에 있으면 이미 저장된거라고 토스트 띄우기
        // 2. 터치 시 내부 db에 없으면 추가
        DatabaseManager.shared.daonStorageSave(docId: "\(uploadTime)") { result in
            switch result {
            case .success(let success):
                print("\(success)")
            case .failure(let error):
                print("\(error)")
            }
        }
        realm = try? Realm()
        let list = realm.objects(MyStorage.self).filter("imageUrl CONTAINS[cd] %@", mainImageUrl)
        if list.isEmpty == true {
            let myStorage = MyStorage()
            myStorage.uploadTime = uploadTime
            myStorage.imageUrl = mainImageUrl
            myStorage.storageTime = Int(Date().millisecondsSince1970)
            try? self.realm.write {
                self.realm.add(myStorage)
            }
            self.backgroundUIView.makeToast("보관함에 추가되었습니다", duration: 1.5, position: .center)
        } else {
            self.backgroundUIView.makeToast("이미 보관함에 있습니다", duration: 1.5, position: .center)
        }
    }
}

extension AlphaTodayWordingPageViewController {
    @objc
    func onTapImage(_ gesture: UITapGestureRecognizer) {
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "FirstMainPageContainerViewController")
        nextView.modalPresentationStyle = .fullScreen
        self.present(nextView, animated: false, completion: nil)
    }
}

// MARK: UIImage alpha (투명도)
extension UIImage {
    func withAlpha(_ value: CGFloat) -> UIImage {
        return UIGraphicsImageRenderer(size: size, format: imageRendererFormat).image { (_) in
            draw(in: CGRect(origin: .zero, size: size), blendMode: .normal, alpha: value)
        }
    }
}

// MARK: Loading
class LoadingIndicator {
    static func showLoading() {
        DispatchQueue.main.async {
            // 최상단에 있는 window 객체 획득
            guard let window = UIApplication.shared.windows.last else { return }
            let loadingIndicatorView: UIActivityIndicatorView
            if let existedView = window.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
                loadingIndicatorView = existedView
            } else {
                loadingIndicatorView = UIActivityIndicatorView(style: .large)
                // 다른 UI가 눌리지 않도록 indicatorView의 크기를 full로 할당
                loadingIndicatorView.frame = window.frame
                // 은표형한테 물어봐서 우리 어플 색깔로 변경하기
                loadingIndicatorView.color = .white
                window.addSubview(loadingIndicatorView)
            }
            loadingIndicatorView.startAnimating()
        }
    }
    static func hideLoading() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.last else { return }
            window.subviews.filter({ $0 is UIActivityIndicatorView }).forEach { $0.removeFromSuperview() }
        }
    }
}
