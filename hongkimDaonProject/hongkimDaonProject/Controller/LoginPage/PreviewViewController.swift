import UIKit
import Kingfisher

class PreviewViewController: UIViewController {
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(.init(systemName: "chevron.backward"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.kf.indicatorType = .activity
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addView()
        setLayout()
        setupView()
        fetchLatestImage()
    }
    
    private func addView() {
        [
            imageView,
            backButton
        ].forEach {
            view.addSubview($0)
        }
    }
    
    private func setLayout() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        backButton.snp.makeConstraints {
            $0.top.left.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    
    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func fetchLatestImage() {
        guard let currentDate = getTodaysDateInKoreanTimeZone() else { return }
        
        fetchImageUrl(date: currentDate) { [weak self] imageUrl in
            self?.setImage(urlString: imageUrl)
        }
    }
    
    private func getTodaysDateInKoreanTimeZone() -> Date? {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        let nowDayString = formatter.string(from: now)
        
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.date(from: nowDayString)
    }
    
    private func fetchImageUrl(
        date: Date,
        completion: @escaping (String) -> ()
    ) {
        DatabaseManager.shared.fireStore
            .collection("daon")
            .whereField(
                "uploadTime",
                isLessThan: date.millisecondsSince1970 + DaonConstants.dayMilliSecond
            )
            .order(by: "uploadTime", descending: true)
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                if let error {
                    self?.showToast(message: error.localizedDescription)
                    return
                }
                
                guard let imageUrl = snapshot?.documents[0].get("imageUrl") as? String else {
                    self?.showToast(message: "")
                    return
                }
                
                completion(imageUrl)
            }
    }
    
    private func setImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let processor = ResizingImageProcessor(referenceSize: view.frame.size)
        self.imageView.kf.setImage(with: url, options: [.processor(processor)])
    }
    
    private func showToast(message: String) {
        // TODO: Show Error Toast
        debugPrint(message)
    }
    
    @objc
    private func didTapBackButton() {
        presentingViewController?.dismiss(animated: true)
    }
}
