import UIKit
import FirebaseFirestore
import FirebaseAuth
import SnapKit
import FirebaseMessaging

enum NickNameOverCheck: String {
    case entrance = ""
    case empty = "변경할 닉네임을 입력해주세요."
    case overlap = "중복된 닉네임입니다."
    case requireCheck = "중복확인을 해주세요."
    case check = "사용가능한 닉네임입니다."
    case same = "기존 닉네임과 같습니다."
}

class InputNickNameViewController: UIViewController {
    let db = Firestore.firestore()
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
        self.nickNameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        changeOverLap()
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
    // MARK: 빈 화면 터치시 키보드 내림
    //    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //          self.view.endEditing(true)
    //    }
}

// MARK: 가입완료, 중복확인
extension InputNickNameViewController {
    @objc
    func onTapConfirmBtn() {
        //        logout()
        if self.overLapCheck == NickNameOverCheck.check {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "HH:mm"
            let demmyUserData: User = User(uid: self.userUid, nickName: self.nickNameTextField.text!, joinTime: Int(Date().millisecondsSince1970), platForm: self.platForm, notification: true, notificationTime: formatter.string(from: Date()), fcmToken: userFcmToken)
            writeUserData(userData: demmyUserData)
        } else {
            self.overLapCheck = NickNameOverCheck.requireCheck
            changeOverLap()
        }
    }
    func writeUserData(userData: User) {
        let docRef = db.document("user/\(userData.uid)")
        docRef.setData(["uid": userData.uid, "nickName": userData.nickName, "joinTime": userData.joinTime, "platForm": userData.platForm, "notification": userData.notification, "notificationTime": userData.notificationTime, "fcmToken": userData.fcmToken]) { result in
            guard result == nil else {
                print("@@@@@@@ 데이터 저장 실패")
                return
            }
        }
        // MARK: 가입 성공 후 메인 페이지 이동
        let storyboard: UIStoryboard = UIStoryboard(name: "MainPageView", bundle: nil)
        guard let mainViewController = storyboard.instantiateViewController(withIdentifier: "FirstMainPageContainerViewController") as? FirstMainPageContainerViewController else { return }
        // MARK: 화면 전환 애니메이션 설정
        mainViewController.modalTransitionStyle = .crossDissolve
        // MARK: 전환된 화면이 보여지는 방법 설정
        mainViewController.modalPresentationStyle = .fullScreen
        self.present(mainViewController, animated: true, completion: nil)
    }
    @objc
    func onTapOverlapCheck(_ gesture: UITapGestureRecognizer) {
        if let text = self.nickNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            // MARK: 아무것도 입력안했을 때
            if text.isEmpty == true {
                self.overLapCheck = NickNameOverCheck.empty
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

extension InputNickNameViewController: UITextFieldDelegate {
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
