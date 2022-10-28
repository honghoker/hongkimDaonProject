import UIKit
import SnapKit
import Kingfisher
import Toast_Swift

class DetailDiaryPageViewController: UIViewController {
    var docId: String?
    var diary: Diary?
    weak var delegate: DispatchDiary?
    var imageLoadComplete: Bool = false
    var scrolldirection: Bool = false
    lazy var toolBar: UIToolbar = {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
        toolBar.setBackgroundImage(UIImage(),
                                   forToolbarPosition: UIBarPosition.any,
                                   barMetrics: UIBarMetrics.default)
        toolBar.setShadowImage(UIImage(),
                               forToolbarPosition: UIBarPosition.any)
        toolBar.tintColor = .systemGray
        toolBar.clipsToBounds = true
        let toolbarEditItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(tabEditBtn))
        let toolbarRemoveItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(tabRemoveBtn))
        toolBar.setItems([.flexibleSpace(), toolbarEditItem, toolbarRemoveItem], animated: true)
        return toolBar
    }()
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    lazy var backBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    lazy var contentView: UIView = {
        let contentView = UIView()
        return contentView
    }()
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    lazy var writeTimeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        label.textColor = .systemGray
        return label
    }()
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        label.textColor = .label
        label.lineBreakStrategy = .hangulWordPriority
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        addView()
        setLayout()
        setDelegate()
        configureVC()
        configureEvent()
        getDiary()
    }
    func addView() {
        view.addSubview(backBtn)
        view.addSubview(scrollView)
        view.addSubview(toolBar)
        scrollView.addSubview(contentView)
        contentView.addSubview(writeTimeLabel)
        contentView.addSubview(imageView)
        contentView.addSubview(contentLabel)
    }
    func setLayout() {
        backBtn.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        toolBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        scrollView.snp.makeConstraints {
            $0.top.equalTo(backBtn.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        contentView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
            $0.width.equalToSuperview()
        }
        writeTimeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        imageView.snp.makeConstraints {
            $0.top.equalTo(writeTimeLabel.snp.bottom).offset(0)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
        }
    }
    func setDelegate() {
        self.scrollView.delegate = self
    }
    func configureVC() {
        view.backgroundColor = UIColor(named: "bgColor")
    }
    func configureEvent() {
        self.backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
    }
    // MARK: - millisecondes -> "# 년.월.일" 형식으로 표시
    func getWriteTimeConvertToDate(_ time: Int64) -> String {
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "# yyyy.MM.dd"
        myDateFormatter.locale = Locale(identifier: "ko_KR")
        let convertNowStr = myDateFormatter.string(from: Date(milliseconds: time))
        return convertNowStr
    }
    // MARK: - label 행간 조절
    func getLabelLineSpacingAttributed(_ str: String, _ spacing: CGFloat) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: str)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
        return attrString
    }
    // MARK: Firestore diary data 가져오기
    func getDiary() {
        DatabaseManager.shared.fireStore.collection("diary").document(docId!).addSnapshotListener { [weak self] documentSnapshot, error in
            guard let document = documentSnapshot else {
                return
            }
            guard document.data() != nil else {
                return
            }
            guard let diary: Diary = try? document.data(as: Diary.self) else {
                return
            }
            self?.diary = diary
            self?.writeTimeLabel.text = self?.getWriteTimeConvertToDate(diary.writeTime)
            self?.contentLabel.attributedText = self?.getLabelLineSpacingAttributed(diary.content, 10.0)
            
            if diary.imageExist == false {
                self?.imageLoadComplete = true
                guard let self else { return }
                self.imageView.snp.remakeConstraints {
                    $0.top.equalTo(self.writeTimeLabel.snp.bottom).offset(0)
                    $0.leading.trailing.equalToSuperview()
                    $0.height.equalTo(0)
                }
            } else {
                let ratio = diary.imageHeight / diary.imageWidth
                guard let width = self?.view.frame.width else { return }
                let height = width * ratio
                if let self {
                    self.imageView.snp.remakeConstraints {
                        $0.top.equalTo(self.writeTimeLabel.snp.bottom).offset(32)
                        $0.leading.trailing.equalToSuperview()
                        $0.height.equalTo(height)
                    }
                } else { return }
                
                // MARK: 이미지 다운샘플링
                let processor = DownsamplingImageProcessor(size: CGSize(width: width, height: height))
                if diary.imageUploadComplete == true {
                    let url = URL(string: diary.imageUrl)
                    self?.imageView.kf.indicatorType = .activity
                    self?.imageView.kf.setImage(
                        with: url,
                        options: [
                            .processor(processor),
                            .scaleFactor(UIScreen.main.scale),
                            .cacheOriginalImage]
                    ) { result in
                        switch result {
                        case .success:
                            self?.imageLoadComplete = true
                        case .failure:
                            self?.imageLoadComplete = false
                        }
                    }
                } else {
                    self?.imageLoadComplete = false
                    // MARK: 이미지 업로드 중일 때 표시
                    DispatchQueue.global().async { [weak self] in
                        DispatchQueue.main.async {
                            self?.imageView.contentMode = .center
                            self?.imageView.image = UIImage(named: "ImageUploading")
                        }
                    }
                }
            }
        }
    }
}
extension DetailDiaryPageViewController {
    @objc
    func back() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @objc
    func tabEditBtn(_ sender: Any) {
        if uploadCheck() == true {
            if let diary = self.diary {
                let storyboard: UIStoryboard = UIStoryboard(name: "EditDiaryPageView", bundle: nil)
                guard let editDiaryPageVC = storyboard.instantiateViewController(withIdentifier: "EditDiaryPageViewController") as? EditDiaryPageViewController else { return }
                editDiaryPageVC.delegate = self
                editDiaryPageVC.diary = diary
                editDiaryPageVC.image = self.imageView.image
                editDiaryPageVC.modalTransitionStyle = .crossDissolve
                editDiaryPageVC.modalPresentationStyle = .fullScreen
                self.present(editDiaryPageVC, animated: true, completion: nil)
            }
        }
    }
    func uploadCheck() -> Bool {
        if let diary = self.diary {
            if diary.imageUploadComplete == false {
                // MARK: 이미지 저장 중일때 예외처리
                self.view.makeToast("이미지 업로드 중입니다. 잠시 후 시도해주세요.")
                return false
            } else if self.imageLoadComplete == false {
                // MARK: 이미지 불러오기가 아직 덜 됐을 때 예외처리
                self.view.makeToast("이미지 로딩 중입니다. 잠시 후 시도해주세요.")
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    @objc
    func tabRemoveBtn(_ sender: Any) {
        let alert = UIAlertController(title: "일기를 삭제하시겠습니까?",
                                      message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: { _ in
        }))
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: { [weak self] _ in
            if self?.uploadCheck() == true {
                LoadingIndicator.showLoading()
                guard let docId = self?.docId else { return }
                DatabaseManager.shared.fireStore.collection("diary").document(docId).delete { [weak self] result in
                    guard result == nil else {
                        self?.view.makeToast("일기 삭제에 실패했습니다.", duration: 1.5, position: .bottom)
                        LoadingIndicator.hideLoading()
                        return
                    }
                    LoadingIndicator.hideLoading()
                    self?.delegate?.delete(Delete: self?.docId)
                    self?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
extension DetailDiaryPageViewController: UIScrollViewDelegate {
    // MARK: - 스크롤 방향에 따라 toolBar hide & show
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if translation.y > 0 {
            if self.scrolldirection == true {
                DispatchQueue.main.async {
                    UIView.transition(with: self.toolBar, duration: 0.6,
                                      options: .transitionCrossDissolve,
                                      animations: {
                        self.toolBar.isHidden = false
                    })
                }
                self.scrolldirection = false
            }
        } else {
            if self.scrolldirection == false {
                self.toolBar.isHidden = true
                self.scrolldirection = true
            }
        }
    }
}
extension DetailDiaryPageViewController: DispatchDiary {
    func update(Input value: Diary?) {
        if let diary = value {
            self.delegate?.update(Input: diary)
        }
    }
    func delete(Delete id: String?) {}
    func dispatch(Input value: Diary?) {}
}
extension DetailDiaryPageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isEqual(navigationController?.interactivePopGestureRecognizer) {
            navigationController?.popViewController(animated: true)
        }
        return false
    }
}
