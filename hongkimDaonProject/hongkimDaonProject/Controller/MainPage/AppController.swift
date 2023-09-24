import UIKit
import Firebase

extension Notification.Name {
    static let authStateDidChange = NSNotification.Name("authStateDidChange")
}

final class AppController {
    static let shared = AppController()
    private init() {
        FirebaseApp.configure() // Firebase 초기화
    }
    private var window: UIWindow!
    private var rootViewController: UIViewController? {
        didSet {
            window.rootViewController = rootViewController
        }
    }
    func show(in window: UIWindow) {
        self.window = window
        window.backgroundColor = .systemBackground
        window.makeKeyAndVisible()
        checkLoginIn()
    }
    @objc private func checkLoginIn() {
        if let _ = AuthManager.shared.auth.currentUser { // <- Firebase Auth
            setHome()
        } else {
            routeToLogin()
        }
    }
    private func setHome() {
        let vc = FirstMainPageContainerViewController()
        rootViewController = UINavigationController(rootViewController: vc)
    }
    private func routeToLogin() {
        let vc = LoginViewController()
        rootViewController = UINavigationController(rootViewController: vc)
    }
}
