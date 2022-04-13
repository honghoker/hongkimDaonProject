import UIKit
import FirebaseFirestore
import FirebaseAuth
import SnapKit

class InputNickNameViewController: UIViewController {
    let database = Firestore.firestore()
    lazy var overLapCheck: Bool = false
    var userUid: String = ""
    var platForm: String = ""
    @IBOutlet weak var overlapText: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var warningOverLapText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("get userUid \(userUid)")
        print("get platForm \(platForm)")
        let overlapClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapOverlapCheck(_:)))
        overlapText.isUserInteractionEnabled = true
        overlapText.addGestureRecognizer(overlapClick)
        warningOverLapText.isHidden = true
        nickNameTextField.delegate = self
        nickNameTextField.addUnderLine()
    }
    // 이거 두개 무슨 차인지..? 결과는 똑같음
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        confirmBtn.titleLabel?.textAlignment = .center
        confirmBtn.layer.borderWidth = 1
        confirmBtn.layer.borderColor = UIColor.black.cgColor
        confirmBtn.titleLabel?.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        confirmBtn.addTarget(self, action: #selector(onTapConfirmBtn), for: .touchUpInside)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        confirmBtn.titleLabel?.textAlignment = .center
        confirmBtn.layer.borderWidth = 1
        confirmBtn.layer.borderColor = UIColor.black.cgColor
        confirmBtn.titleLabel?.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        confirmBtn.addTarget(self, action: #selector(onTapConfirmBtn), for: .touchUpInside)
    }
}

// MARK: 가입완료, 중복확인
extension InputNickNameViewController {
    @objc
    func onTapConfirmBtn() {
        //        logout()
        if self.overLapCheck == true {
            print("가입성공")
            let demmyUserData: User = User(uid: self.userUid, nickName: self.nickNameTextField.text!, joinTime: 1, platForm: self.platForm, notification: true, notificationTime: 22)
            writeUserData(userData: demmyUserData)
        } else {
            print("가입실패")
        }
    }
    func writeUserData(userData: User) {
        let docRef = database.document("user/\(userData.uid)")
        docRef.setData(["uid": userData.uid, "nickName": userData.nickName, "joinTime": userData.joinTime, "platForm": userData.platForm, "notification": userData.notification, "notificationTime": userData.notificationTime])
        //         메인 페이지 이동
        let storyboard: UIStoryboard = UIStoryboard(name: "MainPageView", bundle: nil)
        let mainViewController = storyboard.instantiateInitialViewController()
        mainViewController?.modalPresentationStyle = .fullScreen
        self.present(mainViewController!, animated: true, completion: nil)
    }
    @objc
    func onTapOverlapCheck(_ gesture: UITapGestureRecognizer) {
        print("overlap tap")
        lazy var overLapValue = false
        if let text = nickNameTextField.text {
            if text.isEmpty == true {
                overLapValue = true
            } else {
                let docRef = database.collection("user")
                docRef.getDocuments(completion: { snapshot, error in
                    if let error = error {
                        print("DEBUG: \(error.localizedDescription)")
                        return
                    }
                    guard let documents = snapshot?.documents else { return } // document 가져옴
                    documents.forEach { snapshot in
                        if let nickName = snapshot["nickName"] {
                            if String(describing: nickName) == text {
                                overLapValue = true
                            }
                        }
                    }
                })
            }
        }
        // 이거 위에 if 절 끝나고 돌아야하는데 if 끝나기 전에 밑에께 돌아버림 동기 비동기 처리해야함
        if overLapValue {
            // 닉네임 중복 o
            self.warningOverLapText.isHidden = false
            self.warningOverLapText.text = "닉네임이 중복입니다"
            self.warningOverLapText.textColor = UIColor.systemRed
            self.nickNameTextField.addRedUnderLine()
            self.nickNameTextField.setNeedsLayout()
            self.overLapCheck = false
        } else {
            // 닉네임 중복 x
            self.overLapCheck = true
            self.warningOverLapText.isHidden = false
            self.warningOverLapText.text = "사용가능한 닉네임입니다"
            self.warningOverLapText.textColor = UIColor.systemGreen
            self.nickNameTextField.addUnderLine()
            self.nickNameTextField.setNeedsLayout()
        }
    }
    // 추후 삭제
    @objc
    func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.navigationController?.popToRootViewController(animated: true)
            self.presentingViewController?.dismiss(animated: true)
            print("@@@@@@@@ logout complete")
        } catch let signOutError as NSError {
            print("ERROR: signOutError \(signOutError.localizedDescription)")
        }
    }
}

// MARK: textField UI변경
extension UITextField {
    func addUnderLine () {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: self.bounds.height + 10, width: self.bounds.width, height: 1)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        self.borderStyle = UITextField.BorderStyle.none
        self.layer.addSublayer(bottomLine)
    }
    func addRedUnderLine () {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: self.bounds.height + 10, width: self.bounds.width, height: 1)
        bottomLine.backgroundColor = UIColor.systemRed.cgColor
        self.borderStyle = UITextField.BorderStyle.none
        self.layer.addSublayer(bottomLine)
    }}

// MARK: textField 글자 수 제한 + BackSpace 감지
extension InputNickNameViewController: UITextFieldDelegate {
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