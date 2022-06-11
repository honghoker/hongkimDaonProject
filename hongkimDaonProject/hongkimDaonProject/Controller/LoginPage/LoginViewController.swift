import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import FirebaseMessaging

class LoginViewController: UIViewController {
    let database = DatabaseManager.shared.fireStore
    var userFcmToken: String = ""
    private var currentNonce: String?
    @IBOutlet weak var googleLoginBtn: UIImageView!
    @IBOutlet weak var appleLoginBtn: UIImageView!
    @IBOutlet weak var appIconImageView: UIImageView!
    @IBOutlet weak var previewBtn: UIButton!
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
        setUI()
        appIconImageView.image = UIImage(named: "loginViewAppIcon")
    }
    override func viewDidAppear(_ animated: Bool) {
        if let user = AuthManager.shared.auth.currentUser {
            let docRef = self.database.document("user/\(user.uid)")
            docRef.getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: \(error.localizedDescription)")
                    return
                }
                guard let exist = snapshot?.exists else {return}
                if exist == true {
                    self.showMainViewController()
                }
            }
        }
    }
    func setUI() {
        self.googleLoginBtn.image = UIImage(named: "googleLoginBtn")
        self.googleLoginBtn.isUserInteractionEnabled = true
        self.appleLoginBtn.image = UIImage(named: "appleLoginBtn")
        self.appleLoginBtn.isUserInteractionEnabled = true
        // login btn click action
        let googleLoginClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGoogleBtn(_:)))
        self.googleLoginBtn.addGestureRecognizer(googleLoginClick)
        let appleLoginClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAppleBtn(_:)))
        self.appleLoginBtn.addGestureRecognizer(appleLoginClick)
        previewBtn.addTarget(self, action: #selector(showPreviewViewController), for: .touchUpInside)
    }
}

// MARK: Navigator
extension LoginViewController {
    func showMainViewController() {
        let storyboard: UIStoryboard = UIStoryboard(name: "MainPageView", bundle: nil)
        guard let mainViewController = storyboard.instantiateViewController(withIdentifier: "FirstMainPageContainerViewController") as? FirstMainPageContainerViewController else { return }
        // 화면 전환 애니메이션 설정
        mainViewController.modalTransitionStyle = .crossDissolve
        // 전환된 화면이 보여지는 방법 설정
        mainViewController.modalPresentationStyle = .fullScreen
        self.present(mainViewController, animated: true, completion: nil)
    }
    func showLoginViewController() {
        let storyboard: UIStoryboard = UIStoryboard(name: "LoginView", bundle: nil)
        guard let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
        loginViewController.modalTransitionStyle = .crossDissolve
        loginViewController.modalPresentationStyle = .fullScreen
        self.present(loginViewController, animated: true, completion: nil)
    }
    @objc
    func showPreviewViewController() {
        let storyboard: UIStoryboard = UIStoryboard(name: "PreviewView", bundle: nil)
        guard let PreviewViewController = storyboard.instantiateViewController(withIdentifier: "PreviewViewController") as? PreviewViewController else { return }
        PreviewViewController.modalTransitionStyle = .crossDissolve
        PreviewViewController.modalPresentationStyle = .fullScreen
        self.present(PreviewViewController, animated: true, completion: nil)
    }
}

// MARK: Google, Apple Login
extension LoginViewController {
    func writeUserData(userData: User) {
        let docRef = database.document("user/\(userData.uid)")
        docRef.setData(["uid": userData.uid, "joinTime": userData.joinTime, "platForm": userData.platForm, "notification": userData.notification, "notificationTime": userData.notificationTime, "fcmToken": userData.fcmToken]) { result in
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
    func tapGoogleBtn(_ gesture: UITapGestureRecognizer) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let signInConfig = GIDConfiguration.init(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            // 로그인 실패
            guard error == nil else { return }
            guard let authentication = user?.authentication else { return }
            // access token 부여 받음
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!, accessToken: authentication.accessToken)
            // 파베 인증정보 등록
            AuthManager.shared.auth.signIn(with: credential) {_, _ in
                // token을 넘겨주면, 성공했는지 안했는지에 대한 result값과 error값을 넘겨줌
                if let user = AuthManager.shared.auth.currentUser {
                    let docRef = self.database.document("user/\(user.uid)")
                    docRef.getDocument { snapshot, error in
                        if let error = error {
                            print("DEBUG: \(error.localizedDescription)")
                            return
                        }
                        guard let exist = snapshot?.exists else {return}
                        if exist == true {
                            self.showMainViewController()
                        } else {
                            let formatter = DateFormatter()
                            formatter.locale = Locale(identifier: "ko_KR")
                            formatter.dateFormat = "HH:mm"
                            let demmyUserData: User = User(uid: user.uid, joinTime: Int(Date().millisecondsSince1970), platForm: "google", notification: true, notificationTime: formatter.string(from: Date()), fcmToken: self.userFcmToken)
                            self.writeUserData(userData: demmyUserData)
                        }
                    }
                }
            }
        }
    }
    @objc
    func tapAppleBtn(_ gesture: UITapGestureRecognizer) {
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
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
}

extension LoginViewController: ASAuthorizationControllerDelegate {
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
            AuthManager.shared.auth.signIn(with: credential) { (authDataResult, error) in
                if let user = authDataResult?.user {
                    print("애플 로그인 성공", user.uid, user.email ?? "-")
                    let docRef = self.database.document("user/\(user.uid)")
                    docRef.getDocument { snapshot, error in
                        if let error = error {
                            print("DEBUG: \(error.localizedDescription)")
                            return
                        }
                        guard let exist = snapshot?.exists else {return}
                        if exist == true {
                            self.showMainViewController()
                        } else {
                            let formatter = DateFormatter()
                            formatter.locale = Locale(identifier: "ko_KR")
                            formatter.dateFormat = "HH:mm"
                            let demmyUserData: User = User(uid: user.uid, joinTime: Int(Date().millisecondsSince1970), platForm: "apple", notification: true, notificationTime: formatter.string(from: Date()), fcmToken: self.userFcmToken)
                            self.writeUserData(userData: demmyUserData)
                        }
                    }
                }
                if error != nil {
                    print(error?.localizedDescription ?? "error" as Any)
                    return
                }
            }
        }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
}
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
