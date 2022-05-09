//
//  PreviewViewController.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/05/09.
//

import UIKit
import Kingfisher

class PreviewViewController: UIViewController {
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        getRecntDaon()
    }
    func getRecntDaon() {
        DatabaseManager.shared.fireStore.collection("daon").order(by: "uploadTime", descending: true).limit(to: 1).getDocuments { snapshot, error in
            guard error == nil else {
                return
            }
            if let url = snapshot?.documents[0].get("imageUrl") {
                self.imageView.kf.indicatorType = .activity
                let processor = ResizingImageProcessor(referenceSize: CGSize(width: self.view.frame.width, height: self.view.frame.height))
                let url = URL(string: url as! String)
                self.imageView.kf.setImage(with: url, options: [.processor(processor)])
            }
        }
    }
    @objc
    func back() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
