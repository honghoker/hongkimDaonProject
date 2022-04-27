import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {
    let database = Firestore.firestore()
    private var currentNonce: String?
    @IBOutlet weak var googleLoginBtn: UIImageView!
    @IBOutlet weak var appleLoginBtn: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        googleLoginBtn.image = UIImage(named: "googleLoginBtn")
        googleLoginBtn.isUserInteractionEnabled = true
        appleLoginBtn.image = UIImage(named: "appleLoginBtn")
        appleLoginBtn.isUserInteractionEnabled = true
        // login btn click action
        let googleLoginClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGoogleBtn(_:)))
        googleLoginBtn.addGestureRecognizer(googleLoginClick)
        let appleLoginClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAppleBtn(_:)))
        appleLoginBtn.addGestureRecognizer(appleLoginClick)
    }
    override func viewDidAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser {
            let docRef = self.database.document("user/\(user.uid)")
            guard let platFormCheck = user.email?.contains("gmail") else { return }
            let platForm = platFormCheck == true ? "google" : "apple"
            docRef.getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: \(error.localizedDescription)")
                    return
                }
                guard let exist = snapshot?.exists else {return}
                if exist == true {
                    print("login view exist")
                    self.showMainViewController()
                } else {
                    self.showInputNickNameViewController(userUid: user.uid, platForm: platForm)
                }
            }
        }
    }
}

// MARK: Navigator
extension LoginViewController {
    func showMainViewController() {
        let storyboard: UIStoryboard = UIStoryboard(name: "MainPageView", bundle: nil)
        guard let mainViewController = storyboard.instantiateViewController(withIdentifier: "FirstMainPageContainerViewController") as? FirstMainPageContainerViewController else { return }
        // MARK: 화면 전환 애니메이션 설정
        mainViewController.modalTransitionStyle = .crossDissolve
        // MARK: 전환된 화면이 보여지는 방법 설정
        mainViewController.modalPresentationStyle = .fullScreen
        self.present(mainViewController, animated: true, completion: nil)
    }
    func showInputNickNameViewController(userUid: String, platForm: String) {
        let storyboard: UIStoryboard = UIStoryboard(name: "LoginView", bundle: nil)
        guard let inputNickNameController = storyboard.instantiateViewController(withIdentifier: "InputNickNameViewController") as? InputNickNameViewController else { return }
        inputNickNameController.userUid = userUid
        inputNickNameController.platForm = platForm
        // MARK: 화면 전환 애니메이션 설정
        inputNickNameController.modalTransitionStyle = .crossDissolve
        // MARK: 전환된 화면이 보여지는 방법 설정
        inputNickNameController.modalPresentationStyle = .fullScreen
        self.present(inputNickNameController, animated: true, completion: nil)
        }
}

// MARK: Google, Apple Login
extension LoginViewController {
    @objc
    func tapGoogleBtn(_ gesture: UITapGestureRecognizer) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let signInConfig = GIDConfiguration.init(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return } // 로그인 실패
            guard let authentication = user?.authentication else { return }
            // access token 부여 받음
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!, accessToken: authentication.accessToken)
            // 파베 인증정보 등록
            Auth.auth().signIn(with: credential) {_, _ in
                // token을 넘겨주면, 성공했는지 안했는지에 대한 result값과 error값을 넘겨줌
                if let user = Auth.auth().currentUser {
                    print("user : \(user.uid)")
                    guard let platFormCheck = user.email?.contains("gmail") else { return }
                    let platForm = platFormCheck == true ? "google" : "apple"
                    let docRef = self.database.document("user/\(user.uid)")
                    docRef.getDocument { snapshot, error in
                        if let error = error {
                            print("DEBUG: \(error.localizedDescription)")
                            return
                        }
                        guard let exist = snapshot?.exists else {return}
                        print("snapshot?.exists \(exist)")
                        if exist == true {
                            self.showMainViewController()
                        } else {
                            self.showInputNickNameViewController(userUid: user.uid, platForm: platForm)
                            //                            self.showMainViewController()
                        }
                    }
                }
            }
        }
    }
    @objc
    func tapAppleBtn(_ gesture: UITapGestureRecognizer) {
        print("apple tap")
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
        print("ASAuthorization ASAuthorization ASAuthorization")
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
            Auth.auth().signIn(with: credential) { (authDataResult, error) in
                if let user = authDataResult?.user {
                    print("애플 로그인 성공", user.uid, user.email ?? "-")
                    self.showMainViewController()
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

// MARK: RandomNonceString
extension LoginViewController {
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            randoms.forEach { random in
                if length == 0 {
                    return
                }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
}
