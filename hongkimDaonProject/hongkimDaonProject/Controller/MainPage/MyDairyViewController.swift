import UIKit

class MyDairyViewController: UIViewController {

    @IBOutlet weak var dairyTableView: UITableView!
    @IBOutlet weak var floatingBtn: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let dairyTableViewCellNib = UINib(nibName: String(describing: MyDairyCell.self), bundle: nil)
        self.dairyTableView.register(dairyTableViewCellNib, forCellReuseIdentifier: "myDairyCellId")
        self.dairyTableView.rowHeight = UITableView.automaticDimension
//        self.dairyTableView.estimatedRowHeight = 120
        self.dairyTableView.separatorStyle = .none
        self.dairyTableView.delegate = self
        self.dairyTableView.dataSource = self
    }
    override func viewWillLayoutSubviews() {
        floatingBtn.layer.backgroundColor = UIColor.white.cgColor
        floatingBtn.layer.borderWidth = 0.5
        floatingBtn.layer.cornerRadius = 32
        floatingBtn.layer.borderColor = UIColor.black.cgColor
        let floatingClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapFloatingBtn(_:)))
        floatingBtn.addGestureRecognizer(floatingClick)
    }
    @objc
    func tapFloatingBtn(_ gesture: UITapGestureRecognizer) {
        print("float tap")
    }

}

extension MyDairyViewController: UITableViewDelegate {
}

extension MyDairyViewController: UITableViewDataSource {
    // 테이블 뷰 셀의 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
//        return self.contentArray.count
    }
    // 각 셀에 대한 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dairyTableView.dequeueReusableCell(withIdentifier: "myDairyCellId", for: indexPath) as! MyDairyCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
//        cell.layer.borderWidth = 0.5
//        cell.separatorInset = UIEdgeInsets.zero
        cell.title.text = "성훈 제목"
        cell.content.text = "성훈 내용"
        cell.time.text = "성훈 시간"
        // clipsToBounds -> 이거 뭐지 ?
//        cell.clipsToBounds = true
//        cell.contentLabel.text = contentArray[indexPath.row]
        return cell
    }
}
