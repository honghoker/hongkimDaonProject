import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import Toast_Swift
import RealmSwift

class SettingPageViewController: UIViewController {
    let defaults = UserDefaults.standard
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var notificationConfigBtn: UILabel!
    @IBOutlet weak var logoutBtn: UILabel!
    @IBOutlet weak var withdrawalBtn: UILabel!
    @IBOutlet weak var setDarkModeBtn: UILabel!
    private var currentNonce: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "bgColor")
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
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
    func showToast(msg: String?) {
        self.view.makeToast(msg, duration: 1.5, position: .bottom)
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
            } catch _ as NSError {
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
            self.withdrawal { [weak self] result in
                switch result {
                case .success:
                    // MARK: 탈퇴 성공 시 앱 종료
                    self?.appExit()
                case .failure(let error):
                    guard let error = error as? AuthErrors else {
                        self?.showToast(msg: "회원탈퇴에 실패했습니다.")
                        return
                    }
                    self?.showToast(msg: error.errorDescription)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func withdrawal(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = AuthManager.shared.auth.currentUser else { return completion(.failure(AuthErrors.currentUserNotExist)) }
        currentUser.delete { error in
            guard let error = error as? NSError else {
                self.successToWithdrawal(currentUser.uid)
                return completion(.success(()))
            }
            switch AuthErrorCode(rawValue: error.code) {
            case .requiresRecentLogin:
                let alert = UIAlertController(title: "사용자 정보가 만료되었습니다.",
                                              message: "탈퇴하려는 사용자의 계정으로 다시 로그인해주세요.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: { _ in
                }))
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: { _ in
                    guard !currentUser.providerData.isEmpty else { return completion(.failure(AuthErrors.failedToWithdrawal)) }
                    for userInfo in currentUser.providerData {
                        switch userInfo.providerID {
                        case "google.com":
                            guard let clientID = FirebaseApp.app()?.options.clientID else { return completion(.failure(AuthErrors.failedToWithdrawal)) }
                            let signInConfig = GIDConfiguration.init(clientID: clientID)
                            GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
                                guard error == nil else { return completion(.failure(AuthErrors.failedToSignIn)) }
                                guard let authentication = user?.authentication else { return completion(.failure(AuthErrors.failedToWithdrawal)) }
                                guard currentUser.email == user?.profile?.email && currentUser.displayName == user?.profile?.name else {
                                    return completion(.failure(AuthErrors.notEqualUser))
                                }
                                let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!, accessToken: authentication.accessToken)
                                currentUser.reauthenticate(with: credential) { _, error in
                                    guard error == nil else { return completion(.failure(AuthErrors.failedToWithdrawal)) }
                                    currentUser.delete { error in
                                        guard error == nil else { return completion(.failure(AuthErrors.failedToWithdrawal)) }
                                        self.successToWithdrawal(currentUser.uid)
                                        completion(.success(()))
                                    }
                                }
                            }
                        case "apple.com":
                            let request = self.createAppleIDRequest()
                            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
                            authorizationController.delegate = self
                            authorizationController.presentationContextProvider = self
                            authorizationController.performRequests()
                        default:
                            print("not exist ProviderId")
                        }
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            default:
                completion(.failure(AuthErrors.failedToWithdrawal))
            }
        }
    }
    private func successToWithdrawal(_ uid: String) {
        // MARK: realm 데이터 삭제
        try? FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
    }
    @available(iOS 13, *)
    func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        // 애플로그인은 사용자에게서 2가지 정보를 요구함
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        return request
    }
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        return hashString
    }
    private func appExit() {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { exit(0) }
    }
}

extension SettingPageViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDtoken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDtoken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDtoken.debugDescription)")
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            if let currentUser = AuthManager.shared.auth.currentUser {
                currentUser.reauthenticate(with: credential) { (authResult, error) in
                    guard error == nil else { return }
                    currentUser.delete { error in
                        guard error == nil else {
                            self.showToast(msg: "회원탈퇴에 실패했습니다.")
                            return
                        }
                        self.appExit()
                    }
                }
            }
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
}
extension SettingPageViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
