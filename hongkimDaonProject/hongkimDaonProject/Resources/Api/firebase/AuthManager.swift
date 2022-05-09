//
//  AuthManager.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/21.
//

import Foundation
import GoogleSignIn
import Firebase
import FirebaseAuth
import FirebaseFirestore
import RealmSwift

final class AuthManager: NSObject {
    static let shared = AuthManager()
    let auth: Auth

    override init() {
        self.auth = Auth.auth()
    }
}

protocol withdrawalProtocol {
    func withdrawal(completion: @escaping (Result<String, Error>) -> Void)
}

extension withdrawalProtocol where Self: UIViewController {
    func withdrawal(completion: @escaping (Result<String, Error>) -> Void) {
        if let currentUser = AuthManager.shared.auth.currentUser {
            let uid = currentUser.uid
            currentUser.delete { error in
                if let error = error as? NSError {
                    switch AuthErrorCode(rawValue: error.code) {
                    case .requiresRecentLogin:
                        let alert = UIAlertController(title: "사용자 정보가 만료되었습니다.",
                                                      message: "탈퇴하려는 사용자의 계정으로 다시 로그인해주세요.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: { _ in
                        }))
                        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: { _ in
                            if currentUser.providerData.isEmpty != true {
                                for userInfo in currentUser.providerData {
                                    switch userInfo.providerID {
                                    case "google.com":
                                        print("@@@@@@@@@ google")
                                        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
                                        let signInConfig = GIDConfiguration.init(clientID: clientID)
                                        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
                                            guard error == nil else {
                                                completion(.failure(AuthErros.failedToSignIn))
                                                return
                                            }
                                            guard let authentication = user?.authentication else { return }
                                            if currentUser.email == user?.profile?.email && currentUser.displayName == user?.profile?.name {
                                                let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken!, accessToken: authentication.accessToken)
                                                currentUser.reauthenticate(with: credential) { result, error in
                                                    guard error == nil else {
                                                        completion(.failure(AuthErros.failedToWithdrawal))
                                                        return
                                                    }
                                                    currentUser.delete { error in
                                                        guard error == nil else {
                                                            completion(.failure(AuthErros.failedToWithdrawal))
                                                            return
                                                        }
                                                        self.successToWithdrawal(uid)
                                                        completion(.success(""))
                                                    }
                                                }
                                            } else {
                                                completion(.failure(AuthErros.notEqualUser))
                                            }
                                        }
                                    case "apple.com":
                                        print("@@@@@@@@@ apple")
//                                        // Initialize a fresh Apple credential with Firebase.
//                                        let credential = OAuthProvider.credential(
//                                          withProviderID: "apple.com",
//                                          IDToken: appleIdToken,
//                                          rawNonce: rawNonce
//                                        )
//                                        // Reauthenticate current Apple user with fresh Apple credential.
//                                        currentUser.reauthenticate(with: credential) { (authResult, error) in
//                                          guard error != nil else { return }
//                                          // Apple user successfully re-authenticated.
//                                          // ...
//                                        }
                                    default:
                                        print("user is signed in with \(userInfo.providerID)")
                                    }
                                }
                            }
                        }))
                        self.present(alert, animated: true, completion: nil)
                    default:
                        completion(.failure(AuthErros.failedToWithdrawal))
                        print("Error message: \(error.localizedDescription)")
                    }
                } else {
                    self.successToWithdrawal(uid)
                    completion(.success(""))
                }
            }
        } else {
            self.view.makeToast("네트워크 연결을 확인해주세요.", duration: 1.5, position: .bottom)
        }
    }
    private func successToWithdrawal(_ uid: String) {
        // MARK: realm 데이터 삭제
        try? FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
    }
}

public enum AuthErros: Error {
    case currentUserNotExist
    case failedToSignIn
    case notEqualUser
    case failedToWithdrawal
}
