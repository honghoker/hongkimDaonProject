//
//  MainPageViewController.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/08.
//

import UIKit

class MainPageViewController: UIViewController {
    @IBOutlet weak var myTableView: UITableView!
    let imageArray = [UUID(), UUID(), UUID()]

    override func viewDidLoad() {
        super.viewDidLoad()
        // 셀 리소스 파일 가져오기
        let myTableViewCellNib = UINib(nibName: String(describing: MainPageViewCell.self), bundle: nil)
        // 셀에 리소스 등록
        self.myTableView.register(myTableViewCellNib, forCellReuseIdentifier: "myTableViewCell")
        self.myTableView.rowHeight = UITableView.automaticDimension
        self.myTableView.estimatedRowHeight = 120
        // delegate 설정
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
    }
}

extension MainPageViewController: UITableViewDelegate{}

extension MainPageViewController: UITableViewDataSource {

    // 테이블 뷰 셀의 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.imageArray.count
    }

    // 각 셀에 대한 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myTableView.dequeueReusableCell(withIdentifier: "myTableViewCell", for: indexPath) as! MainPageViewCell
        cell.testBtn.addTarget(self, action: #selector(onTestBtnClicked(sender:)), for: .touchUpInside)
//        guard let cell = myTableView.dequeueReusableCell(withIdentifier: "myTableViewCell", for: indexPath) as? MainPageViewCell else { return }
//        cell.userContentLabel.text = imageArray[indexPath.row]
        return cell
    }
    @objc fileprivate func onTestBtnClicked(sender: UIButton) {
        print("@@@@@@@@@@@ onTestBtnClicked")
        ImageUploader.uploadImage(image: UIImage(named: "duck")!)
    }
}
