import UIKit
import SnapKit
import Firebase
import FirebaseFirestore
import CoreAudio

class MyDiaryViewController: UIViewController {
    @IBOutlet weak var diaryTableView: UITableView!
    var myDiarys: [Diary] = []
    private var diaryCount = 0
    private var lastCurrentPageDoc: DocumentSnapshot?
    private var limit = 10
    private var isFetching = false
    private var isNext = true
    lazy var floatBtn: UIButton = {
        let btn = UIButton()
        btn.layer.backgroundColor = UIColor.white.cgColor
        btn.layer.shadowColor = UIColor.gray.cgColor
        btn.layer.shadowOpacity = 0.5
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 6.0
        btn.layer.cornerRadius = 32
        btn.tintColor = UIColor.gray
//        highlighter
        btn.setImage(UIImage(systemName: "scribble"), for: .normal)
        let config = UIImage.SymbolConfiguration(pointSize: 24)
        btn.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        let myTableViewCellNib = UINib(nibName: String(describing: MyDiaryCell.self), bundle: nil)
        self.diaryTableView.register(myTableViewCellNib, forCellReuseIdentifier: "MyDiaryCell")
        self.diaryTableView.rowHeight = 120
        self.diaryTableView.estimatedRowHeight = UITableView.automaticDimension
        self.diaryTableView.separatorStyle = .none
        self.diaryTableView.delegate = self
        self.diaryTableView.dataSource = self
        view.addSubview(floatBtn)
        self.floatBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(64)
            make.right.equalTo(diaryTableView).offset(-16)
            make.bottom.equalTo(diaryTableView).offset(-32)
        }
        let floatingClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapFloatingBtn(_:)))
        floatBtn.addGestureRecognizer(floatingClick)
        fetch()
    }
}

extension MyDiaryViewController {
    @IBAction func fetch() {
        guard !(isFetching == true || isNext == false) else {
            return
        }
        guard let user = Auth.auth().currentUser else {
            return
        }
        let uid = user.uid
        isFetching = true
        self.fetchDiary(uid: uid) { (snapshot, error) in
            guard error == nil else {
                print("Error when get diarys: \(error!)")
                self.isFetching = false
                return
            }
            guard let snapshot = snapshot else {
                print("diary docs is null")
                self.isFetching = false
                return
            }
            guard !snapshot.documents.isEmpty else {
                print("diary docs is empty")
                self.isNext = false
                self.isFetching = false
                return
            }
            let newDiarys = snapshot.documents.map({ (diarySnapshot: QueryDocumentSnapshot) -> Diary in
                return try! diarySnapshot.data(as: Diary.self)
            })
            if self.limit > newDiarys.count { self.isNext = false }
            self.lastCurrentPageDoc = snapshot.documents.last
            self.myDiarys.append(contentsOf: newDiarys)
            DispatchQueue.main.async {
                self.diaryTableView.reloadData()
            }
            self.isFetching = false
        }
    }
    func fetchDiary(uid: String, completed: @escaping (QuerySnapshot?, Error?) -> Void) {
        let diaryDB = Firestore.firestore().collection("diary")
        var query: Query
        if self.myDiarys.isEmpty {
            query = diaryDB.whereField("uid", isEqualTo: uid).order(by: "writeTime", descending: true).limit(to: limit)
        } else {
            query = diaryDB.whereField("uid", isEqualTo: uid).order(by: "writeTime", descending: true).limit(to: limit).start(afterDocument: lastCurrentPageDoc!)
        }
        query.getDocuments { (snapshot, error) in
            if let error = error {
                completed(nil, error)
            } else {
                completed(snapshot, nil)
            }
        }
    }
    @objc
    func tapFloatingBtn(_ gesture: UITapGestureRecognizer) {
        let storyboard: UIStoryboard = UIStoryboard(name: "WriteDiaryPageView", bundle: nil)
        let inputNickNameVC = storyboard.instantiateViewController(withIdentifier: "WriteDiaryPageViewController")
        inputNickNameVC.modalPresentationStyle = .fullScreen
        inputNickNameVC.modalTransitionStyle = .crossDissolve
        self.present(inputNickNameVC, animated: true, completion: nil)
    }
}

extension MyDiaryViewController: UITableViewDelegate {
    // MARK: 스크롤 이벤트 (load more data)
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height {
            self.fetch()
        }
    }
}

extension MyDiaryViewController: UITableViewDataSource {
    // MARK: 테이블 뷰 셀의 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myDiarys.count
    }
    // MARK: 각 셀에 대한 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = diaryTableView.dequeueReusableCell(withIdentifier: "MyDiaryCell", for: indexPath) as? MyDiaryCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        //        cell.separatorInset = UIEdgeInsets.zero
        cell.title.text = self.myDiarys[indexPath.row].title
        cell.content.text = self.myDiarys[indexPath.row].content
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "yyyy년 MM월 dd일 a h:mm" // 2020.08.13 오후 04시 30분
        myDateFormatter.locale = Locale(identifier: "ko_KR") // PM, AM을 언어에 맞게 setting (ex: PM -> 오후)
        let convertNowStr = myDateFormatter.string(from: Date(milliseconds: myDiarys[indexPath.row].writeTime)) //
        cell.time.text = convertNowStr
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // MARK: 클릭한 셀의 이벤트 처리
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard: UIStoryboard = UIStoryboard(name: "DetailDiaryView", bundle: nil)
        guard let DetailDiaryVC = storyboard.instantiateViewController(withIdentifier: "DetailDiaryViewController") as? DetailDiaryViewController else { return }
        // MARK: 화면 전환 애니메이션 설정
        DetailDiaryVC.modalTransitionStyle = .crossDissolve
        // MARK: 전환된 화면이 보여지는 방법 설정 (fullScreen)
        DetailDiaryVC.docId = String(myDiarys[indexPath.row].writeTime)
        DetailDiaryVC.modalPresentationStyle = .fullScreen
        self.present(DetailDiaryVC, animated: true, completion: nil)
    }
}
