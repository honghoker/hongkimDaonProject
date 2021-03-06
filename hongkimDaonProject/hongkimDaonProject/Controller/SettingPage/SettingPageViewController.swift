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
        let lightMode = UIAlertAction(title: "????????????", style: .default) {(action) in
            if let window = UIApplication.shared.windows.first {
                if #available(iOS 13.0, *) {
                    window.overrideUserInterfaceStyle = .light
                    self.defaults.set(false, forKey: "darkModeState")
                }
            }
        }
        let darkMode = UIAlertAction(title: "????????????", style: .default) {(action) in
            if let window = UIApplication.shared.windows.first {
                if #available(iOS 13.0, *) {
                    window.overrideUserInterfaceStyle = .dark
                    self.defaults.set(true, forKey: "darkModeState")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "??????", style: .cancel) {(action) in
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
        let alert = UIAlertController(title: "???????????? ???????????????????", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "??????", style: UIAlertAction.Style.default, handler: { _ in
            // Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "??????",
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
            do {
                let firebaseAuth = AuthManager.shared.auth
                try firebaseAuth.signOut()
                let storyboard: UIStoryboard = UIStoryboard(name: "LoginView", bundle: nil)
                guard let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
                // MARK: ?????? ?????? ??????????????? ??????
                loginViewController.modalTransitionStyle = .crossDissolve
                // MARK: ????????? ????????? ???????????? ?????? ??????
                loginViewController.modalPresentationStyle = .fullScreen
                self.present(loginViewController, animated: true, completion: nil)
            } catch let signOutError as NSError {
                self.showToast(msg: "??????????????? ??????????????????.")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @objc
    func withdrawal(_ gesture: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "???????????? ???????????????????",
                                      message: "[?????? ??? ????????????]\n?????? ??????, ?????? ???????????? ????????? ???????????? ?????? ???????????? ????????? ??????????????????", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "??????", style: UIAlertAction.Style.default, handler: { _ in
        }))
        alert.addAction(UIAlertAction(title: "??????",
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
            self.withdrawal { result in
                switch result {
                case .success:
                    // MARK: ?????? ?????? ??? ??? ??????
                    self.appExit()
                case .failure(let error):
                    switch error as? AuthErros {
                    case .failedToSignIn:
                        self.showToast(msg: "???????????? ??????????????????.")
                    case .currentUserNotExist:
                        self.showToast(msg: "????????? ????????? ??????????????? ??????????????????.")
                    case .notEqualUser:
                        self.showToast(msg: "??????????????? ??????????????????.\n?????? ???????????? ????????? ?????? ???????????????.")
                    case .failedToWithdrawal:
                        self.showToast(msg: "??????????????? ??????????????????.")
                    default:
                        self.showToast(msg: "??????????????? ??????????????????.")
                    }
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func withdrawal(completion: @escaping (Result<String, Error>) -> Void) {
        if let currentUser = AuthManager.shared.auth.currentUser {
            let uid = currentUser.uid
            currentUser.delete { error in
                if let error = error as? NSError {
                    switch AuthErrorCode(rawValue: error.code) {
                    case .requiresRecentLogin:
                        let alert = UIAlertController(title: "????????? ????????? ?????????????????????.",
                                                      message: "??????????????? ???????????? ???????????? ?????? ?????????????????????.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "??????", style: UIAlertAction.Style.default, handler: { _ in
                        }))
                        alert.addAction(UIAlertAction(title: "??????", style: UIAlertAction.Style.default, handler: { _ in
                            if currentUser.providerData.isEmpty != true {
                                for userInfo in currentUser.providerData {
                                    switch userInfo.providerID {
                                    case "google.com":
                                        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                                        let signInConfig = GIDConfiguration.init(clientID: clientID)
                                        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
                                            guard error == nil else {
                                                completion(.failure(AuthErros.failedToSignIn))
                                                return
                                            }
                                            guard let authentication = user?.authentication else { return }
                                            if currentUser.email == user?.profile?.email && currentUser.displayName == user?.profile?.name {
                                                let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!, accessToken: authentication.accessToken)
                                                currentUser.reauthenticate(with: credential) { result, error in
                                                    guard error == nil else {
                                                        completion(.failure(AuthErros.failedToWithdrawal))
                                                        return
                                                    }
                                                    currentUser.delete { error in
                                                        guard error == nil else {
                                                            completion(.failure(AuthErros.failedToWithdrawal))
                                                            return
                                                        }
                                                        self.successToWithdrawal(uid)
                                                        completion(.success(""))
                                                    }
                                                }
                                            } else {
                                                completion(.failure(AuthErros.notEqualUser))
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
                            }
                        }))
                        self.present(alert, animated: true, completion: nil)
                    default:
                        completion(.failure(AuthErros.failedToWithdrawal))
                    }
                } else {
                    self.successToWithdrawal(uid)
                    completion(.success(""))
                }
            }
        } else {
            self.view.makeToast("???????????? ????????? ??????????????????.", duration: 1.5, position: .bottom)
        }
    }
    private func successToWithdrawal(_ uid: String) {
        // MARK: realm ????????? ??????
        try? FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
    }
    @available(iOS 13, *)
    func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        // ?????????????????? ?????????????????? 2?????? ????????? ?????????
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
                            self.showToast(msg: "??????????????? ??????????????????.")
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
