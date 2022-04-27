import UIKit
import FirebaseAuth
import FirebaseFirestore

class StartPageViewController: UIViewController {
    let database = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("start viewLoad")
    }
    override func viewDidAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser {
            print("view user \(user.uid)")
            let docRef = self.database.document("user/\(user.uid)")
            docRef.getDocument { snapshot, error in
                if let error = error {
                    print("DEBUG: \(error.localizedDescription)")
                    return
                }
                guard let exist = snapshot?.exists else {return}
                if exist == true {
                    sleep(1)
                    self.showMainViewController()
                } else {
                    sleep(1)
                    self.showLoginViewController()
                }
            }
        } else {
            sleep(1)
            self.showLoginViewController()
        }
    }
}

// MARK: Navigator
extension StartPageViewController {
    func showLoginViewController() {
        let storyboard: UIStoryboard = UIStoryboard(name: "LoginView", bundle: nil)
        guard let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
        // MARK: 화면 전환 애니메이션 설정
        loginViewController.modalTransitionStyle = .crossDissolve
        // MARK: 전환된 화면이 보여지는 방법 설정
        loginViewController.modalPresentationStyle = .fullScreen
        self.present(loginViewController, animated: true, completion: nil)
        //        let storyboard = UIStoryboard(name: "LoginView", bundle: Bundle.main)
        //        let loginViewController = storyboard.instantiateViewController(identifier: "LoginViewController")
        //        loginViewController.modalPresentationStyle = .fullScreen
        //        UIApplication.shared.windows.first?.rootViewController?.show(loginViewController, sender: nil)
    }
    func showMainViewController() {
        let storyboard: UIStoryboard = UIStoryboard(name: "MainPageView", bundle: nil)
        guard let mainViewController = storyboard.instantiateViewController(withIdentifier: "FirstMainPageContainerViewController") as? FirstMainPageContainerViewController else { return }
        // MARK: 화면 전환 애니메이션 설정
        mainViewController.modalTransitionStyle = .crossDissolve
        // MARK: 전환된 화면이 보여지는 방법 설정
        mainViewController.modalPresentationStyle = .fullScreen
        self.present(mainViewController, animated: true, completion: nil)
    }
}
