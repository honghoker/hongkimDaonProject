import UIKit
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
    let db = DatabaseManager.shared.fireStore
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
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                self.userFcmToken = token
                print("FCM registration token: \(token)")
            }
        }
        setUIAtViewDidLoad()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setUIWillLayoutSubviews()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        changeOverLap()
    }
    // MARK: set UI
    func setUIAtViewDidLoad() {
        let overlapClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapOverlapCheck(_:)))
        self.overlapText.isUserInteractionEnabled = true
        self.overlapText.addGestureRecognizer(overlapClick)
        self.warningOverLapText.isHidden = true
        self.nickNameTextField.delegate = self
        self.nickNameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }
    func setUIWillLayoutSubviews() {
        self.confirmBtn.titleLabel?.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        self.confirmBtn.titleLabel?.textAlignment = .center
        self.confirmBtn.layer.borderWidth = 1
        self.confirmBtn.layer.borderColor = UIColor.label.cgColor
        self.confirmBtn.tintColor = UIColor.label
        self.confirmBtn.addTarget(self, action: #selector(onTapConfirmBtn), for: .touchUpInside)
    }
}

// MARK: 가입완료, 중복확인
extension InputNickNameViewController {
    @objc
    func onTapConfirmBtn() {
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
                print("데이터 저장 실패")
                return
            }
        }
        // 가입 성공 후 메인 페이지 이동
        let storyboard: UIStoryboard = UIStoryboard(name: "MainPageView", bundle: nil)
        guard let mainViewController = storyboard.instantiateViewController(withIdentifier: "FirstMainPageContainerViewController") as? FirstMainPageContainerViewController else { return }
        // 화면 전환 애니메이션 설정
        mainViewController.modalTransitionStyle = .crossDissolve
        // 전환된 화면이 보여지는 방법 설정
        mainViewController.modalPresentationStyle = .fullScreen
        self.present(mainViewController, animated: true, completion: nil)
    }
    @objc
    func onTapOverlapCheck(_ gesture: UITapGestureRecognizer) {
        if let text = self.nickNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
            // 아무것도 입력안했을 때
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
