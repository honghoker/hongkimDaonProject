//
//  AppDelegate.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/06.
//

import UIKit
import Firebase
import GoogleSignIn
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // MARK: realm migration
        //        // 1. config 설정(이전 버전에서 다음 버전으로 마이그레이션될때 어떻게 변경될것인지)
        //        let config = Realm.Configuration(
        //            schemaVersion: 2, // 새로운 스키마 버전 설정
        //            migrationBlock: { migration, oldSchemaVersion in
        //                if oldSchemaVersion < 2 {
        //                    // 1-1. 마이그레이션 수행(버전 2보다 작은 경우 버전 2에 맞게 데이터베이스 수정)
        //                    migration.deleteData(forType: TodayList.className())
        //                    migration.deleteData(forType: Person.className())
        //                }
        //            }
        //        )
        //        // 2. Realm이 새로운 Object를 쓸 수 있도록 설정
        //        Realm.Configuration.defaultConfiguration = config
        FirebaseApp.configure()
        return true
    }
    // google login handler
    func application(_ application: UIApplication, open urlLink: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        var handled: Bool
        handled = GIDSignIn.sharedInstance.handle(urlLink)
        if handled {
            return true
        }
        // Handle other custom URL types.
        // If not handled by this app, return false.
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
}
