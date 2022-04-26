//
//  ChangeNickNameViewController.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/26.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth

class ChangeNickNameViewController: UIViewController {
    let db = Firestore.firestore()
    lazy var overLapCheck: NickNameOverCheck = NickNameOverCheck.entrance
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var overlapText: UILabel!
    @IBOutlet weak var warningOverLapText: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    var nickName: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        initNickName()
        let overlapClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapOverlapCheck(_:)))
        overlapText.isUserInteractionEnabled = true
        overlapText.addGestureRecognizer(overlapClick)
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        warningOverLapText.isHidden = true
        nickNameTextField.delegate = self
    }
    override func viewDidLayoutSubviews() {
        overLapCheck == NickNameOverCheck.entrance ? self.nickNameTextField.addUnderLine() : overLapCheck == NickNameOverCheck.check ? self.nickNameTextField.addUnderLine() :
        self.nickNameTextField.addRedUnderLine()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        editBtn.titleLabel?.textAlignment = .center
        editBtn.layer.borderWidth = 1
        editBtn.layer.borderColor = UIColor.black.cgColor
        editBtn.titleLabel?.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        editBtn.addTarget(self, action: #selector(onTapEditBtn), for: .touchUpInside)
    }
}

extension ChangeNickNameViewController {
    func initNickName() {
        if let uid = Auth.auth().currentUser?.uid {
            db.collection("user").document(uid).getDocument { snapshot, error in
                guard error == nil else {
                    return
                }
                self.nickName = snapshot?.get("nickName") as? String
                self.nickNameTextField.text = self.nickName
            }
        }
    }
    @objc
    func back() {
        self.presentingViewController?.dismiss(animated: true)
    }
    @objc
    func onTapOverlapCheck(_ gesture: UITapGestureRecognizer) {
        if let text = nickNameTextField.text {
            // MARK: 아무것도 입력안했을 때
            if text.isEmpty == true {
                warningOverLapText.isHidden = false
                self.overLapCheck = NickNameOverCheck.notCheck
                self.warningOverLapText.text = "변경할 닉네임을 입력해주세요."
                self.warningOverLapText.textColor = UIColor.systemRed
                self.nickNameTextField.addRedUnderLine()
            } else {
                // MARK: 기존 닉네임과 같을 때
                if text == self.nickName {
                    warningOverLapText.isHidden = true
                    self.overLapCheck = NickNameOverCheck.notCheck
                    self.nickNameTextField.addUnderLine()
                } else {
                    let docRef = db.collection("user").whereField("nickName", isEqualTo: text)
                    docRef.getDocuments(completion: { snapshot, error in
                        if let error = error {
                            print("DEBUG: \(error.localizedDescription)")
                            return
                        }
                        guard let documents = snapshot?.documents else { return }
                        if documents.isEmpty {
                            self.warningOverLapText.text = "사용가능한 닉네임입니다."
                            self.warningOverLapText.textColor = UIColor.systemGreen
                            self.overLapCheck = NickNameOverCheck.check
                            self.nickNameTextField.addUnderLine()
                        } else {
                            self.warningOverLapText.text = "중복된 닉네임입니다."
                            self.warningOverLapText.textColor = UIColor.systemRed
                            self.overLapCheck = NickNameOverCheck.notCheck
                            self.nickNameTextField.addRedUnderLine()
                        }
                        self.warningOverLapText.isHidden = false
                    })
                }
            }
        }
    }
    @objc
    func onTapEditBtn() {
        if self.overLapCheck == NickNameOverCheck.check {
            if let uid = Auth.auth().currentUser?.uid {
                db.collection("user").document(uid).updateData(["nickName": nickNameTextField.text!])
            } else {
                print("변경실패")
            }
        }
    }
}

// MARK: textField 글자 수 제한 + BackSpace 감지
extension ChangeNickNameViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        guard textField.text!.count < 8 else { return false }
        return true
    }
}
