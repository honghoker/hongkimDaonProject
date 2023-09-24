import UIKit
import SnapKit
import Firebase
import FirebaseFirestore

protocol DispatchDiary: AnyObject {
    func dispatch(Input value: Diary?)
    func update(Input value: Diary?)
    func delete(Delete id: String?)
}

class MyDiaryViewController: UIViewController {
    private var myDiarys: [Diary] = []
    private var diaryCount = 0
    private var lastCurrentPageDoc: DocumentSnapshot?
    private var limit = 10
    private var isFetching = false
    private var isNext = true
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        let myTableViewCellNib = UINib(nibName: String(describing: MyDiaryCell.self), bundle: nil)
        tableView.register(myTableViewCellNib, forCellReuseIdentifier: "MyDiaryCell")
        tableView.backgroundColor = UIColor(named: "bgColor")
        tableView.rowHeight = 100
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private lazy var floatingButton: UIButton = {
        let button = UIButton()
        button.layer.backgroundColor = UIColor.white.cgColor
        button.layer.shadowColor = UIColor.gray.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 6.0
        button.layer.cornerRadius = 32
        button.tintColor = UIColor.gray
        button.setImage(UIImage(systemName: "scribble"), for: .normal)
        let config = UIImage.SymbolConfiguration(pointSize: 24)
        button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.backgroundColor = UIColor(named: "bgColor")
        let floatingClick = UITapGestureRecognizer(target: self, action: #selector(didtapFloatingButton))
        button.addGestureRecognizer(floatingClick)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addView()
        setLayout()
        setupView()
        fetch()
    }
    
    private func addView() {
        [
            tableView,
            floatingButton
        ].forEach {
            view.addSubview($0)
        }
    }
    
    private func setLayout() {
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        floatingButton.snp.makeConstraints {
            $0.size.equalTo(64)
            $0.right.equalTo(tableView).offset(-16)
            $0.bottom.equalTo(tableView).offset(-32)
        }
    }
    
    private func setupView() {
        
    }
}

extension MyDiaryViewController {
    @IBAction private func fetch() {
        guard !(isFetching == true || isNext == false) else {
            return
        }
        guard let user = AuthManager.shared.auth.currentUser else {
            //            self.view.makeToast("네트워크 연결을 확인해주세요.", duration: 1.5, position: .bottom)
            return
        }
        let uid = user.uid
        isFetching = true
        self.fetchDiary(uid: uid) { [weak self] (snapshot, error) in
            guard error == nil else {
                //                print("Error when get diarys: \(error!)")
                self?.isFetching = false
                return
            }
            guard let snapshot = snapshot else {
                //                print("diary docs is null")
                self?.isFetching = false
                return
            }
            guard !snapshot.documents.isEmpty else {
                //                print("diary docs is empty")
                self?.isNext = false
                self?.isFetching = false
                return
            }
            let newDiarys = snapshot.documents.map({ (diarySnapshot: QueryDocumentSnapshot) -> Diary in
                return try! diarySnapshot.data(as: Diary.self)
            })
            if let limit = self?.limit {
                if limit > newDiarys.count {
                    self?.isNext = false
                }
            }
            self?.lastCurrentPageDoc = snapshot.documents.last
            self?.myDiarys.append(contentsOf: newDiarys)
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
            self?.isFetching = false
        }
    }
    private func fetchDiary(uid: String, completed: @escaping (QuerySnapshot?, Error?) -> Void) {
        let diaryDB = DatabaseManager.shared.fireStore.collection("diary")
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
    func didtapFloatingButton(_ gesture: UITapGestureRecognizer) {
        if self.myDiarys.isEmpty == true {
            // MARK: 일기가 비어있으면
            moveToWriteDiaryPage()
        } else {
            let current = Calendar.current
            if current.isDateInToday(Date(milliseconds: self.myDiarys[0].writeTime)) == true {
                // MARK: 오늘이면
                //                self.view.makeToast("이미 오늘의 일기를 작성했습니다.")
            } else {
                // MARK: 오늘이 아니면 일기 작성
                moveToWriteDiaryPage()
            }
        }
    }
    private func moveToWriteDiaryPage() {
        let vc = WriteDiaryPageViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
}

extension MyDiaryViewController: DispatchDiary {
    func update(Input value: Diary?) {
        if let diary = value {
            if let index = myDiarys.firstIndex(where: {
                $0.writeTime == Int64(diary.writeTime)}) {
                myDiarys[index] = diary
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            }
        }
    }
    func delete(Delete value: String?) {
        if let writeTime = value {
            if let index = self.myDiarys.firstIndex(where: {
                $0.writeTime == Int64(writeTime)}) {
                self.myDiarys.remove(at: index)
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            }
        }
    }
    func dispatch(Input value: Diary?) {
        if let diary = value {
            self.myDiarys.insert(diary, at: 0)
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
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
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "MyDiaryCell", for: indexPath
        ) as? MyDiaryCell else {
            return UITableViewCell()
        }
        cell.backgroundColor = UIColor(named: "bgColor")
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        //        cell.separatorInset = UIEdgeInsets.zero
        cell.content.text = self.myDiarys[indexPath.row].content
        let myDateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "# yyyy.MM.dd" // 2020.08.13 오후 04:30분
        myDateFormatter.locale = Locale(identifier: "ko_KR") // PM, AM을 언어에 맞게 setting (ex: PM -> 오후)
        let convertNowStr = myDateFormatter.string(from: Date(milliseconds: myDiarys[indexPath.row].writeTime)) //
        cell.time.text = convertNowStr
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // MARK: 클릭한 셀의 이벤트 처리
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = DetailDiaryPageViewController()
        vc.delegate = self
        // MARK: 화면 전환 애니메이션 설정
        vc.modalTransitionStyle = .crossDissolve
        // MARK: 전환된 화면이 보여지는 방법 설정 (fullScreen)
        vc.docId = String(myDiarys[indexPath.row].writeTime)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}
