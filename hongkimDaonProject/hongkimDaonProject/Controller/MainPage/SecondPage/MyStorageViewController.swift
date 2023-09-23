import UIKit
import FirebaseFirestore
import RealmSwift
import Kingfisher

class MyStorageViewController: UIViewController {
    private var myDaons = [MyStorage]()
    private var diaryCount = 0
    private var lastCurrentPageDoc: DocumentSnapshot?
    private var limit = 10
    private var isFetching = false
    private var isNext = true
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        let cellNib = UINib(nibName: String(describing: MyStorageCell.self), bundle: nil)
        tableView.backgroundColor = UIColor(named: "bgColor")
        tableView.register(MyStorageCell.self, forCellReuseIdentifier: MyStorageCell.identifier)
        tableView.separatorInset = .zero
        tableView.directionalLayoutMargins = .zero
        tableView.layoutMargins = .zero
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addView()
        setLayout()
        setupView()
        fetchStoragedDaon()
    }
    
    private func addView() {
        view.addSubview(tableView)
    }
    
    private func setLayout() {
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaInsets)
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupView() {
        
    }
    
    private func fetchStoragedDaon() {
        do {
            let realm = try Realm()
            let result = realm.objects(MyStorage.self).sorted(byKeyPath: "storageTime", ascending: false)
            myDaons = Array(result)
        } catch {
            debugPrint("fetch Storage Error: \(error.localizedDescription)")
        }
    }
}

extension MyStorageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myDaons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "myStorageCellId",
            for: indexPath
        ) as? MyStorageCell else {
            return UITableViewCell()
        }
        let imageUrl = myDaons[indexPath.row].imageUrl
        cell.setImage(urlString: imageUrl)
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
        present(mainVC, animated: true)
    }
}
