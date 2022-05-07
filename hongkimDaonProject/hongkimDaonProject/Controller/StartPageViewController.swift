import UIKit
import FirebaseAuth
import FirebaseFirestore
import Lottie

class StartPageViewController: UIViewController {
    let database = Firestore.firestore()
    var animationView: AnimationView = {
        let lottieView = AnimationView(name: "lottieFile")
        lottieView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        lottieView.contentMode = .scaleAspectFill
        return lottieView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        animationView.center = CGPoint(x: view.frame.size.width  / 2, y: view.frame.size.height / 2.3)
        //        animationView.center = view.center
        animationView.loopMode = .playOnce
        view.addSubview(animationView)
        animationView.play {(finish) in
            self.animationView.play()
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
                        self.animationView.removeFromSuperview()
                        self.showMainViewController()
                    } else {
                        self.animationView.removeFromSuperview()
                        self.showLoginViewController()
                    }
                }
            } else {
                self.animationView.removeFromSuperview()
                self.showLoginViewController()
            }
        }
    }
    // 일단 요거 지우지말고 대기
    override func viewDidAppear(_ animated: Bool) {
        //        if let user = Auth.auth().currentUser {
        //            print("view user \(user.uid)")
        //            let docRef = self.database.document("user/\(user.uid)")
        //            docRef.getDocument { snapshot, error in
        //                if let error = error {
        //                    print("DEBUG: \(error.localizedDescription)")
        //                    return
        //                }
        //                guard let exist = snapshot?.exists else {return}
        //                if exist == true {
        //                    sleep(1)
        //                    self.animationView.stop()
        //                    self.showMainViewController()
        //                } else {
        //                    sleep(1)
        //                    self.animationView.stop()
        //                    self.showLoginViewController()
        //                }
        //            }
        //        } else {
        //            sleep(1)
        //            self.animationView.stop()
        //            self.showLoginViewController()
        //        }
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
