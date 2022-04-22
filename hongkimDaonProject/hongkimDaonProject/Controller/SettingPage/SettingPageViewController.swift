//
//  SettingPageViewController.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/11.
//

import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseFirestore
import Toast_Swift
import RealmSwift

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
        let setNotificationClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapSetNotification(_:)))
        notificationConfigBtn.isUserInteractionEnabled = true
        notificationConfigBtn.addGestureRecognizer(setNotificationClick)
    }
}

extension SettingPageViewController {
    @objc
    func onTapSetNotification(_ gesture: UITapGestureRecognizer) {
        guard let nextView = self.storyboard?.instantiateViewController(identifier: "SetNotificationPageViewController") as? SetNotificationPageViewController else {
            return
        }
        nextView.modalPresentationStyle = .fullScreen
        self.present(nextView, animated: false, completion: nil)
    }
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
                //                GIDSignIn.sharedInstance.signOut()
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
            if let currentUser = Auth.auth().currentUser {
                currentUser.delete { error in
                    if let error = error as? NSError {
                        switch AuthErrorCode(rawValue: error.code) {
                        case .operationNotAllowed:
                            print("Email/ Password sign in provider is new disabled")
                        case .requiresRecentLogin:
                            print("@@@@@@@@@@@@@@@@@ requiresRecentLogin request")
                            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                            let signInConfig = GIDConfiguration.init(clientID: clientID)
                            GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
                                guard error == nil else { return } // 로그인 실패
                                guard let authentication = user?.authentication else { return }
                                // access token 부여 받음
                                // MARK: 은표 예외처리 필요
                                if currentUser.email == user?.profile?.email && currentUser.displayName == user?.profile?.name {
                                    let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!, accessToken: authentication.accessToken)
                                    currentUser.reauthenticate(with: credential) { result, error in
                                        if let error = error {
                                            print("@@@@@@@@ reauthenticate erorr : \(error)")
                                        } else {
                                            print("@@@@@@@@ reauthenticate success : \(result)")
                                            currentUser.delete { error in
                                                if let error = error as? NSError {
                                                    print("@@@@@@@ 또 실패 : \(error)")
                                                } else {
                                                    print("@@@@@@@@ 회원탈퇴 성공")
                                                    self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                                                    // MARK: 은표 나의 일기 firestore 삭제 필요
                                                    // MARK: 성훈 realm 나의 보관함 삭제 필요
                                                    try? FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    self.view.makeToast("회원탈퇴가 실패했습니다.\n현재 로그인한 계정과 다른 계정입니다.", duration: 1.5, position: .bottom)
                                }
                            }
                        default:
                            print("Error message: \(error.localizedDescription)")
                        }
                    } else {
                        print("@@@@@@@@ 회원탈퇴 성공")
                        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                        // MARK: 은표 나의 일기 firestore 삭제 필요
                        // MARK: realm 데이터 삭제
                        try? FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
                    }
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
