import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var googleLoginBtn: UIView!
    @IBOutlet weak var appleLoginBtn: UIView!
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
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
    }
    @objc
    func tapGoogleBtn(_ gesture: UITapGestureRecognizer) {
        // 같은 스토리보드 내에서 페이지이동
//        let inputNickNameVC = self.storyboard?.instantiateViewController(withIdentifier: "InputNickNameViewController")
        // 다른 스토리보드 페이지이동
        let storyboard: UIStoryboard = UIStoryboard(name: "MainPage", bundle: nil)
        let inputNickNameVC = storyboard.instantiateViewController(withIdentifier: "MainPageContainerViewController")
        inputNickNameVC.modalPresentationStyle = .fullScreen
        inputNickNameVC.modalTransitionStyle = .crossDissolve
        self.present(inputNickNameVC, animated: true, completion: nil)
    }
}
