import UIKit
import Firebase
//import GoogleSignIn
import AuthenticationServices
import CryptoKit
import FirebaseMessaging

class LoginViewController: UIViewController {
    private let database = DatabaseManager.shared.fireStore
    private var userFcmToken: String = ""
    private var currentNonce: String?
    
    private let appIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "loginViewAppIcon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "다온"
        label.font = UIFont(name: "JejuMyeongjoOTF", size: 36)
        label.textColor = .label
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "좋은 일이 다오는,"
        label.font = UIFont(name: "JejuMyeongjoOTF", size: 20)
        label.textColor = .label
        return label
    }()
    
    private let dividerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.axis = .horizontal
        return stackView
    }()
    
    private let leftDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let snsLoginLabel: UILabel = {
        let label = UILabel()
        label.text = "SNS 로그인"
        label.font = UIFont(name: "JejuMyeongjoOTF", size: 12)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let rightDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let loginButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 48
        stackView.axis = .horizontal
        return stackView
    }()
    
    private lazy var googleLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "googleLoginBtn"), for: .normal)
        button.addTarget(self, action: #selector(didTapGoogleLoginButton), for: .touchUpInside)
        return button
    }()

    private lazy var appleLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "appleLoginBtn"), for: .normal)
        button.addTarget(self, action: #selector(didTapAppleLoginButton), for: .touchUpInside)
        return button
    }()

    private lazy var previewButton: UIButton = {
        let button = UIButton()
        button.setTitle("오늘의 글 미리보기", for: .normal)
        button.setTitleColor(.systemGray, for: .normal)
        button.titleLabel?.font = UIFont(name: "JejuMyeongjoOTF", size: 12)
        button.addTarget(self, action: #selector(didTapPreviewButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addView()
        setLayout()
        setupView()
        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                self.userFcmToken = token
                print("FCM registration token: \(token)")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let user = AuthManager.shared.auth.currentUser {
            let docRef = self.database.document("user/\(user.uid)")
            docRef.getDocument { snapshot, error in
                if let error = error {
                    debugPrint("DEBUG: \(error.localizedDescription)")
                    return
                }
                guard let exist = snapshot?.exists else {return}
                if exist == true {
                    self.showMainViewController()
                }
            }
        }
    }
    
    private func addView() {
        [
            leftDivider,
            snsLoginLabel,
            rightDivider
        ].forEach {
            dividerStackView.addArrangedSubview($0)
        }
        
        [
            googleLoginButton,
            appleLoginButton
        ].forEach {
            loginButtonStackView.addArrangedSubview($0)
        }
        
        [
            appIconImageView,
            subtitleLabel,
            titleLabel,
            dividerStackView,
            loginButtonStackView,
            previewButton
        ].forEach {
            view.addSubview($0)
        }
    }
    
    private func setLayout() {
        appIconImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(140)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(100)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(appIconImageView.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
        }
        
        [leftDivider, rightDivider].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(1)
            }
        }
        
        dividerStackView.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(40)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(32)
        }
        
        [googleLoginButton, appleLoginButton].forEach {
            $0.snp.makeConstraints {
                $0.size.equalTo(48)
            }
        }
        
        loginButtonStackView.snp.makeConstraints {
            $0.top.equalTo(dividerStackView.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
        }
        
        previewButton.snp.makeConstraints {
            $0.top.equalTo(loginButtonStackView.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(50)
        }
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(named: "bgColor")
    }
}

// MARK: Navigator
extension LoginViewController {
    func showMainViewController() {
		let mainViewController = FirstMainPageContainerViewController()
        // 화면 전환 애니메이션 설정
        mainViewController.modalTransitionStyle = .crossDissolve
        // 전환된 화면이 보여지는 방법 설정
        mainViewController.modalPresentationStyle = .fullScreen
        self.present(mainViewController, animated: true, completion: nil)
    }
    
    @objc private func didTapPreviewButton() {
        let vc = PreviewViewController()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

// MARK: Google, Apple Login
extension LoginViewController {
    private func writeUserData(userData: User) {
        let docRef = database.document("user/\(userData.uid)")
        docRef.setData(["uid": userData.uid, "joinTime": userData.joinTime, "platForm": userData.platForm, "notification": userData.notification, "notificationTime": userData.notificationTime, "fcmToken": userData.fcmToken]) { result in
            guard result == nil else {
                print("데이터 저장 실패")
                return
            }
        }
        // 가입 성공 후 메인 페이지 이동
		let mainViewController = FirstMainPageContainerViewController()
        // 화면 전환 애니메이션 설정
        mainViewController.modalTransitionStyle = .crossDissolve
        // 전환된 화면이 보여지는 방법 설정
        mainViewController.modalPresentationStyle = .fullScreen
        self.present(mainViewController, animated: true, completion: nil)
    }
    
    @objc private func didTapGoogleLoginButton(_ gesture: UITapGestureRecognizer) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
//        let signInConfig = GIDConfiguration.init(clientID: clientID)
//        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
//            // 로그인 실패
//            guard error == nil else { return }
//            guard let authentication = user?.authentication else { return }
//            // access token 부여 받음
//            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!, accessToken: authentication.accessToken)
//            // 파베 인증정보 등록
//            AuthManager.shared.auth.signIn(with: credential) {_, _ in
//                // token을 넘겨주면, 성공했는지 안했는지에 대한 result값과 error값을 넘겨줌
//                if let user = AuthManager.shared.auth.currentUser {
//                    let docRef = self.database.document("user/\(user.uid)")
//                    docRef.getDocument { snapshot, error in
//                        if let error = error {
//                            print("DEBUG: \(error.localizedDescription)")
//                            return
//                        }
//                        guard let exist = snapshot?.exists else {return}
//                        if exist == true {
//                            self.showMainViewController()
//                        } else {
//                            let formatter = DateFormatter()
//                            formatter.locale = Locale(identifier: "ko_KR")
//                            formatter.dateFormat = "HH:mm"
//                            let demmyUserData: User = User(uid: user.uid, joinTime: Int(Date().millisecondsSince1970), platForm: "google", notification: true, notificationTime: formatter.string(from: Date()), fcmToken: self.userFcmToken)
//                            self.writeUserData(userData: demmyUserData)
//                        }
//                    }
//                }
//            }
//        }
    }
    @objc private func didTapAppleLoginButton(_ gesture: UITapGestureRecognizer) {
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        // 애플로그인은 사용자에게서 2가지 정보를 요구함
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        return request
    }
    
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
