import Foundation
import FirebaseAuth

final class AuthManager: NSObject {
    static let shared = AuthManager()
    let auth: Auth

    override init() {
        self.auth = Auth.auth()
    }
}

public enum AuthErros: Error {
    case currentUserNotExist
    case failedToSignIn
    case notEqualUser
    case failedToWithdrawal
}
