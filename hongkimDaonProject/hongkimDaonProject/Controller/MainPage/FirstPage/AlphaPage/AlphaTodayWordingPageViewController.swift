import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Kingfisher
import RealmSwift
import Toast_Swift

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
//        imageView.kf.indicatorType = .activity
//        imageView.kf.setImage(with: URL(string: mainImageUrl))
//        saveBtn.addTarget(self, action: #selector(daonStorageSave), for: .touchUpInside)
//        downloadBtn.addTarget(self, action: #selector(imageDownload), for: .touchUpInside)
    }
    override func viewWillLayoutSubviews() {
    }
    @objc
    func imageDownload() {
        let data = try? Data(contentsOf: URL(string: mainImageUrl)!)
        // 컴플레션 처리해서 사진 다운 로딩 구현하기 -> 로딩 끝나면 토스트 띄우기
        UIImageWriteToSavedPhotosAlbum(UIImage(data: data!)!, self, nil, nil)
        self.backgroundUIView.makeToast("사진첩에 저장되었습니다", duration: 1.5, position: .center)
    }
    @objc
    func daonStorageSave() {
        // MARK: 성훈 내부 db 추가 필요
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
