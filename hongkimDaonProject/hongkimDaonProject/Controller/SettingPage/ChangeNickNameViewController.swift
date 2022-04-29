//
//  ChangeNickNameViewController.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/26.
//

import Foundation
import UIKit
import Toast_Swift
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
        self.nickNameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        changeOverLap()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        editBtn.titleLabel?.textAlignment = .center
        editBtn.layer.borderWidth = 1
        editBtn.layer.borderColor = UIColor.label.cgColor
        editBtn.tintColor = UIColor.label
        editBtn.titleLabel?.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        editBtn.addTarget(self, action: #selector(onTapEditBtn), for: .touchUpInside)
        LoadingIndicator.showLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            LoadingIndicator.hideLoading()
        }
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
        self.presentingViewController?.dismiss(animated: false)
    }
    @objc
    func onTapOverlapCheck(_ gesture: UITapGestureRecognizer) {
        if let text = self.nickNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            // MARK: 아무것도 입력안했을 때
            if text.isEmpty == true {
                self.overLapCheck = NickNameOverCheck.empty
                self.changeOverLap()
            } else {
                // MARK: 기존 닉네임과 같을 때
                if text == self.nickName {
                    self.overLapCheck = NickNameOverCheck.same
                    self.changeOverLap()
                } else {
                    let docRef = db.collection("user").whereField("nickName", isEqualTo: text)
                    docRef.getDocuments(completion: { snapshot, error in
                        if let error = error {
                            print("DEBUG: \(error.localizedDescription)")
                            return
                        }
                        guard let documents = snapshot?.documents else { return }
                        if documents.isEmpty {
                            self.overLapCheck = NickNameOverCheck.check
                            self.changeOverLap()
                        } else {
                            self.overLapCheck = NickNameOverCheck.overlap
                            self.changeOverLap()
                        }
                    })
                }
            }
        }
    }
    // MARK: underLine, 경고문구 변경
    func changeOverLap() {
        switch self.overLapCheck {
        case .entrance: // 처음
            self.nickNameTextField.addUnderLine()
            warningOverLapText.isHidden = true
        case .empty: // 공백
            self.warningOverLapText.textColor = UIColor.systemRed
            self.nickNameTextField.addRedUnderLine()
            self.warningOverLapText.isHidden = false
        case .overlap: // 중복
            self.warningOverLapText.textColor = UIColor.systemRed
            self.nickNameTextField.addRedUnderLine()
            self.warningOverLapText.isHidden = false
        case .requireCheck: // 중복확인 요구
            self.warningOverLapText.textColor = UIColor.systemRed
            self.nickNameTextField.addRedUnderLine()
            self.warningOverLapText.isHidden = false
        case .check: // 사용가능
            self.warningOverLapText.textColor = UIColor.systemGreen
            self.nickNameTextField.addUnderLine()
            self.warningOverLapText.isHidden = false
        case .same: // 기존이랑 같음
            self.warningOverLapText.textColor = UIColor.systemRed
            self.nickNameTextField.addRedUnderLine()
            self.warningOverLapText.isHidden = false
        }
        self.warningOverLapText.text = self.overLapCheck.rawValue
    }
    @objc
    func onTapEditBtn() {
        if self.overLapCheck == NickNameOverCheck.check {
            if let uid = Auth.auth().currentUser?.uid {
                db.collection("user").document(uid).updateData(["nickName": nickNameTextField.text!]) { result in
                    guard result == nil else {
                        self.view.makeToast("닉네임 변경에 실패했습니다.", duration: 1.5, position: .bottom)
                        return
                    }
                    self.view.makeToast("닉네임 변경에 성공했습니다.", duration: 1.5, position: .bottom)
                }
            } else {
                self.view.makeToast("네트워크 연결을 확인해주세요.", duration: 1.5, position: .bottom)
            }
        } else {
            self.overLapCheck = NickNameOverCheck.requireCheck
            changeOverLap()
        }
    }
}

extension ChangeNickNameViewController: UITextFieldDelegate {
    // MARK: 중복확인완료 후 텍스트 필드가 변경되었을 때
    @objc func textFieldDidChange(_ sender: Any?) {
        if self.overLapCheck == NickNameOverCheck.check {
            self.overLapCheck = NickNameOverCheck.entrance
            changeOverLap()
        }
    }
    // MARK: textField 글자 수 제한 + BackSpace 감지
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
