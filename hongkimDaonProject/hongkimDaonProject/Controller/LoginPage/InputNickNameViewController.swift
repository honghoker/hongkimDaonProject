import UIKit
import FirebaseFirestore
import FirebaseAuth

class InputNickNameViewController: UIViewController {
    let database = Firestore.firestore()
    @IBOutlet weak var overlapText: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var warningOverLapText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let overlapClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapOverlapCheck(_:)))
        overlapText.isUserInteractionEnabled = true
        overlapText.addGestureRecognizer(overlapClick)
        warningOverLapText.heightAnchor.constraint(equalToConstant: CGFloat(0)).isActive = true
//        warningOverLapText.isHidden = false
//        warningOverLapText.heightAnchor.constraint(equalToConstant: CGFloat(40)).isActive = true
        nickNameTextField.addUnderLine()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        confirmBtn.layer.borderWidth = 1
        confirmBtn.layer.borderColor = UIColor.black.cgColor
        confirmBtn.titleLabel?.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        confirmBtn.addTarget(self, action: #selector(onTapConfirmBtn), for: .touchUpInside)
    }

    override func viewWillLayoutSubviews() {
    }
}

// MARK: 가입완료, 중복확인
extension InputNickNameViewController {
    @objc
    func onTapConfirmBtn() {
        //        logout()
        let demmyUserData: User = User(uid: "uid1", nickName: "ungchun", joinTime: 1, platForm: "apple", notification: true, notificationTime: 22)
        writeUserData(userData: demmyUserData)
    }
    func writeUserData(userData: User) {
        let docRef = database.document("user/2")
        docRef.setData(["uid": userData.uid, "nickName": userData.nickName, "joinTime": userData.joinTime, "platForm": userData.platForm, "notification": userData.notification, "notificationTime": userData.notificationTime])
        // 메인 페이지 이동
    }
    @objc
    func onTapOverlapCheck(_ gesture: UITapGestureRecognizer) {
        print("overlap tap")
        lazy var overLapValue = false
        if let text = nickNameTextField.text {
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
                if overLapValue {
                    // 닉네임 중복 o
                    self.nickNameTextField.addRedUnderLine()
                    self.nickNameTextField.setNeedsLayout()
                } else {
                    // 닉네임 중복 x
                    // Blue -> 원래 underline 색깔로 바꿔야함
                    self.nickNameTextField.addBlueUnderLine()
                    self.nickNameTextField.setNeedsLayout()
                }
            })
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
        bottomLine.backgroundColor = UIColor.red.cgColor
        self.borderStyle = UITextField.BorderStyle.none
        self.layer.addSublayer(bottomLine)
    }
    // 추후 삭제
    func addBlueUnderLine () {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: self.bounds.height + 10, width: self.bounds.width, height: 1)
        bottomLine.backgroundColor = UIColor.blue.cgColor
        self.borderStyle = UITextField.BorderStyle.none
        self.layer.addSublayer(bottomLine)
    }
}
