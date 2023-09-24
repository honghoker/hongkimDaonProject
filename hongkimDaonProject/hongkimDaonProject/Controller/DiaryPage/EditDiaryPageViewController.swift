import Foundation
import UIKit
import FirebaseFirestore
import FMPhotoPicker
import STTextView
//import Toast_Swift

class EditDiaryPageViewController: UIViewController {
    private let textViewMaxLength: Int = 5000
    private var diary: Diary?
    private var image: UIImage?
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
        label.text = "일기수정"
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
    
    init(diary: Diary, image: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        self.diary = diary
        self.image = image
        imageView.image = image
        imageViewLabel.isHidden = image != nil
        textView.text = diary.content
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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

extension EditDiaryPageViewController {
    @objc
    func didTapBackButton(_ gesture: UITapGestureRecognizer) {
        if image != imageView.image || diary?.content != textView.text {
            let alert = UIAlertController(
                title: "변경사항이 있습니다.",
                message: "수정된 내용을 저장하지 않고 나가시겠어요?",
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
        if AuthManager.shared.auth.currentUser?.uid != nil {
            LoadingIndicator.showLoading()
            if var diary {
                diary.imageExist = imageView.image != nil
                diary.imageWidth = imageView.image?.size.width ?? 0
                diary.imageHeight = imageView.image?.size.height ?? 0
                diary.content = textView.text ?? ""
                if self.imageView.image == nil {
                    diary.imageUploadComplete = true
                } else {
                    diary.imageUploadComplete = self.imageView.image == self.image
                }
                DatabaseManager.shared.updateDiary(diary: diary, completion: { [weak self] result in
                    switch result {
                    case .success:
                        // MARK: 이미지를 변경했을 경우, 삭제했을 경우
                        if self?.imageView.image != self?.image {
                            // MARK: 기존 이미지 삭제
                            if self?.image != nil {
                                // StorageManager.shared.deleteImage(downloadURL: diary.imageUrl)
                            }
                            // MARK: 이미지 변경 시
                            if let image = self?.imageView.image, let data = image.jpegData(compressionQuality: 0.5) {
                                StorageManager.shared.uploadImage(with: data, filePath: "diary", fileName: String(diary.writeTime)) { result in
                                    switch result {
                                    case .success(let downloadUrl):
                                        DatabaseManager.shared.updateImageUrl(docId: String(diary.writeTime), imageUrl: downloadUrl) { result in
                                            switch result {
                                            case .success:
                                                debugPrint("updateImage success")
                                            case .failure:
                                                debugPrint("updateImage faulure")
                                            }
                                        }
                                    case .failure:
                                        debugPrint("uploadImage error")
                                    }
                                }
                            }
                        }
                        LoadingIndicator.hideLoading()
                        self?.delegate?.update(Input: diary)
                        self?.presentingViewController?.dismiss(animated: true)
                    case .failure:
                        LoadingIndicator.hideLoading()
                        //                        self?.view.makeToast("일기 수정이 실패했습니다.", duration: 1.5, position: .bottom)
                    }
                })
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

extension EditDiaryPageViewController: FMPhotoPickerViewControllerDelegate {
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

extension EditDiaryPageViewController: UITextViewDelegate {
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
