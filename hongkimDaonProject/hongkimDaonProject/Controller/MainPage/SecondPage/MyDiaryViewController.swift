import UIKit
import Firebase
import FirebaseFirestore

class MyDiaryViewController: UIViewController {
    let database = Firestore.firestore()
    lazy var diaryCount = 0
    @IBOutlet weak var diaryTableView: UITableView!
    @IBOutlet weak var floatingBtn: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let diaryTableViewCellNib = UINib(nibName: String(describing: MyDiaryCell.self), bundle: nil)
        self.diaryTableView.register(diaryTableViewCellNib, forCellReuseIdentifier: "myDiaryCellId")
        self.diaryTableView.rowHeight = UITableView.automaticDimension
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
    override func viewWillAppear(_ animated: Bool) {
    }
    override func viewDidAppear(_ animated: Bool) {
    }
}

extension MyDiaryViewController {
    @objc
    func tapFloatingBtn(_ gesture: UITapGestureRecognizer) {
//                        loadData()
        let storyboard: UIStoryboard = UIStoryboard(name: "WriteDiaryPageView", bundle: nil)
        let inputNickNameVC = storyboard.instantiateViewController(withIdentifier: "WriteDiaryPageViewController")
        inputNickNameVC.modalPresentationStyle = .fullScreen
        inputNickNameVC.modalTransitionStyle = .crossDissolve
        self.present(inputNickNameVC, animated: true, completion: nil)
    }
    func loadData() {
        let docRefTest = database.collection("diary")
        docRefTest.getDocuments(completion: { snapshot, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else { return } // document 가져옴
            print("documents.count \(documents.count)")
            self.diaryCount = documents.count
            self.diaryTableView.layoutIfNeeded()
            documents.forEach { snapshot in
                print("snapshot \(String(describing: snapshot["title"]))")
            }
        })
        //        let docRef = database.document("diary/fOSHl6jdkmYpc9WH4q5p")
        //        docRef.getDocument { snapshot, error in
        //            guard let data = snapshot?.data(), error == nil else {
        //                return
        //            }
        //            guard let title = data["title"] as? String else {
        //                return
        //            }
        //            print("data data \(data)")
        //            print("title title \(title)")
        //        }
    }
    //    func writeData(text: String) {
    //        let docRef = database.document("diary/1")
    //        docRef.setData(["text": text])
    //    }
}

extension MyDiaryViewController: UITableViewDelegate {
}

extension MyDiaryViewController: UITableViewDataSource {
    // 테이블 뷰 셀의 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
        //        return self.diaryCount
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
        //        cell.clipsToBounds = true -> 이거 뭐지 ?
        //        cell.contentLabel.text = contentArray[indexPath.row]
        return cell
    }
}
