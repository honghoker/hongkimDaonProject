import UIKit
import SnapKit
import FirebaseAuth
import FirebaseStorage
import Kingfisher
import RealmSwift
//import Toast_Swift
import MobileCoreServices

class AlphaTodayWordingPageViewController: UIViewController {
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
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
        imageView.kf.indicatorType = .activity
        let url = URL(string: String(describing: mainImageUrl))
        imageView.kf.setImage(with: url, options: nil)
        saveBtn.addTarget(self, action: #selector(daonStorageSave), for: .touchUpInside)
        downloadBtn.addTarget(self, action: #selector(imageDownload), for: .touchUpInside)
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
        let url = URL(string: String(describing: mainImageUrl))
        URLSession.shared.dataTask(with: url!) { [weak self] data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                print("network error:", error ?? "Unknown error")
                return
            }
            guard 200..<300 ~= response.statusCode else {
                print("invalid status code, expected 2xx, received", response.statusCode)
                return
            }
            guard let image = UIImage(data: data) else {
                print("Not valid image")
                return
            }
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            DispatchQueue.main.async {
                LoadingIndicator.hideLoading()
//                self?.backgroundUIView.makeToast("사진첩에 저장되었습니다", duration: 1.5, position: .center)
            }
        }.resume()
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
            myStorage.imageUrl = mainImageUrl
            myStorage.storageTime = Int(Date().millisecondsSince1970)
            try? self.realm.write {
                self.realm.add(myStorage)
            }
//            self.backgroundUIView.makeToast("보관함에 추가되었습니다", duration: 1.5, position: .center)
        } else {
            try? realm.write {
                realm.delete(list)
            }
//            self.backgroundUIView.makeToast("보관함에서 삭제되었습니다", duration: 1.5, position: .center)
        }
    }
}
