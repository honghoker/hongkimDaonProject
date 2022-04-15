//
//  NoAlertable.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/12.
//

import UIKit


struct NoAlert: FMAlertable {
    func show(in viewController: UIViewController, ok: @escaping () -> Void, cancel: @escaping () -> Void) {
        return
    }
}
