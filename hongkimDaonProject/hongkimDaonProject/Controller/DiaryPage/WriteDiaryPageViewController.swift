import UIKit
import FirebaseFirestore
import FMPhotoPicker
import SnapKit
import STTextView

class WriteDiaryPageViewController: UIViewController {
    private let textViewMaxLength: Int = 5000
    weak var delegate: DispatchDiary?
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(.systemGray3, for: .normal)
        button.titleLabel?.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "일기쓰기"
        label.textColor = .black
        label.font = UIFont(name: "JejuMyeongjoOTF", size: 16)
        return label
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton()
        button.setTitle("완료", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        button.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapPickImage))
        imageView.addGestureRecognizer(gesture)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let imageViewLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘 하루를 표현하는 사진 한장을 올려보세요"
        label.textColor = .black
        label.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private lazy var textView: STTextView = {
        let textView = STTextView()
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        style.lineBreakStrategy = .hangulWordPriority
        let attributes = [NSAttributedString.Key.paragraphStyle: style]
        
        textView.typingAttributes = attributes
        textView.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        textView.textColor = .label
        textView.placeholder = "내용을 입력해주세요."
        textView.delegate = self
        
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addView()
        setLayout()
        setupView()
    }
    
    private func addView() {
        [
            imageView,
            imageViewLabel,
            textView
        ].forEach {
            scrollView.addSubview($0)
        }
        
        [
            backButton,
            titleLabel,
            completeButton,
            scrollView
        ].forEach {
            view.addSubview($0)
        }
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(20)
            $0.centerX.equalTo(view.snp.centerX)
        }
        
        backButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel)
            $0.left.equalTo(view.safeAreaLayoutGuide.snp.left).inset(16)
        }
        
        completeButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel)
            $0.right.equalTo(view.safeAreaLayoutGuide.snp.right).inset(20)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(scrollView.contentLayoutGuide)
            $0.horizontalEdges.equalTo(scrollView.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(300)
        }
        
        imageViewLabel.snp.makeConstraints {
            $0.center.equalTo(imageView)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(16)
            $0.horizontalEdges.equalTo(scrollView.safeAreaLayoutGuide).inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(named: "bgColor")
    }
}

extension WriteDiaryPageViewController {
    @objc
    func didTapBackButton(_ gesture: UITapGestureRecognizer) {
        if imageView.image != nil || !textView.text.isEmpty {
            let alert = UIAlertController(
                title: "작성된 내용이 있어요.\n저장하지 않고 나가시겠어요?",
                message: "",
                preferredStyle: .alert
            )
            let submit = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                self?.presentingViewController?.dismiss(animated: true)
            }
            let cancel = UIAlertAction(title: "취소", style: .default)
            [cancel, submit].forEach { alert.addAction($0) }
            alert.preferredAction = submit
            present(alert, animated: true)
        } else {
            presentingViewController?.dismiss(animated: true)
        }
    }
    @objc
    func didTapCompleteButton(_ gesture: UITapGestureRecognizer) {
        if let uid = AuthManager.shared.auth.currentUser?.uid {
            LoadingIndicator.showLoading()
            let writeTime: Int64 = Int64(Date().millisecondsSince1970)
            let content = textView.text ?? ""
            let diary = Diary(
                id: nil,
                uid: uid,
                imageUrl: "",
                content: content,
                writeTime: writeTime,
                imageExist: imageView.image != nil,
                imageWidth: imageView.image?.size.width ?? 0,
                imageHeight: imageView.image?.size.height ?? 0,
                imageUploadComplete: imageView.image == nil
            )
            
            DatabaseManager.shared.writeDiary(diary: diary) { [weak self] result in
                switch result {
                case .success:
                    if self?.imageView.image != nil {
                        guard let image = self?.imageView.image,
                              let data = image.jpegData(compressionQuality: 0.5) else {
                            return
                        }
                        StorageManager.shared.uploadImage(with: data, filePath: "diary", fileName: String(writeTime)) { result in
                            switch result {
                            case .success(let downloadUrl):
                                DatabaseManager.shared.updateImageUrl(docId: String(writeTime), imageUrl: downloadUrl) { result in
                                    switch result {
                                    case .success:
                                        debugPrint("updateImage success")
                                    case .failure:
                                        debugPrint("updateImage failure")
                                    }
                                }
                            case .failure:
                                debugPrint("uploadImage error")
                            }
                        }
                    }
                    LoadingIndicator.hideLoading()
                    self?.delegate?.dispatch(Input: diary)
                    self?.presentingViewController?.dismiss(animated: true)
                case .failure:
                    LoadingIndicator.hideLoading()
                    //                    self?.view.makeToast("일기 쓰기에 실패했습니다.", duration: 1.5, position: .bottom)
                }
            }
        } else {
            //            self.view.makeToast("네트워크 연결을 확인해주세요.", duration: 1.5, position: .bottom)
        }
    }
    @objc
    func didTapPickImage(_ gesture: UITapGestureRecognizer) {
        let config = FMPhotoPickerConfig.customConfiguration()
        let picker = FMPhotoPickerViewController(config: config)
        picker.delegate = self
        self.present(picker, animated: true)
    }
}

extension WriteDiaryPageViewController: FMPhotoPickerViewControllerDelegate {
    func fmImageEditorViewController(
        _ editor: FMImageEditorViewController,
        didFinishEdittingPhotoWith photo: UIImage
    ) {
        dismiss(animated: true, completion: nil)
    }
    func fmPhotoPickerController(
        _ picker: FMPhotoPickerViewController,
        didFinishPickingPhotoWith photos: [UIImage]
    ) {
        dismiss(animated: true, completion: nil)
        guard let photo = photos.first else { return }
        imageView.image = photo
        imageViewLabel.isHidden = true
    }
}

extension WriteDiaryPageViewController: UITextViewDelegate {
    // MARK: textView 글자 수 제한 + BackSpace 감지
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let char = text.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        guard textView.text!.count < textViewMaxLength else {
            //            self.view.makeToast("5,000자까지 입력할 수 있습니다.", duration: 1.5, position: .bottom)
            return false
        }
        return true
    }
}

extension FMPhotoPickerConfig {
    static func customConfiguration() -> FMPhotoPickerConfig {
        var config = FMPhotoPickerConfig()
        config.maxImage = 1
        config.selectMode = .single
        config.mediaTypes = [.image]
        config.useCropFirst = true
        config.customStrings = [
            "picker_button_cancel": "취소",
            "picker_button_select_done": "완료",
            "present_title_photo_created_date_format": "",
            "present_button_back": "",
            "present_button_edit_image": "편집하기",
            "editor_button_cancel": "취소",
            "editor_button_done": "완료",
            "permission_button_ok": "확인",
            "permission_button_cancel": "취소",
            "editor_menu_crop": "",
            "editor_menu_filter": "",
            "permission_dialog_title": "",
            "permission_dialog_message": "사진에 접근할 수 없습니다.\n사진에 대한 접근 권한을 허용해주세요."
        ]
        return config
    }
    
    private var customStrings: [String: String] {
        get { strings }
        set { newValue.forEach { strings[$0.key] = $0.value } }
    }
}
