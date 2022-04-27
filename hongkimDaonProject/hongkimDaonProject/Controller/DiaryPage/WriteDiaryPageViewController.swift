//
//  WriteDiaryPageViewController.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/11.
//

import UIKit
import MobileCoreServices
import FirebaseAuth
import Firebase
import FirebaseFirestoreSwift
import FMPhotoPicker

class WriteDiaryPageViewController: UIViewController {
    var delegate: DispatchDiary?
    @IBOutlet weak var backBtn: UILabel!
    @IBOutlet weak var completeBtn: UILabel!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var diaryTitleTextField: UITextField!
    @IBOutlet weak var diaryContentTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    let placeholderText = "내용을 입력해주세요."
    private let titleMaxLength: Int = 50
    override func viewDidLoad() {
        super.viewDidLoad()
        diaryTitleTextField.delegate = self
        diaryContentTextView.text = placeholderText
        diaryContentTextView.textColor = .lightGray
        diaryContentTextView.delegate = self
        // MARK: 첫 영문자 소문자로 시작
        diaryTitleTextField.autocapitalizationType = .none
        diaryContentTextView.autocapitalizationType = .none
        let imgButtonClicked: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickImage(_:)))
        imageButton.addGestureRecognizer(imgButtonClicked)
        let backBtnClicked: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(back(_:)))
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(backBtnClicked)
        let completeBtnClicked: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(complete(_:)))
        completeBtn.isUserInteractionEnabled = true
        completeBtn.addGestureRecognizer(completeBtnClicked)
    }
    override func viewDidLayoutSubviews() {
        // MARK: underLine 긋기
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: diaryTitleTextField.frame.height+6, width: diaryTitleTextField.frame.width, height: 0.5)
        bottomLine.backgroundColor = UIColor.systemGray4.cgColor
        diaryTitleTextField.borderStyle = .none
        diaryTitleTextField.layer.addSublayer(bottomLine)
        // MARK: to remove left padding
        diaryContentTextView.textContainer.lineFragmentPadding = 0
    }
}

extension Date {
    var millisecondsSince1970: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    func adding(_ component: Calendar.Component, value: Int, using calendar: Calendar = .current) -> Date {
            calendar.date(byAdding: component, value: value, to: self)!
    }
}

extension WriteDiaryPageViewController {
    @objc
    func back(_ gesture: UITapGestureRecognizer) {
        if self.imageButton.currentImage != nil || diaryTitleTextField.text != "" || diaryContentTextView.textColor != UIColor.lightGray {
            let alert = UIAlertController(title: "작성된 내용이 있어요.\n저장하지 않고 나가시겠어요?",
                                          message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: { _ in
                // Cancel Action
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
        if let uid = Auth.auth().currentUser?.uid {
            let writeTime: Int64 = Int64(Date().millisecondsSince1970)
            let title = diaryTitleTextField.text ?? ""
            var content: String = ""
            if diaryContentTextView.textColor != UIColor.lightGray {
                content = diaryContentTextView.text
            }
            let diary = Diary(id: nil, uid: uid, imageUrl: "", title: title, content: content, writeTime: writeTime)
            DatabaseManager.shared.writeDiary(diary: diary) { result in
                switch result {
                case .success(let success):
                    print("@@@@@@@ 일기쓰기 성공 : \(success)")
                    if self.imageButton.currentImage != nil {
                        guard let image = self.imageButton.currentImage,
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
                    self.delegate?.dispatch(self, Input: diary)
                    self.presentingViewController?.dismiss(animated: true)
                case .failure(let error):
                    print("@@@@@@@ 일기쓰기 실패 error : \(error)")
                }
            }
        } else {
            print("@@@@@@@@@@@ uid 없음 토스트")
        }
    }
    @objc
    func pickImage(_ gesture: UITapGestureRecognizer) {
        print("@@@@@@@@ navigate")
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
        imageButton.setImage(photos[0], for: .normal)
    }
}

// MARK: textField 글자 수 제한 + BackSpace 감지
extension WriteDiaryPageViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        guard textField.text!.count < titleMaxLength else { return false }
        return true
    }
}

extension WriteDiaryPageViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText: String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
        // Else if the text view's placeholder is showing and the
        // length of the replacement string is greater than 0, set
        // the text color to black then set its text to the
        // replacement string
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }
        // For every other case, the text should change with the usual
        // behavior...
        else {
            return true
        }
        // ...otherwise return false since the updates have already
        // been made
        return false
    }
}
