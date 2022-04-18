import UIKit
import FirebaseAuth
import FirebaseFirestore

class MyStorageViewController: UIViewController {
    @IBOutlet weak var storageTableView: UITableView!
    var myDaons: [Daon] = []
    private var diaryCount = 0
    private var lastCurrentPageDoc: DocumentSnapshot?
    private var limit = 10
    private var isFetching = false
    private var isNext = true
    override func viewDidLoad() {
        super.viewDidLoad()
        let storageTableViewCellNib = UINib(nibName: String(describing: MyStorageCell.self), bundle: nil)
        self.storageTableView.register(storageTableViewCellNib, forCellReuseIdentifier: "myStorageCellId")
        self.storageTableView.rowHeight = UITableView.automaticDimension
        self.storageTableView.separatorStyle = .none
        self.storageTableView.delegate = self
        self.storageTableView.dataSource = self
        fetch()
    }
}

extension MyStorageViewController {
    @IBAction func fetch() {
        guard !(isFetching == true || isNext == false) else {
            return
        }
        guard let user = Auth.auth().currentUser else {
            return
        }
        let uid = user.uid
        isFetching = true
        self.fetchDaon(uid: uid) { (snapshot, error) in
            guard error == nil else {
                print("Error when get daons: \(error!)")
                self.isFetching = false
                return
            }
            guard let snapshot = snapshot else {
                print("daon docs is null")
                self.isFetching = false
                return
            }
            guard !snapshot.documents.isEmpty else {
                print("daon docs is empty")
                self.isNext = false
                self.isFetching = false
                return
            }
            let newDaons = snapshot.documents.map({ (diarySnapshot: QueryDocumentSnapshot) -> Daon in
                return try! diarySnapshot.data(as: Daon.self)
            })
            if self.limit > newDaons.count { self.isNext = false }
            self.lastCurrentPageDoc = snapshot.documents.last
            self.myDaons.append(contentsOf: newDaons)
            DispatchQueue.main.async {
                self.storageTableView.reloadData()
            }
            self.isFetching = false
        }
    }
    func fetchDaon(uid: String, completed: @escaping (QuerySnapshot?, Error?) -> Void) {
        let diaryDB = Firestore.firestore().collection("daon")
        var query: Query
        if self.myDaons.isEmpty {
            query = diaryDB.order(by: "storageUser.\(uid)", descending: true).limit(to: limit)
        } else {
            query = diaryDB.order(by: "storageUser.\(uid)", descending: true).limit(to: limit).start(afterDocument: lastCurrentPageDoc!)
        }
        query.getDocuments { (snapshot, error) in
            if let error = error {
                completed(nil, error)
            } else {
                completed(snapshot, nil)
            }
        }
    }
}

extension MyStorageViewController: UITableViewDelegate {
    // MARK: 스크롤 이벤트 (load more data)
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height {
            self.fetch()
        }
    }
}

extension MyStorageViewController: UITableViewDataSource {
    // MARK: 테이블 뷰 셀의 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myDaons.count
    }
    // MARK: 각 셀에 대한 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = storageTableView.dequeueReusableCell(withIdentifier: "myStorageCellId", for: indexPath) as? MyStorageCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        // MARK: Image setting
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // MARK: 클릭한 셀의 이벤트 처리
        // MARK: 이미지 크게 보기
    }
}
