import UIKit
import FirebaseFirestore
import FirebaseAuth
import SnapKit
import FirebaseMessaging

enum NickNameOverCheck {
    case entrance
    case notCheck
    case check
}

class InputNickNameViewController: UIViewController {
    let database = Firestore.firestore()
    lazy var overLapCheck: NickNameOverCheck = NickNameOverCheck.entrance
    var userUid: String = ""
    var platForm: String = ""
    var userFcmToken: String = ""
    @IBOutlet weak var overlapText: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var warningOverLapText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("get userUid \(userUid)")
        print("get platForm \(platForm)")
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                self.userFcmToken = token
                print("FCM registration token: \(token)")
            }
        }
        let overlapClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapOverlapCheck(_:)))
        overlapText.isUserInteractionEnabled = true
        overlapText.addGestureRecognizer(overlapClick)
        warningOverLapText.isHidden = true
        nickNameTextField.delegate = self
    }
    override func viewDidLayoutSubviews() {
        print("overLapCheck \(overLapCheck)")
        overLapCheck == NickNameOverCheck.entrance ? self.nickNameTextField.addUnderLine() : overLapCheck == NickNameOverCheck.check ? self.nickNameTextField.addUnderLine() :
        self.nickNameTextField.addRedUnderLine()
    }
    // storyboard에서 세팅을 해놨는데 vc에서 confirmBtn click 하고나면 왜 layout이 초기화되는건지..?
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
        if self.overLapCheck == NickNameOverCheck.check {
            print("가입성공")
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "HH:mm"
            let demmyUserData: User = User(uid: self.userUid, nickName: self.nickNameTextField.text!, joinTime: Int(Date().millisecondsSince1970), platForm: self.platForm, notification: true, notificationTime: formatter.string(from: Date()), fcmToken: userFcmToken)
            writeUserData(userData: demmyUserData)
        } else {
            print("가입실패")
        }
    }
    func writeUserData(userData: User) {
        let docRef = database.document("user/\(userData.uid)")
        docRef.setData(["uid": userData.uid, "nickName": userData.nickName, "joinTime": userData.joinTime, "platForm": userData.platForm, "notification": userData.notification, "notificationTime": userData.notificationTime, "fcmToken": userData.fcmToken])
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
                self.changeState(overLapValue: overLapValue)
            } else {
                let docRef = database.collection("user").whereField("nickName", isEqualTo: text)
                docRef.getDocuments(completion: { snapshot, error in
                    if let error = error {
                        print("DEBUG: \(error.localizedDescription)")
                        return
                    }
                    guard let documents = snapshot?.documents else { return }
                    overLapValue = documents.isEmpty == true ? false : true
                    self.changeState(overLapValue: overLapValue)
                })
            }
        }
    }
    func changeState(overLapValue: Bool) {
        if overLapValue == true {
            self.overLapCheck = NickNameOverCheck.notCheck
        } else {
            self.overLapCheck = NickNameOverCheck.check
        }
        self.warningOverLapText.isHidden = false
        self.warningOverLapText.text = overLapValue ? "닉네임이 중복입니다" : "사용가능한 닉네임입니다"
        self.warningOverLapText.textColor = overLapValue ? UIColor.systemRed : UIColor.systemGreen
        overLapValue ? self.nickNameTextField.addRedUnderLine() : self.nickNameTextField.addUnderLine()
        //        self.nickNameTextField.setNeedsLayout()
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
        //                self.bounds.width
        bottomLine.frame = CGRect(x: 0.0, y: self.frame.height + 10, width: self.frame.width, height: 1)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        self.borderStyle = UITextField.BorderStyle.none
        self.layer.addSublayer(bottomLine)
    }
    func addRedUnderLine () {
        let bottomLine = CALayer()
        //        self.bounds.width
        bottomLine.frame = CGRect(x: 0.0, y: self.frame.height + 10, width: self.frame.width, height: 1)
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
