import UIKit
import Firebase
import GoogleSignIn
import RealmSwift
import FirebaseMessaging
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "완료"
        IQKeyboardManager.shared.toolbarTintColor = .black
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        // MARK: firebase login
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        AppController.shared.show(in: window)
        // MARK: FCM
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        return true
    }
    // 세로방향 고정
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return application(app, open: url,
                           sourceApplication: options[UIApplication.OpenURLOptionsKey
                            .sourceApplication] as? String,
                           annotation: "")
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?,
                     annotation: Any) -> Bool {
        return false
    }
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    // MARK: FCM
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}
// MARK: FCM
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("\(#function)")
    }
}
// MARK: FCM
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("Firebase registration token: \(token)")
        let dataDict: [String: String] = ["token": token]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}
