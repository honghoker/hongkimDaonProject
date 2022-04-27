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

class EditDiaryPageViewController: UIViewController {
    var diary: Diary?
    var image: UIImage?
    @IBOutlet weak var backBtn: UILabel!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var diaryTitleTextField: UITextField!
    @IBOutlet weak var diaryContentTextView: UITextView!
    let placeholderText = "내용을 입력해주세요."
    private let titleMaxLength: Int = 50
    override func viewDidLoad() {
        super.viewDidLoad()
        diaryInit()
        diaryTitleTextField.delegate = self
        diaryContentTextView.delegate = self
        // MARK: 첫 영문자 소문자로 시작
        diaryTitleTextField.autocapitalizationType = .none
        diaryContentTextView.autocapitalizationType = .none
        let backBtnClicked: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(back(_:)))
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(backBtnClicked)
    }
    func diaryInit() {
        if image != nil {
            self.imageButton.setImage(self.image, for: .normal)
        }
        if let diary = self.diary {
            diaryTitleTextField.text = diary.title
            diaryContentTextView.text = diary.content
        }
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

extension EditDiaryPageViewController {
    @objc
    func back(_ gesture: UITapGestureRecognizer) {
        if image != self.imageButton.currentImage || diary?.title !=  diaryTitleTextField.text || diary?.content != diaryContentTextView.text {
            let alert = UIAlertController(title: "변경사항이 있습니다.",
                                          message: "수정된 내용을 저장하지 않고 나가시겠어요?", preferredStyle: UIAlertController.Style.alert)
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
}

// MARK: textField 글자 수 제한 + BackSpace 감지
extension EditDiaryPageViewController: UITextFieldDelegate {
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
extension EditDiaryPageViewController: UITextViewDelegate {
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
