import UIKit
import FirebaseStorage
import RealmSwift
import Kingfisher
import FirebaseFirestore

class AllWordingPageViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var realm: Realm!
    let database = DatabaseManager.shared.fireStore
    var daonArray: Array<RealmDaon>! = []
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try? Realm()
        LoadingIndicator.showLoading()
        todayImageCacheSet { complete in
            let result = self.realm.objects(RealmDaon.self)
            self.daonArray = Array(result)
            self.setUI()
            LoadingIndicator.hideLoading()
        }
    }
    // MARK: set UI
    func setUI() {
        let allWordingTableViewCellNib = UINib(nibName: String(describing: AllWordingCell.self), bundle: nil)
        self.tableView.backgroundColor = UIColor(named: "bgColor")
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

extension AllWordingPageViewController {
    func todayImageCacheSet(completion: @escaping (Bool) -> Void) {
        // 내부 db today null check
        // empty -> 해당 월 url 다 가져오기
        // isEmpty -> 최근에 받은 url id랑 비교해서 월 변경됐는지 확인
        // 변경됐으면 변경된 월 1일 ~ 오늘까지 다운
        // 변경안됐으면 최근에 받은 일 ~ 오늘까지 다운
        realm = try? Realm()
        //            var daonUploadTime  = 0
        let list = realm.objects(RealmDaon.self)
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
        dateFormatter.dateFormat = "yyyy-MM"
        let nowMonthString = dateFormatter.string(from: now)
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let nowMonthDate: Date = dateFormatter.date(from: nowMonthString)!
        dateFormatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let nowDayString = dateFormatter.string(from: now)
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let nowDayDate: Date = dateFormatter.date(from: nowDayString)!
        if list.count == .zero {
            // empty -> store 접근 -> date.millisecondsSince1970 이거보다 큰 것들 다 가져와서 db 저장
            self.database.collection("daon").whereField("uploadTime", isGreaterThanOrEqualTo: Int(nowMonthDate.millisecondsSince1970)).whereField("uploadTime", isLessThanOrEqualTo: Int(nowDayDate.millisecondsSince1970)).getDocuments { (snapshot, error) in
                if error != nil {
                    print("Error getting documents: \(String(describing: error))")
                } else {
                    for document in (snapshot?.documents)! {
                        guard let uploadTime = document.data()["uploadTime"] else { return }
                        guard let imageUrl = document.data()["imageUrl"] else { return }
                        let daon = RealmDaon()
                        daon.imageData = try! Data(contentsOf: URL(string: String(describing: imageUrl))!)
                        daon.uploadTime = Int(String(describing: uploadTime)) ?? 0
                        try? self.realm.write {
                            self.realm.add(daon)
                        }
                    }
                    completion(true)
                }            }
        } else {
            // realm 접근 -> 최근에 받은 url id 확인해서 월 바꼈는지 확인
            guard let realmImageId = list.last?.uploadTime else { return }
            guard let realmImageData = list.last?.imageData else { return }
            let realmMonthDate = Date(timeIntervalSince1970: (Double(Int(realmImageId)) / 1000.0))
            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            dateFormatter.dateFormat = "yyyy-MM"
            let realmMonthString = dateFormatter.string(from: realmMonthDate)
            if nowMonthString.suffix(2) != realmMonthString.suffix(2) {
                try? realm.write {
                    realm.deleteAll()
                }
                self.database.collection("daon").whereField("uploadTime", isGreaterThanOrEqualTo: Int(nowMonthDate.millisecondsSince1970)).whereField("uploadTime", isLessThanOrEqualTo: Int(nowDayDate.millisecondsSince1970)).getDocuments { [self] (snapshot, error) in
                    if error != nil {
                        print("Error getting documents: \(String(describing: error))")
                    } else {
                        for document in (snapshot?.documents)! {
                            guard let uploadTime = document.data()["uploadTime"] else { return }
                            guard let imageUrl = document.data()["imageUrl"] else { return }
                            let daon = RealmDaon()
                            daon.imageData = try! Data(contentsOf: URL(string: String(describing: imageUrl))!)
                            daon.uploadTime = Int(String(describing: uploadTime)) ?? 0
                            try? self.realm.write {
                                self.realm.add(daon)
                            }
                        }
                        completion(true)
                    }
                }
            } else {
                if nowDayString.suffix(2) == "01" {
                    // if nowString == 마지막 날짜 -> 이미 접속했다 -> 다운 x
                    // else -> 월이 바뀌고 첫 접속이다 -> realm 전체 delete -> 다운 해야함
                    if realmImageId == nowMonthDate.millisecondsSince1970 {
                        completion(true)
                    } else {
                        try? realm.write {
                            realm.deleteAll()
                        }
                        self.database.collection("daon").whereField("uploadTime", isGreaterThanOrEqualTo: Int(nowMonthDate.millisecondsSince1970)).whereField("uploadTime", isLessThanOrEqualTo: Int(nowDayDate.millisecondsSince1970)).getDocuments { (snapshot, error) in
                            if error != nil {
                                print("Error getting documents: \(String(describing: error))")
                            } else {
                                for document in (snapshot?.documents)! {
                                    guard let uploadTime = document.data()["uploadTime"] else { return }
                                    guard let imageUrl = document.data()["imageUrl"] else { return }
                                    let daon = RealmDaon()
                                    daon.imageData = try! Data(contentsOf: URL(string: String(describing: imageUrl))!)
                                    daon.uploadTime = Int(String(describing: uploadTime)) ?? 0
                                    try? self.realm.write {
                                        self.realm.add(daon)
                                    }
                                }
                                completion(true)
                            }
                        }
                    }
                } else {
                    // if nowString == 마지막 날짜 -> 이미 접속했다 -> 다운 x
                    if realmImageId == nowDayDate.millisecondsSince1970 {
                        completion(true)
                    } else {
                        // else -> 다운 해야함
                        self.database.collection("daon").whereField("uploadTime", isGreaterThan: Int(realmMonthDate.millisecondsSince1970)).whereField("uploadTime", isLessThanOrEqualTo: Int(nowDayDate.millisecondsSince1970)).getDocuments { (snapshot, error) in
                            if error != nil {
                                print("Error getting documents: \(String(describing: error))")
                            } else {
                                for document in (snapshot?.documents)! {
                                    guard let uploadTime = document.data()["uploadTime"] else { return }
                                    guard let imageUrl = document.data()["imageUrl"] else { return }
                                    let daon = RealmDaon()
                                    daon.imageData = try! Data(contentsOf: URL(string: String(describing: imageUrl))!)
                                    daon.uploadTime = Int(String(describing: uploadTime)) ?? 0
                                    try? self.realm.write {
                                        self.realm.add(daon)
                                    }
                                }
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension AllWordingPageViewController: UITableViewDelegate {
}

extension AllWordingPageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let imageData = daonArray[indexPath.row].imageData
        let imageId = daonArray[indexPath.row].uploadTime
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "allWordingCellId", for: indexPath) as? AllWordingCell else {
            return UITableViewCell()
        }
        cell.backgroundColor = UIColor(named: "bgColor")
        cell.allImageView.image = UIImage(data: imageData)
        let dateFormatter = DateFormatter()
        let realmDayDate = Date(timeIntervalSince1970: (Double(Int(imageId)) / 1000.0))
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let nowDayString = dateFormatter.string(from: realmDayDate)
        cell.dayLabel.text = String(describing: nowDayString)
        cell.dayLabel.textColor = .white
        cell.dayLabel.backgroundColor = .none
        cell.dayLabel.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
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
        mainImageData = daonArray[indexPath.row].imageData
        mainUploadTime = daonArray[indexPath.row].uploadTime
        let storyboard: UIStoryboard = UIStoryboard(name: "MainPageView", bundle: nil)
        guard let mainVC = storyboard.instantiateViewController(withIdentifier: "FirstMainPageContainerViewController") as? FirstMainPageContainerViewController else { return }
        // 화면 전환 애니메이션 설정
        mainVC.modalTransitionStyle = .crossDissolve
        // 전환된 화면이 보여지는 방법 설정 (fullScreen)
        mainVC.modalPresentationStyle = .fullScreen
        self.present(mainVC, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daonArray.count
    }
}
