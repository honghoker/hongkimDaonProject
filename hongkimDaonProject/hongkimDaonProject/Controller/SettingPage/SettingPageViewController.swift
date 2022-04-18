//
//  SettingPageViewController.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/11.
//

import UIKit
import Firebase

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
    }
}

extension SettingPageViewController {
    @objc
    func back() {
        self.presentingViewController?.dismiss(animated: true)
    }
    @objc
    func logout(_ gesture: UITapGestureRecognizer) {
        print("@@@@@@@@@@@@@@@@@")
        do {
            let firebaseAuth = Auth.auth()
            try firebaseAuth.signOut()
            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
            print("@@@@@@@@ logout complete")
        } catch let signOutError as NSError {
            print("ERROR: signOutError \(signOutError.localizedDescription)")
        }
    }
}
