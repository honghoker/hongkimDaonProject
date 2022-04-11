import UIKit
import Firebase

class MyDiaryViewController: UIViewController {
    @IBOutlet weak var diaryTableView: UITableView!
    @IBOutlet weak var floatingBtn: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let diaryTableViewCellNib = UINib(nibName: String(describing: MyDiaryCell.self), bundle: nil)
        self.diaryTableView.register(diaryTableViewCellNib, forCellReuseIdentifier: "myDiaryCellId")
        self.diaryTableView.rowHeight = UITableView.automaticDimension
        //        self.diaryTableView.estimatedRowHeight = 120
        self.diaryTableView.separatorStyle = .none
        self.diaryTableView.delegate = self
        self.diaryTableView.dataSource = self
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
        print("@@@@@ float tap")
//        let firebaseAuth = Auth.auth()
//        do {
//            try firebaseAuth.signOut()
//            self.navigationController?.popToRootViewController(animated: true)
//        } catch let signOutError as NSError {
//            print("ERROR: signOutError \(signOutError.localizedDescription)")
//        }
        let storyboard: UIStoryboard = UIStoryboard(name: "WriteDiaryPageView", bundle: nil)
        let inputNickNameVC = storyboard.instantiateViewController(withIdentifier: "WriteDiaryPageViewController")
        inputNickNameVC.modalPresentationStyle = .fullScreen
        inputNickNameVC.modalTransitionStyle = .crossDissolve
        self.present(inputNickNameVC, animated: true, completion: nil)
    }
}

extension MyDiaryViewController: UITableViewDelegate {
}

extension MyDiaryViewController: UITableViewDataSource {
    // 테이블 뷰 셀의 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
        //        return self.contentArray.count
    }
    // 각 셀에 대한 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = diaryTableView.dequeueReusableCell(withIdentifier: "myDiaryCellId", for: indexPath) as? MyDiaryCell else {
            return UITableViewCell()
        }
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
