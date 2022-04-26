//
//  AppController.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/22.
//

import UIKit
import Firebase

extension Notification.Name {
    static let authStateDidChange = NSNotification.Name("authStateDidChange")
}

final class AppController {
    static let shared = AppController()
    private init() {
        FirebaseApp.configure() // Firebase 초기화
        registerAuthStateDidChangeEvent()
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
    private func registerAuthStateDidChangeEvent() {
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(checkLoginIn),
//                                               name: .AuthStateDidChange, // <- Firebase Auth 이벤트
//                                               object: nil)
    }
    @objc private func checkLoginIn() {
        if let user = Auth.auth().currentUser { // <- Firebase Auth
            print("@@@@@@@@@@ checkLoginIn user : \(user)")
            setHome()
        } else {
            print("@@@@@@@@@@ checkLoginIn not exist currentUser")
            routeToLogin()
        }
    }
    private func setHome() {
        let homeVC = FirstMainPageContainerViewController()
        rootViewController = UINavigationController(rootViewController: homeVC)
    }
    private func routeToLogin() {
        let loginVC = LoginViewController()
        rootViewController = UINavigationController(rootViewController: loginVC)
    }
}
