import Foundation
import FirebaseAuth

final class AuthManager: NSObject {
    static let shared = AuthManager()
    let auth: Auth

    override init() {
        self.auth = Auth.auth()
    }
}

enum AuthErrors: Error {
    case currentUserNotExist
    case failedToSignIn
    case notEqualUser
    case failedToWithdrawal
}

extension AuthErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedToSignIn:
            return "로그인에 실패했습니다."
        case .currentUserNotExist:
            return "사용자 정보를 가져오는데 실패했습니다."
        case .notEqualUser:
            return "회원탈퇴가 실패했습니다.\n현재 로그인한 계정과 다른 계정입니다."
        case .failedToWithdrawal:
            return "회원탈퇴에 실패했습니다."
        }
    }
}
