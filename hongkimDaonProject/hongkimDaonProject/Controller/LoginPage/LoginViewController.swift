import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices
import CryptoKit // 해시 값 추가

class LoginViewController: UIViewController {
    @IBOutlet weak var googleLoginBtn: UIView!
    @IBOutlet weak var appleLoginBtn: UIView!
    private var currentNonce: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        // googleLoginBtn
        googleLoginBtn.layer.borderColor = UIColor.black.cgColor
        googleLoginBtn.layer.backgroundColor = .none
        googleLoginBtn.layer.borderWidth = 1
        googleLoginBtn.layer.cornerRadius = 24
        // appleLoginBtn
        appleLoginBtn.layer.borderColor = UIColor.black.cgColor
        appleLoginBtn.layer.backgroundColor = .none
        appleLoginBtn.layer.borderWidth = 1
        appleLoginBtn.layer.cornerRadius = 24
        let googleLoginClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGoogleBtn(_:)))
        googleLoginBtn.addGestureRecognizer(googleLoginClick)
    }
    override func viewDidAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser {
            print("@@@@@@@@@ 로그인 성공 user : \(user.uid)")
            showMainViewController()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    private func showMainViewController() {
        // MARK: 로그인 후 메인페이지 이동
        let storyboard = UIStoryboard(name: "MainPageView", bundle: Bundle.main)
        let mainViewController = storyboard.instantiateViewController(identifier: "MainPageContainerViewController")
        mainViewController.modalPresentationStyle = .fullScreen
        UIApplication.shared.windows.first?.rootViewController?.show(mainViewController, sender: nil)
    }
}
extension LoginViewController {
    @objc
    func tapGoogleBtn(_ gesture: UITapGestureRecognizer) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let signInConfig = GIDConfiguration.init(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard error == nil else { return } // 로그인 실패
            guard let authentication = user?.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!, accessToken: authentication.accessToken)
            // access token 부여 받음
            // 파베 인증정보 등록
            Auth.auth().signIn(with: credential) {_, _ in
                // token을 넘겨주면, 성공했는지 안했는지에 대한 result값과 error값을 넘겨줌
                self.showMainViewController()
            }
        }
    }
}
