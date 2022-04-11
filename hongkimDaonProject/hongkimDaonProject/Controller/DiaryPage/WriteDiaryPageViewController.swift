//
//  WriteDiaryPageViewController.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/11.
//

import UIKit

class WriteDiaryPageViewController: UIViewController {
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var diaryTextField: UITextField!
    @IBOutlet weak var diaryTextView: UITextView!
    let placeholderText = "내용을 입력해주세요."
    override func viewDidLoad() {
        super.viewDidLoad()
        diaryTextView.text = placeholderText
        diaryTextView.textColor = .lightGray
        diaryTextView.delegate = self
        diaryTextField.autocapitalizationType = .none
        diaryTextView.autocapitalizationType = .none
        let imgButtonClicked: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(navigate(_:)))
        imageButton.addGestureRecognizer(imgButtonClicked)
    }
    override func viewDidLayoutSubviews() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: diaryTextField.frame.height+6, width: diaryTextField.frame.width, height: 0.5)
        bottomLine.backgroundColor = UIColor.systemGray4.cgColor
        diaryTextField.borderStyle = .none
        diaryTextField.layer.addSublayer(bottomLine)
        // MARK: to remove left padding
        diaryTextView.textContainer.lineFragmentPadding = 0
    }
    @objc
    func navigate(_ gesture: UITapGestureRecognizer) {
//        let storyboard: UIStoryboard = UIStoryboard(name: "MainPageView", bundle: nil)
//        let inputNickNameVC = storyboard.instantiateViewController(withIdentifier: "MainPageViewController")
//        inputNickNameVC.modalPresentationStyle = .fullScreen
//        inputNickNameVC.modalTransitionStyle = .crossDissolve
//        self.present(inputNickNameVC, animated: true, completion: nil)
    }
}

extension WriteDiaryPageViewController: UITextViewDelegate {
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
