import UIKit
import FirebaseAuth
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
        let storageTableViewCellNib = UINib(nibName: String(describing: MyStorageCell.self), bundle: nil)
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
    // MARK: 스크롤 이벤트 (load more data)
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let offsetY = scrollView.contentOffset.y
//        let contentHeight = scrollView.contentSize.height
//        if offsetY > contentHeight - scrollView.frame.height {
//            self.fetch()
//        }
    }
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
//        let imageUrl = myDaons[indexPath.row].imageUrl
        let imageData = myDaons[indexPath.row].imageData
//        cell.myStorageImageView.kf.setImage(with: URL(string: imageUrl))
        cell.myStorageImageView.image = UIImage(data: imageData)
        cell.contentMode = .scaleAspectFit
        cell.directionalLayoutMargins = .zero
        cell.layoutMargins = .zero
        cell.contentView.directionalLayoutMargins = .zero
        cell.contentView.layoutMargins = .zero
        // MARK: Image setting
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // MARK: 클릭한 셀의 이벤트 처리
        // MARK: 이미지 크게 보기
        tableView.deselectRow(at: indexPath, animated: true)
//        print("todayArray[indexPath.row].url \(myDaons[indexPath.row].imageUrl)")
//        mainImageUrl = myDaons[indexPath.row].imageUrl
        mainImageData = myDaons[indexPath.row].imageData
        mainUploadTime = myDaons[indexPath.row].uploadTime
        let storyboard: UIStoryboard = UIStoryboard(name: "MainPageView", bundle: nil)
        guard let mainVC = storyboard.instantiateViewController(withIdentifier: "FirstMainPageContainerViewController") as? FirstMainPageContainerViewController else { return }
        // 화면 전환 애니메이션 설정
        mainVC.modalTransitionStyle = .crossDissolve
        // 전환된 화면이 보여지는 방법 설정 (fullScreen)
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC, animated: true, completion: nil)
    }
}
