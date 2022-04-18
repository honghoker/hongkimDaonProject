import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import RealmSwift

class AlphaTodayWordingPageViewController: UIViewController {
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapImage(_:)))
        //        StorageManager.shared.downloadURL(for: "today/2022/04/testPage.png") { [weak self] result in
        //            switch result {
        //            case .success(let url):
        //                var image: UIImage?
        //                DispatchQueue.global().async {
        //                    print("main dispatchqueue")
        //                    let data = try? Data(contentsOf: url)
        //                    DispatchQueue.main.async {
        //                        image = UIImage(data: data!)
        //                        self?.imageView.image = image?.withAlpha(0.5)
        //                        self?.imageView.isUserInteractionEnabled = true
        //                    }
        //                }
        //            case .failure(let error):
        //                print("Failed to get download url:\(error)")
        //            }
        //        }
        imageView.image = UIImage(named: "testPage")?.withAlpha(0.5)
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageClick)
        shareBtn.addTarget(self, action: #selector(testDaonUpload), for: .touchUpInside)
        saveBtn.addTarget(self, action: #selector(daonStorageSave), for: .touchUpInside)
    }
    override func viewWillLayoutSubviews() {
        shareBtn.titleLabel?.text = ""
        saveBtn.titleLabel?.text = ""
        downloadBtn.titleLabel?.text = ""
    }
    @objc
    func testDaonUpload() {
        let nowTime = Date().millisecondsSince1970
        Firestore.firestore().collection("daon").document("\(nowTime)").setData(["imageUrl": "https://firebasestorage.googleapis.com:443/v0/b/hongkimdaonproject.appspot.com/o/diary%2F1649996407571?alt=media&token=0d53a2ef-7ae8-4b3c-aa6b-286fd1b486b3", "uploadTime": nowTime, "storageUser": [String: String]() ])
    }
    @objc
    func daonStorageSave() {
        // MARK: 성훈 내부 db 추가 필요
        // 1. 터치 시 내부 db에 있으면 이미 저장된거라고 토스트 띄우기
        // 2. 터치 시 내부 db에 없으면 추가
        DatabaseManager.shared.daonStorageSave(docId: "1650313640244") { result in
            switch result {
            case .success(let success):
                print("@@@@@@@ 저장됐다는 토스트 : \(success)")
            case .failure(let error):
                print("@@@@@@@ 저장 실패했다는 토스트 : \(error)")
            }
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
