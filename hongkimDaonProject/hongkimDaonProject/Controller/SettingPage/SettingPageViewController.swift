import UIKit
import Firebase
//import GoogleSignIn
import AuthenticationServices
import CryptoKit
import RealmSwift

class SettingPageViewController: UIViewController {
    private var currentNonce: String?
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(.init(systemName: "chevron.backward"), for: .normal)
        button.tintColor = .systemGray
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 50
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var notificationConfigButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapNotificationButton), for: .touchUpInside)
        button.setTitle("알림 설정", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        return button
    }()
    
    private lazy var darkModeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapDarkModeButton), for: .touchUpInside)
        button.setTitle("다크모드 설정", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        return button
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        return button
    }()
    
    private lazy var withdrawalButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapWithdrawal), for: .touchUpInside)
        button.setTitle("회원 탈퇴", for: .normal)
        // FIXME: Color - 247 152 149, #f79895
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        return button
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addView()
        setLayout()
        setupView()
    }
    
    private func addView() {
        [
            backButton,
            stackView
        ].forEach {
            view.addSubview($0)
        }
        
        [
            notificationConfigButton,
            darkModeButton,
            divider,
            logoutButton,
            withdrawalButton
        ].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    private func setLayout() {
        backButton.snp.makeConstraints {
            $0.top.left.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        divider.snp.makeConstraints {
            $0.width.equalTo(10)
            $0.height.equalTo(1)
        }
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(named: "bgColor")
    }
}

extension SettingPageViewController {
    @objc
    private func didTapDarkModeButton(_ gesture: UITapGestureRecognizer) {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first(where: {
                $0.activationState == .foregroundActive
            }) as? UIWindowScene,
            let window = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            return
        }
        
        let alert = UIAlertController(title: .none, message: .none, preferredStyle: .actionSheet)
        let lightMode = UIAlertAction(title: "주간모드", style: .default) { _ in
            window.overrideUserInterfaceStyle = .light
            UserDefaults.standard.set(false, forKey: "darkModeState")
        }
        let darkMode = UIAlertAction(title: "야간모드", style: .default) { _ in
            window.overrideUserInterfaceStyle = .dark
            UserDefaults.standard.set(true, forKey: "darkModeState")
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        [lightMode, darkMode, cancel].forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
    
    @objc
    private func showToast(msg: String?) {
        //        self.view.makeToast(msg, duration: 1.5, position: .bottom)
    }
    
    @objc
    private func didTapNotificationButton(_ gesture: UITapGestureRecognizer) {
        let vc = SetNotificationPageViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: false)
    }
    
    @objc
    private func didTapBackButton() {
        presentingViewController?.dismiss(animated: true)
    }
    
    @objc
    private func didTapLogout(_ gesture: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "로그아웃 하시겠습니까?", message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .default)
        let confirm = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            do {
                let firebaseAuth = AuthManager.shared.auth
                try firebaseAuth.signOut()
                
                let vc = LoginViewController()
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true)
            } catch _ as NSError {
                self?.showToast(msg: "로그아웃이 실패했습니다.")
            }
        }
        [cancel, confirm].forEach { alert.addAction($0) }
        alert.preferredAction = confirm
        present(alert, animated: true)
    }
    
    @objc
    private func didTapWithdrawal(_ gesture: UITapGestureRecognizer) {
        let alert = UIAlertController(
            title: "회원탈퇴 하시겠습니까?",
            message: "[탈퇴 시 주의사항]\n나의 일기, 나의 보관함에 저장된 데이터가 모두 사라지며 복구가 불가능합니다",
            preferredStyle: .alert
        )
        
        let withdrawal = UIAlertAction(title: "탈퇴", style: .default) { [weak self] _ in
            self?.withdrawal { result in
                switch result {
                case .success:
                    self?.appExit()
                case .failure(let error):
                    guard let error = error as? AuthErrors else {
                        self?.showToast(msg: "회원탈퇴에 실패했습니다.")
                        return
                    }
                    self?.showToast(msg: error.errorDescription)
                }
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .default)
        
        [cancel, withdrawal].forEach { alert.addAction($0) }
        alert.preferredAction = withdrawal
        present(alert, animated: true)
    }
    
    private func withdrawal(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = AuthManager.shared.auth.currentUser else { return completion(.failure(AuthErrors.currentUserNotExist)) }
        //        currentUser.delete { error in
        //            guard let error = error as? NSError else {
        //                self.successToWithdrawal(currentUser.uid)
        //                return completion(.success(()))
        //            }
        //            switch AuthErrorCode(rawValue: error.code) {
        //            case .requiresRecentLogin:
        //                let alert = UIAlertController(title: "사용자 정보가 만료되었습니다.",
        //                                              message: "탈퇴하려는 사용자의 계정으로 다시 로그인해주세요.", preferredStyle: UIAlertController.Style.alert)
        //                alert.addAction(UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: { _ in
        //                }))
        //                alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: { _ in
        //                    guard !currentUser.providerData.isEmpty else { return completion(.failure(AuthErrors.failedToWithdrawal)) }
        //                    for userInfo in currentUser.providerData {
        //                        switch userInfo.providerID {
        //                        case "google.com":
        //                            guard let clientID = FirebaseApp.app()?.options.clientID else { return completion(.failure(AuthErrors.failedToWithdrawal)) }
        //                            let signInConfig = GIDConfiguration.init(clientID: clientID)
        //                            GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
        //                                guard error == nil else { return completion(.failure(AuthErrors.failedToSignIn)) }
        //                                guard let authentication = user?.authentication else { return completion(.failure(AuthErrors.failedToWithdrawal)) }
        //                                guard currentUser.email == user?.profile?.email && currentUser.displayName == user?.profile?.name else {
        //                                    return completion(.failure(AuthErrors.notEqualUser))
        //                                }
        //                                let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!, accessToken: authentication.accessToken)
        //                                currentUser.reauthenticate(with: credential) { _, error in
        //                                    guard error == nil else { return completion(.failure(AuthErrors.failedToWithdrawal)) }
        //                                    currentUser.delete { error in
        //                                        guard error == nil else { return completion(.failure(AuthErrors.failedToWithdrawal)) }
        //                                        self.successToWithdrawal(currentUser.uid)
        //                                        completion(.success(()))
        //                                    }
        //                                }
        //                            }
        //                        case "apple.com":
        //                            let request = self.createAppleIDRequest()
        //                            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        //                            authorizationController.delegate = self
        //                            authorizationController.presentationContextProvider = self
        //                            authorizationController.performRequests()
        //                        default:
        //                            print("not exist ProviderId")
        //                        }
        //                    }
        //                }))
        //                self.present(alert, animated: true, completion: nil)
        //            default:
        //                completion(.failure(AuthErrors.failedToWithdrawal))
        //            }
        //        }
    }
    
    private func successToWithdrawal(_ uid: String) {
        // MARK: realm 데이터 삭제
        try? FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
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
                currentUser.reauthenticate(with: credential) { [weak self] (authResult, error) in
                    guard error == nil else { return }
                    currentUser.delete { error in
                        guard error == nil else {
                            self?.showToast(msg: "회원탈퇴에 실패했습니다.")
                            return
                        }
                        self?.appExit()
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
