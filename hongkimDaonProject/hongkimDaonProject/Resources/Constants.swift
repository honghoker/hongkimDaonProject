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
