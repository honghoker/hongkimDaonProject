import UIKit
import Firebase
import FirebaseFirestore

class MyDiaryViewController: UIViewController {
    let database = Firestore.firestore()
    lazy var diaryCount = 0
    var myDiarys: [Diary] = []
    @IBOutlet weak var diaryTableView: UITableView!
    @IBOutlet weak var floatingBtn: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let myTableViewCellNib = UINib(nibName: String(describing: TestDiaryCell.self), bundle: nil)
        self.diaryTableView.register(myTableViewCellNib, forCellReuseIdentifier: "TestDiaryCell")
        self.diaryTableView.rowHeight = 120
        self.diaryTableView.estimatedRowHeight = UITableView.automaticDimension
        self.diaryTableView.separatorStyle = .none
        self.diaryTableView.delegate = self
        self.diaryTableView.dataSource = self
        testGetDiary()
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
    private func testGetDiary() {
        DatabaseManager.shared.getDiary { [weak self] result in
            switch result {
            case .success(let diarys):
                let result: [Diary] = diarys as [Diary]
                self?.myDiarys += result
                self?.diaryTableView.reloadData()
                print("@@@@@@@@@@ diarys : \(diarys.count)")
            case .failure(let Error):
                print("@@@@@@@@@@ Error : \(Error)")
            }
        }
    }
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
        return self.myDiarys.count
        //        return self.diaryCount
    }
    // 각 셀에 대한 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = diaryTableView.dequeueReusableCell(withIdentifier: "TestDiaryCell", for: indexPath) as? TestDiaryCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        //        cell.layer.borderWidth = 0.5
        //        cell.separatorInset = UIEdgeInsets.zero
        cell.title.text = myDiarys[indexPath.row].title
        cell.content.text = myDiarys[indexPath.row].content
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "yyyy년 MM월 dd일 a h:mm" // 2020.08.13 오후 04시 30분
        myDateFormatter.locale = Locale(identifier: "ko_KR") // PM, AM을 언어에 맞게 setting (ex: PM -> 오후)
        let convertNowStr = myDateFormatter.string(from: Date(milliseconds: myDiarys[indexPath.row].writeTime)) //
        cell.time.text = convertNowStr
        // clipsToBounds -> 이거 뭐지 ?
        //        cell.clipsToBounds = true
        //        cell.contentLabel.text = contentArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 클릭한 셀의 이벤트 처리
        tableView.deselectRow(at: indexPath, animated: true)
        print("Click Cell Number: " + String(indexPath.row))
        let storyboard: UIStoryboard = UIStoryboard(name: "DetailDiaryView", bundle: nil)
        guard let DetailDiaryVC = storyboard.instantiateViewController(withIdentifier: "DetailDiaryViewController") as? DetailDiaryViewController else { return }
                // 화면 전환 애니메이션 설정
        DetailDiaryVC.modalTransitionStyle = .coverVertical
                // 전환된 화면이 보여지는 방법 설정 (fullScreen)
        DetailDiaryVC.docId = String(myDiarys[indexPath.row].writeTime)
        DetailDiaryVC.modalPresentationStyle = .fullScreen
                self.present(DetailDiaryVC, animated: true, completion: nil)
    }
}
