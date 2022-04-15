import UIKit
import SnapKit

class AlphaTodayWordingPageViewController: UIViewController {
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapImage(_:)))
        imageView.image = UIImage(named: "testPage")?.withAlpha(0.5)
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageClick)
        shareBtn.titleLabel?.text = ""
        saveBtn.titleLabel?.text = ""
        downloadBtn.titleLabel?.text = ""
    }
    override func viewWillLayoutSubviews() {
        shareBtn.titleLabel?.text = ""
        saveBtn.titleLabel?.text = ""
        downloadBtn.titleLabel?.text = ""
    }
//    override func viewDidLayoutSubviews() {
//        shareBtn.titleLabel?.text = ""
//        saveBtn.titleLabel?.text = ""
//        downloadBtn.titleLabel?.text = ""
//    }
//    override func viewDidAppear(_ animated: Bool) {
//        shareBtn.titleLabel?.text = ""
//        saveBtn.titleLabel?.text = ""
//        downloadBtn.titleLabel?.text = ""
//    }
//    override func viewDidDisappear(_ animated: Bool) {
//        shareBtn.titleLabel?.text = ""
//        saveBtn.titleLabel?.text = ""
//        downloadBtn.titleLabel?.text = ""
//    }
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
