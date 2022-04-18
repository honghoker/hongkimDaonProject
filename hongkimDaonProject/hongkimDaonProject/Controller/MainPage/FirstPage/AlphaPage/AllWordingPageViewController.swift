import UIKit
import FirebaseStorage
import RealmSwift

class AllWordingPageViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var realm: Realm!
    var todayArray: Array<Today>!
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try? Realm()
        let result = realm.objects(Today.self)
        todayArray = Array(result)
        let allWordingTableViewCellNib = UINib(nibName: String(describing: AllWordingCell.self), bundle: nil)
        self.tableView.register(allWordingTableViewCellNib, forCellReuseIdentifier: "allWordingCellId")
        self.tableView.separatorInset = .zero
        self.tableView.directionalLayoutMargins = .zero
        self.tableView.layoutMargins = .zero
        self.tableView.rowHeight = UITableView.automaticDimension
        //        self.tableView.rowHeight = 300
        //        self.tableView.estimatedRowHeight = 200
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
}

extension AllWordingPageViewController: UITableViewDelegate {
}

extension AllWordingPageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let imageUrl = todayArray[indexPath.row].url
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "allWordingCellId", for: indexPath) as? AllWordingCell else {
            return UITableViewCell()
        }
        cell.allImageView.kf.setImage(with: URL(string: imageUrl))
        cell.contentMode = .scaleAspectFit
        cell.directionalLayoutMargins = .zero
        cell.layoutMargins = .zero
        cell.contentView.directionalLayoutMargins = .zero
        cell.contentView.layoutMargins = .zero
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 클릭한 셀의 이벤트 처리
        tableView.deselectRow(at: indexPath, animated: true)
        print("todayArray[indexPath.row].url \(todayArray[indexPath.row].url)")
        mainImageUrl = todayArray[indexPath.row].url
        let storyboard: UIStoryboard = UIStoryboard(name: "MainPageView", bundle: nil)
        guard let mainVC = storyboard.instantiateViewController(withIdentifier: "FirstMainPageContainerViewController") as? FirstMainPageContainerViewController else { return }
        // 화면 전환 애니메이션 설정
        mainVC.modalTransitionStyle = .crossDissolve
        // 전환된 화면이 보여지는 방법 설정 (fullScreen)
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todayArray.count
    }
}
