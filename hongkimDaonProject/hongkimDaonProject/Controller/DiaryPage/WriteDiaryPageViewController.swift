//
//  WriteDiaryPageViewController.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/11.
//

import UIKit
import FirebaseFirestoreSwift
import FMPhotoPicker
import SnapKit
import STTextView

class WriteDiaryPageViewController: UIViewController {
    var delegate: DispatchDiary?
    @IBOutlet weak var imageViewLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backBtn: UILabel!
    @IBOutlet weak var completeBtn: UILabel!
    @IBOutlet weak var diaryContentTextView: STTextView!
    @IBOutlet weak var scrollView: UIScrollView!
    private let titleMaxLength: Int = 50
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "bgColor")
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 10
        style.lineBreakStrategy = .hangulWordPriority
        let attributes =  [NSAttributedString.Key.paragraphStyle: style]
        diaryContentTextView.typingAttributes = attributes
        diaryContentTextView.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        diaryContentTextView.textColor = .label
        let imgButtonClicked: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickImage(_:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imgButtonClicked)
        let backBtnClicked: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(back(_:)))
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(backBtnClicked)
        let completeBtnClicked: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(complete(_:)))
        completeBtn.isUserInteractionEnabled = true
        completeBtn.addGestureRecognizer(completeBtnClicked)
    }
}

extension WriteDiaryPageViewController {
    @objc
    func back(_ gesture: UITapGestureRecognizer) {
        if self.imageView.image != nil || !diaryContentTextView.text.isEmpty {
            let alert = UIAlertController(title: "작성된 내용이 있어요.\n저장하지 않고 나가시겠어요?",
                                          message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: { _ in
            }))
            alert.addAction(UIAlertAction(title: "확인",
                                          style: UIAlertAction.Style.default,
                                          handler: {(_: UIAlertAction!) in
                self.presentingViewController?.dismiss(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.presentingViewController?.dismiss(animated: true)
        }
    }
    @objc
    func complete(_ gesture: UITapGestureRecognizer) {
        if let uid = AuthManager.shared.auth.currentUser?.uid {
            LoadingIndicator.showLoading()
            let writeTime: Int64 = Int64(Date().millisecondsSince1970)
            let content = diaryContentTextView.text ?? ""
            let diary = Diary(id: nil, uid: uid, imageUrl: "", content: content, writeTime: writeTime,
                              imageExist: self.imageView.image != nil, imageWidth: self.imageView.image?.size.width ?? 0, imageHeight: self.imageView.image?.size.height ?? 0, imageUploadComplete: self.imageView.image == nil)
            DatabaseManager.shared.writeDiary(diary: diary) { result in
                switch result {
                case .success(let success):
                    print("@@@@@@@ 일기쓰기 성공 : \(success)")
                    if self.imageView.image != nil {
                        guard let image = self.imageView.image,
                              let data = image.jpegData(compressionQuality: 0.5) else {
                            return
                        }
                        StorageManager.shared.uploadImage(with: data, filePath: "diary", fileName: String(writeTime)) { result in
                            switch result {
                            case .success(let downloadUrl):
                                DatabaseManager.shared.updateImageUrl(docId: String(writeTime), imageUrl: downloadUrl) { result in
                                    switch result {
                                    case .success(let success):
                                        print("@@@@@@@@@ imageUpdate 성공 : \(success)")
                                    case .failure(let error):
                                        print("@@@@@@@@ failedToUpdateImageUrl error : \(error)")
                                    }
                                }
                            case .failure(let error):
                                print("@@@@@@@@@@@ Storage manager error: \(error)")
                            }
                        }
                    }
                    LoadingIndicator.hideLoading()
                    self.delegate?.dispatch(self, Input: diary)
                    self.presentingViewController?.dismiss(animated: true)
                case .failure(let error):
                    LoadingIndicator.hideLoading()
                    self.view.makeToast("일기 쓰기에 실패했습니다.", duration: 1.5, position: .bottom)
                }
            }
        } else {
            self.view.makeToast("네트워크 연결을 확인해주세요.", duration: 1.5, position: .bottom)
        }
    }
    @objc
    func pickImage(_ gesture: UITapGestureRecognizer) {
        var config = FMPhotoPickerConfig()
        config.maxImage = 1
        config.selectMode = .single
        config.mediaTypes = [.image]
        config.useCropFirst = true
        config.strings["picker_button_cancel"] = "취소"
        config.strings["picker_button_select_done"] = "완료"
        config.strings["present_title_photo_created_date_format"] = ""
        config.strings["present_button_back"] = ""
        config.strings["present_button_edit_image"] = "편집하기"
        config.strings["editor_button_cancel"] = "취소"
        config.strings["editor_button_done"] = "완료"
        config.strings["permission_button_ok"] = "확인"
        config.strings["permission_button_cancel"] = "취소"
        config.strings["editor_menu_crop"] = ""
        config.strings["editor_menu_filter"] = ""
        config.strings["permission_dialog_title"] = ""
        config.strings["permission_dialog_message"] = "사진에 접근할 수 없습니다.\n사진에 대한 접근 권한을 허용해주세요."
        let picker = FMPhotoPickerViewController(config: config)
        picker.delegate = self
        self.present(picker, animated: true)
    }
}

extension WriteDiaryPageViewController: FMPhotoPickerViewControllerDelegate {
    func fmImageEditorViewController(_ editor: FMImageEditorViewController, didFinishEdittingPhotoWith photo: UIImage) {
        self.dismiss(animated: true, completion: nil)
        print("@@@@@@@@@@@@ photo : \(photo)")
    }
    func fmPhotoPickerController(_ picker: FMPhotoPickerViewController, didFinishPickingPhotoWith photos: [UIImage]) {
        print("@@@@@@@@@@@@ photo222 : \(photos[0])")
        self.dismiss(animated: true, completion: nil)
        imageView.image = photos[0]
        imageViewLabel.isHidden = true
    }
}
