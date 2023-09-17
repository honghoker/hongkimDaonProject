import UIKit
import FirebaseFirestore
import RealmSwift
import Kingfisher

class MyStorageViewController: UIViewController {
    @IBOutlet weak var storageTableView: UITableView!
    var myDaons: Array<MyStorage>!
    var realm: Realm!
    private var diaryCount = 0
    private var lastCurrentPageDoc: DocumentSnapshot?
    private var limit = 10
    private var isFetching = false
    private var isNext = true
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try? Realm()
        let result = realm.objects(MyStorage.self).sorted(byKeyPath: "storageTime", ascending: false)
        myDaons = Array(result)
        setUI()
    }
    // MARK: set UI
    func setUI() {
        let storageTableViewCellNib = UINib(nibName: String(describing: MyStorageCell.self), bundle: nil)
        self.storageTableView.backgroundColor = UIColor(named: "bgColor")
        self.storageTableView.register(storageTableViewCellNib, forCellReuseIdentifier: "myStorageCellId")
        self.storageTableView.separatorInset = .zero
        self.storageTableView.directionalLayoutMargins = .zero
        self.storageTableView.layoutMargins = .zero
        self.storageTableView.rowHeight = UITableView.automaticDimension
        self.storageTableView.separatorStyle = .none
        self.storageTableView.delegate = self
        self.storageTableView.dataSource = self
    }
}

extension MyStorageViewController: UITableViewDelegate {
}

extension MyStorageViewController: UITableViewDataSource {
    // MARK: 테이블 뷰 셀의 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myDaons.count
    }
    // MARK: 각 셀에 대한 설정
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "myStorageCellId", for: indexPath) as? MyStorageCell else {
            return UITableViewCell()
        }
        let imageUrl = myDaons[indexPath.row].imageUrl
        cell.backgroundColor = UIColor(named: "bgColor")
        cell.myStorageImageView.kf.indicatorType = .activity
        let url = URL(string: String(describing: imageUrl))
        cell.myStorageImageView.kf.setImage(with: url, options: nil)
        cell.contentMode = .scaleAspectFit
        cell.directionalLayoutMargins = .zero
        cell.layoutMargins = .zero
        cell.contentView.directionalLayoutMargins = .zero
        cell.contentView.layoutMargins = .zero
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 클릭한 셀의 이벤트 처리
        // 이미지 크게 보기
        tableView.deselectRow(at: indexPath, animated: true)
        mainImageUrl = myDaons[indexPath.row].imageUrl
        mainUploadTime = myDaons[indexPath.row].uploadTime

		let mainVC = FirstMainPageContainerViewController()
        // 화면 전환 애니메이션 설정
        mainVC.modalTransitionStyle = .crossDissolve
        // 전환된 화면이 보여지는 방법 설정 (fullScreen)
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC, animated: true, completion: nil)
    }
}
