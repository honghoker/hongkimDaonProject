import Foundation
import UIKit

// MARK: daon color
struct DaonConstants {
    static let daonColor = UIColor(red: 238/255, green: 226/255, blue: 203/255, alpha: 1)
}

// MARK: Loading
class LoadingIndicator {
    static func showLoading() {
        DispatchQueue.main.async {
            // 최상단에 있는 window 객체 획득
            guard let window = UIApplication.shared.windows.last else { return }
            let loadingIndicatorView: UIActivityIndicatorView
            if let existedView = window.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
                loadingIndicatorView = existedView
            } else {
                loadingIndicatorView = UIActivityIndicatorView(style: .large)
                // 다른 UI가 눌리지 않도록 indicatorView의 크기를 full로 할당
                loadingIndicatorView.frame = window.frame
                loadingIndicatorView.color = DaonConstants.daonColor
                window.addSubview(loadingIndicatorView)
            }
            loadingIndicatorView.startAnimating()
        }
    }
    static func hideLoading() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.last else { return }
            window.subviews.filter({ $0 is UIActivityIndicatorView }).forEach { $0.removeFromSuperview() }
        }
    }
}

// MARK: RandomNonceString
func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: Array<Character> =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
        }
        randoms.forEach { random in
            if length == 0 {
                return
            }
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    return result
}

// MARK: realm db 삭제
//                try! FileManager.default.removeItem(at:Realm.Configuration.defaultConfiguration.fileURL!)
//                print(Realm.Configuration.defaultConfiguration.fileURL!)

// MARK: custom DayDate mil
//        let dateString:String = "2022-05"
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM"
//        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
//        let date:Date = dateFormatter.date(from: dateString)!
//        print("before date String \(date)")
//        print("after date String \(date.adding(.month, value: 1))")

// MARK: nowDayDate mil
//        let now = Date()
//        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let nowDayString = dateFormatter.string(from: now)
//        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
//        let nowDayDate: Date = dateFormatter.date(from: nowDayString)!
//        print("nowDayDate \(nowDayDate)")
//        print("nowDayDate mil \(nowDayDate.millisecondsSince1970)")

// MARK: addImage
// @objc
// func addImage(_ gesture: UITapGestureRecognizer) {
//    print("add Image")
//    database.collection("daon").document("\(1651708800000)").setData(["imageUrl": "", "storageUser": "", "uploadTime": 1651708800000])
// }
