import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import Toast_Swift
import RealmSwift

class SettingPageViewController: UIViewController, withdrawalProtocol {
    let defaults = UserDefaults.standard
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var nickNameChangeBtn: UILabel!
    @IBOutlet weak var notificationConfigBtn: UILabel!
    @IBOutlet weak var logoutBtn: UILabel!
    @IBOutlet weak var withdrawalBtn: UILabel!
    @IBOutlet weak var setDarkModeBtn: UILabel!
    var nickNameChangeChk: Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "bgColor")
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        let nickNameChangeBtnClicked: UITapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(nickName(_:)))
        nickNameChangeBtn.isUserInteractionEnabled = true
        nickNameChangeBtn.addGestureRecognizer(nickNameChangeBtnClicked)
        let logoutBtnClicked: UITapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(logout(_:)))
        logoutBtn.isUserInteractionEnabled = true
        logoutBtn.addGestureRecognizer(logoutBtnClicked)
        let withdrawalBtnClicked: UITapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(withdrawal(_:)))
        withdrawalBtn.isUserInteractionEnabled = true
        withdrawalBtn.addGestureRecognizer(withdrawalBtnClicked)
        let setNotificationClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapSetNotification(_:)))
        notificationConfigBtn.isUserInteractionEnabled = true
        notificationConfigBtn.addGestureRecognizer(setNotificationClick)
        let setDarkModeClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapDarkModeClick(_:)))
        setDarkModeBtn.isUserInteractionEnabled = true
        setDarkModeBtn.addGestureRecognizer(setDarkModeClick)
    }
    override func viewWillAppear(_ animated: Bool) {
        // MARK: 닉네임 변경 토스트 처리
        if let chk = nickNameChangeChk {
            if chk == true {
                self.view.makeToast("닉네임이 변경되었습니다.", duration: 1.5, position: .bottom)
                nickNameChangeChk = nil
            }
        }
    }
}

extension SettingPageViewController {
    @objc
    func onTapDarkModeClick(_ gesture: UITapGestureRecognizer) {
        let alert = UIAlertController(title: .none, message: .none, preferredStyle: .actionSheet)
        let lightMode = UIAlertAction(title: "주간모드", style: .default) {(action) in
            if let window = UIApplication.shared.windows.first {
                if #available(iOS 13.0, *) {
                    window.overrideUserInterfaceStyle = .light
                    self.defaults.set(false, forKey: "darkModeState")
                }
            }
        }
        let darkMode = UIAlertAction(title: "야간모드", style: .default) {(action) in
            if let window = UIApplication.shared.windows.first {
                if #available(iOS 13.0, *) {
                    window.overrideUserInterfaceStyle = .dark
                    self.defaults.set(true, forKey: "darkModeState")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) {(action) in
            print("cancel")
        }
        alert.addAction(lightMode)
        alert.addAction(darkMode)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    @objc
    func showToast(msg: String) {
        self.view.makeToast(msg, duration: 1.5, position: .bottom)
    }
    @objc
    func nickName(_ gesture: UITapGestureRecognizer) {
        // MARK: 닉네임 변경 페이지 이동
        guard let changeNickNameVC = self.storyboard?.instantiateViewController(identifier: "ChangeNickNameViewController") as? ChangeNickNameViewController else {
            return
        }
        changeNickNameVC.modalPresentationStyle = .fullScreen
        self.present(changeNickNameVC, animated: false, completion: nil)
    }
    @objc
    func onTapSetNotification(_ gesture: UITapGestureRecognizer) {
        guard let nextView = self.storyboard?.instantiateViewController(identifier: "SetNotificationPageViewController") as? SetNotificationPageViewController else {
            return
        }
        nextView.modalPresentationStyle = .fullScreen
        self.present(nextView, animated: false, completion: nil)
    }
    @objc
    func back() {
        self.presentingViewController?.dismiss(animated: true)
    }
    @objc
    func logout(_ gesture: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "로그아웃 하시겠습니까?", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: { _ in
            // Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "확인",
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
            do {
                let firebaseAuth = AuthManager.shared.auth
                try firebaseAuth.signOut()
                let storyboard: UIStoryboard = UIStoryboard(name: "LoginView", bundle: nil)
                guard let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
                // MARK: 화면 전환 애니메이션 설정
                loginViewController.modalTransitionStyle = .crossDissolve
                // MARK: 전환된 화면이 보여지는 방법 설정
                loginViewController.modalPresentationStyle = .fullScreen
                self.present(loginViewController, animated: true, completion: nil)
                //                GIDSignIn.sharedInstance.signOut()
                print("@@@@@@@@ logout complete")
            } catch let signOutError as NSError {
                print("ERROR: signOutError \(signOutError.localizedDescription)")
                self.showToast(msg: "로그아웃이 실패했습니다.")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @objc
    func withdrawal(_ gesture: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "회원탈퇴 하시겠습니까?",
                                      message: "[탈퇴 시 주의사항]\n나의 일기, 나의 보관함에 저장된 데이터가 모두 사라지며 복구가 불가능합니다", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: { _ in
        }))
        alert.addAction(UIAlertAction(title: "탈퇴",
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
            self.withdrawal { result in
                switch result {
                case .success:
                    // MARK: 토스트 처리 필요
                    self.showToast(msg: "회원탈퇴에 성공했습니다.")
                    print("@@@@@@@@ withdrawal success")
                    self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                case .failure(let error):
                    switch error as? AuthErros {
                    case .failedToSignIn:
                        self.showToast(msg: "로그인에 실패했습니다.")
                    case .currentUserNotExist:
                        self.showToast(msg: "사용자 정보를 가져오는데 실패했습니다.")
                    case .notEqualUser:
                        self.showToast(msg: "회원탈퇴가 실패했습니다.\n현재 로그인한 계정과 다른 계정입니다.")
                    case .failedToWithdrawal:
                        self.showToast(msg: "회원탈퇴에 실패했습니다.")
                    default:
                        self.showToast(msg: "회원탈퇴에 실패했습니다.")
                    }
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
