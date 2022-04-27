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

protocol withdrawalProtocol {
    func withdrawal(completion: @escaping (Result<String, Error>) -> Void)
}

extension withdrawalProtocol where Self: UIViewController {
    func withdrawal(completion: @escaping (Result<String, Error>) -> Void) {
        if let currentUser = Auth.auth().currentUser {
            let uid = currentUser.uid
            currentUser.delete { error in
                if let error = error as? NSError {
                    switch AuthErrorCode(rawValue: error.code) {
                    case .requiresRecentLogin:
                        let alert = UIAlertController(title: "사용자 정보가 만료되었습니다.",
                                                      message: "탈퇴하려는 사용자의 계정으로 다시 로그인해주세요.", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: { _ in
                            // Cancel Action
                        }))
                        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: { _ in
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

//    final class AuthManager {
//        static let shared = AuthManager()
//        private let auth = Auth.auth()
//
//        public func withdrawal(completion: @escaping (Result<String, Error>) -> Void) {
//        }
//    }
