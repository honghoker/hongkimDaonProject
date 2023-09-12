import UIKit
import Kingfisher
import FirebaseFirestore

class AllWordingPageViewController: UIViewController {
	let database = DatabaseManager.shared.fireStore
	var daonArray: [Daon] = []
	
	let tableView = UITableView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.addSubview(tableView)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
			tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
		])
		
		self.setUI()
		todayImageCacheSet()
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
		//                self.tableView.rowHeight = 300
		//                self.tableView.estimatedRowHeight = 200
		self.tableView.separatorStyle = .none
		self.tableView.delegate = self
		self.tableView.dataSource = self
	}
}

extension AllWordingPageViewController {
	func todayImageCacheSet() {
		let now = Date()
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = NSTimeZone(name: "ko_KR") as TimeZone?
		dateFormatter.dateFormat = "yyyy-MM-dd"
		let nowDayString = dateFormatter.string(from: now)
		dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
		let nowDayDate: Date = dateFormatter.date(from: nowDayString)!
		self.database.collection("daon").whereField("uploadTime", isGreaterThan: Int64(nowDayDate.millisecondsSince1970) - DaonConstants.weakMilliSecond).whereField("uploadTime", isLessThanOrEqualTo: Int(nowDayDate.millisecondsSince1970)).getDocuments { (snapshot, error) in
			if error != nil {
				print("Error getting documents: \(String(describing: error))")
			} else {
				if let snapshot = snapshot {
					self.daonArray = snapshot.documents.map { (daonSnapshot: QueryDocumentSnapshot) -> Daon in
						return try! daonSnapshot.data(as: Daon.self)
					}
					self.tableView.reloadData()
				}
			}
		}
	}
}

extension AllWordingPageViewController: UITableViewDelegate {
}

extension AllWordingPageViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		//        let imageId = daonArray[indexPath.row].uploadTime
		//        let imageUrl = daonArray[indexPath.row].imageUrl
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "allWordingCellId", for: indexPath) as? AllWordingCell else {
			return UITableViewCell()
		}
		//        let dateFormatter = DateFormatter()
		//        let realmDayDate = Date(timeIntervalSince1970: (Double(Int(imageId)) / 1000.0))
		//        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
		//        dateFormatter.dateFormat = "yyyy-MM-dd"
		//        let nowDayString = dateFormatter.string(from: realmDayDate)
		//        cell.backgroundColor = UIColor(named: "bgColor")
		//        cell.dayLabel.text = String(describing: nowDayString)
		//        cell.allImageView.kf.indicatorType = .activity
		//        let url = URL(string: String(describing: imageUrl))
		//        cell.allImageView.kf.setImage(with: url, options: nil)
		
		cell.backgroundColor = .black
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let imageUrl = daonArray[indexPath.row].imageUrl
		let uploadTime = daonArray[indexPath.row].uploadTime
		mainImageUrl = imageUrl
		mainUploadTime = Int(uploadTime)
		// 클릭한 셀의 이벤트 처리
		tableView.deselectRow(at: indexPath, animated: true)
		
		let mainVC = FirstMainPageContainerViewController()
		// 화면 전환 애니메이션 설정
		mainVC.modalTransitionStyle = .crossDissolve
		// 전환된 화면이 보여지는 방법 설정 (fullScreen)
		mainVC.modalPresentationStyle = .fullScreen
		self.present(mainVC, animated: true, completion: nil)
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		//        return daonArray.count
		return 5
	}
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
}
