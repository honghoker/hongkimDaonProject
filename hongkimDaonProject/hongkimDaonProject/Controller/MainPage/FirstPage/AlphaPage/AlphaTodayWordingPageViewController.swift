import UIKit
import SnapKit
import FirebaseStorage

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
    }
    override func viewWillLayoutSubviews() {
        shareBtn.titleLabel?.text = ""
        saveBtn.titleLabel?.text = ""
        downloadBtn.titleLabel?.text = ""
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
