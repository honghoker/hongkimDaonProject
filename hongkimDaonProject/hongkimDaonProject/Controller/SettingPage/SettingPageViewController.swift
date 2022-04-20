//
//  SettingPageViewController.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/11.
//

import UIKit
import Firebase
import Network

class SettingPageViewController: UIViewController {
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var nickNameChangeBtn: UILabel!
    @IBOutlet weak var notificationConfigBtn: UILabel!
    @IBOutlet weak var logoutBtn: UILabel!
    @IBOutlet weak var withdrawalBtn: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        let logoutBtnClicked: UITapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(logout(_:)))
        logoutBtn.isUserInteractionEnabled = true
        logoutBtn.addGestureRecognizer(logoutBtnClicked)
        let withdrawalBtnClicked: UITapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(withdrawal(_:)))
        withdrawalBtn.isUserInteractionEnabled = true
        withdrawalBtn.addGestureRecognizer(withdrawalBtnClicked)
    }
}

extension SettingPageViewController {
    @objc
    func back() {
        self.presentingViewController?.dismiss(animated: true)
    }
    @objc
    func logout(_ gesture: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "로그아웃 하시겠습니까?", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: { _ in
            // Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "확인",
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
            do {
                let firebaseAuth = Auth.auth()
                try firebaseAuth.signOut()
                self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                print("@@@@@@@@ logout complete")
            } catch let signOutError as NSError {
                print("ERROR: signOutError \(signOutError.localizedDescription)")
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @objc
    func withdrawal(_ gesture: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "회원탈퇴 하시겠습니까?",
                                      message: "[탈퇴 시 주의사항]\n나의 일기, 나의 보관함에 저장된 데이터가 모두 사라지며 복구가 불가능합니다", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: { _ in
            // Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "탈퇴",
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
            Auth.auth().currentUser?.delete(completion: { (error) in
              if let error = error as? NSError {
                switch AuthErrorCode(rawValue: error.code) {
                case .operationNotAllowed:
                  // Error: The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.
                  print("Email/ Password sign in provider is new disabled")
                case .requiresRecentLogin:
                  // Error: Updating a user’s password is a security sensitive operation that requires a recent login from the user. This error indicates the user has not signed in recently enough. To resolve, reauthenticate the user by invoking reauthenticateWithCredential:completion: on FIRUser.
                  print("Updating a user’s password is a security sensitive operation that requires a recent login from the user. This error indicates the user has not signed in recently enough. To resolve, reauthenticate the user by invoking reauthenticateWithCredential:completion: on FIRUser.")
                    if let user = Auth.auth().currentUser {
                        var credential: AuthCredential
//                        GoogleAuthProvider.credential(withIDToken: user.getIDToken(), accessToken: String)
                        user.getIDToken(completion: { (result, error) in
                            if let error = error {
                                print("@@@@@@@@ error : \(error)")
                                return
                            } else {
                                let userIdToken = result!
                                GoogleAuthProvider.credential(withIDToken: userIdToken, accessToken: "")
                            }
                            })

//                        user.reauthenticate(with: credential, completion: { (result, error) in
//                            if let err = error {
//                                // error
//                            } else {
//                                // go on
//                            }
//                        })
                    }
                default:
                  print("Error message: \(error.localizedDescription)")
                }
              } else {
                print("User account is deleted successfully")
              }
            })
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
