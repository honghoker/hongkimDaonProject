import UIKit
import FirebaseStorage
import Kingfisher

class TodayWordingPageViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    private let storage = Storage.storage().reference()
    lazy var year: String = ""
    lazy var month: String = ""
    lazy var day: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
        dateFormatter.dateFormat = "yyyy"
        year = dateFormatter.string(from: now)
        dateFormatter.dateFormat = "MM"
        month = dateFormatter.string(from: now)
        dateFormatter.dateFormat = "dd"
        day = dateFormatter.string(from: now)
        //        StorageManager.shared.downloadURL(for: "today/2022/04/testPage.png") { [weak self] result in
        //            switch result {
        //            case .success(let url):
        //                var image: UIImage?
        //                DispatchQueue.global().async {
        //                    print("main dispatchqueue")
        //                    let data = try? Data(contentsOf: url)
        //                    DispatchQueue.main.async {
        //                        image = UIImage(data: data!)
        //                        self?.imageView.kf.indicatorType = .activity
        //                        self?.imageView.kf.setImage(with: url,  options: [.transition(.fade(1.2))])
        ////                        self?.imageView.image = image
        //                        self?.imageView.isUserInteractionEnabled = true
        //                    }
        //                }
        //            case .failure(let error):
        //                print("Failed to get download url:\(error)")
        //            }
        //        }
        
        //        guard let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/hongkimdaonproject.appspot.com/o/today%2F2022%2F04%2FtestPage.png?alt=media&token=7a218705-a8f1-44de-8cf1-674b141de1cc") else { return }
        let imageClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapImage(_:)))
        //        imageView.isUserInteractionEnabled = true
        //        imageView.addGestureRecognizer(imageClick)
        //        imageView.kf.indicatorType = .activity
        //        imageView.kf.setImage(with: url, options: [.transition(.fade(1.2))])
        imageView.image = UIImage(named: "testPage")
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageClick)
        // 캐시 삭제
        //                        ImageCache.default.clearMemoryCache()
        //                         ImageCache.default.clearDiskCache { print("done clearDiskCache") }
    }
}

extension TodayWordingPageViewController {
    @objc
    func onTapImage(_ gesture: UITapGestureRecognizer) {
        print("?????")
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "AlphaMainPageContainerViewController")
        nextView.modalPresentationStyle = .fullScreen
        self.present(nextView, animated: false, completion: nil)
    }
}

extension UIImageView {
    func setImage(with urlString: String) {
        ImageCache.default.retrieveImage(forKey: urlString, options: nil) { result in
            switch result {
            case .success(let value):
                if let image = value.image {
                    // 캐시가 존재하는 경우
                    self.image = image
                } else {
                    // 캐시가 존재하지 않는 경우
                    guard let url = URL(string: urlString) else { return }
                    let resource = ImageResource(downloadURL: url, cacheKey: urlString)
                    self.kf.setImage(with: resource)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
