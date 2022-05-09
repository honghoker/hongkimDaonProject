//
//  EditDiaryPageViewController.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/27.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import FMPhotoPicker
import STTextView

class EditDiaryPageViewController: UIViewController {
    var diary: Diary?
    var image: UIImage?
    var delegate: DispatchDiary?
    @IBOutlet weak var backBtn: UILabel!
    @IBOutlet weak var completeBtn: UILabel!
    @IBOutlet weak var imageViewLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var diaryContentTextView: STTextView!
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
        diaryInit()
    }
    func diaryInit() {
        if self.image != nil {
            self.imageView.image = self.image
            imageViewLabel.isHidden = true
        }
        if let diary = self.diary {
            diaryContentTextView.text = diary.content
        }
    }
}

extension EditDiaryPageViewController {
    @objc
    func back(_ gesture: UITapGestureRecognizer) {
        if self.image != self.imageView.image || diary?.content != diaryContentTextView.text {
            let alert = UIAlertController(title: "변경사항이 있습니다.",
                                          message: "수정된 내용을 저장하지 않고 나가시겠어요?", preferredStyle: UIAlertController.Style.alert)
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
        print("@@@@@@ complete Touch")
        if AuthManager.shared.auth.currentUser?.uid != nil {
            if var diary = self.diary {
                diary.imageExist = self.imageView.image != nil
                diary.imageWidth = self.imageView.image?.size.width ?? 0
                diary.imageHeight = self.imageView.image?.size.height ?? 0
                diary.content = self.diaryContentTextView.text ?? ""
                if self.imageView.image == nil {
                    diary.imageUploadComplete = true
                } else {
                    diary.imageUploadComplete = self.imageView.image == self.image
                }
                DatabaseManager.shared.updateDiary(diary: diary, completion: {result in
                    switch result {
                    case .success(let success):
                        // MARK: 이미지를 변경했을 경우, 삭제했을 경우
                        if self.imageView.image != self.image {
                            // MARK: 기존 이미지 삭제
                            StorageManager.shared.deleteImage(downloadURL: diary.imageUrl)
                            // MARK: 이미지 변경 시
                            if let image = self.imageView.image, let data = image.jpegData(compressionQuality: 0.5) {
                                StorageManager.shared.uploadImage(with: data, filePath: "diary", fileName: String(diary.writeTime)) { result in
                                    switch result {
                                    case .success(let downloadUrl):
                                        DatabaseManager.shared.updateImageUrl(docId: String(diary.writeTime), imageUrl: downloadUrl) { result in
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
                        }
                        print("@@@@@@@@@ update 성공")
                        self.delegate?.update(self, Input: diary)
                        self.presentingViewController?.dismiss(animated: true)
                    case .failure(let error):
                        print("업데이트 실패 토스트 : \(error)")
                    }
                })
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

extension EditDiaryPageViewController: FMPhotoPickerViewControllerDelegate {
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
