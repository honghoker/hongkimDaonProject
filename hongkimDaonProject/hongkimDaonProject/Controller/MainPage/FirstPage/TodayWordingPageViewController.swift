import UIKit
import FirebaseStorage
import Kingfisher
import RealmSwift
import FirebaseFirestore

public var mainImageUrl = ""

class TodayWordingPageViewController: UIViewController {
    var realm: Realm!
    let database = Firestore.firestore()
    @IBOutlet weak var imageView: UIImageView!
    private let storage = Storage.storage().reference()
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapImage(_:)))
        imageView.image = UIImage(named: "testPage")
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageClick)
        // MARK: 성훈 위에 주석하고 밑에 작업
        //        let imageClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapImage(_:)))
        //        let beforeImageURL = mainImageUrl
        //        todayImageCacheSet {imageUrl in
        //            print("todayImageCacheSet 완료 \(imageUrl)")
        //            if beforeImageURL != "" {
        //                mainImageUrl = beforeImageURL
        //                self.setImageView(url: URL(string: mainImageUrl)!, imageClick: imageClick)
        //            } else {
        //                mainImageUrl = imageUrl
        //                self.setImageView(url: URL(string: mainImageUrl)!, imageClick: imageClick)
        //            }
        //        }
        
        // MARK: 캐시 삭제
        //                        ImageCache.default.clearMemoryCache()
        //                         ImageCache.default.clearDiskCache { print("done clearDiskCache") }
    }
}

extension TodayWordingPageViewController {
    func todayImageCacheSet(completion: @escaping (String) -> Void) {
        // 내부 db today null check
        // empty -> 해당 월 url 다 가져오기
        // isEmpty -> 최근에 받은 url id랑 비교해서 월 변경됐는지 확인
        // 변경됐으면 변경된 월 1일 ~ 오늘까지 다운
        // 변경안됐으면 최근에 받은 일 ~ 오늘까지 다운
        realm = try? Realm()
        let list = realm.objects(Today.self)
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
            // empty
            // store 접근 -> date.millisecondsSince1970 이거보다 큰 것들 다 가져와서 db 저장
            self.database.collection("today").whereField("id", isGreaterThan: Int(nowMonthDate.millisecondsSince1970)).getDocuments { (snapshot, error) in
                if error != nil {
                    print("Error getting documents: \(String(describing: error))")
                } else {
                    for document in (snapshot?.documents)! {
                        guard let id = document.data()["id"] else { return }
                        guard let url = document.data()["url"] else { return }
                        let today = Today()
                        today.id = Int(String(describing: id)) ?? 0
                        today.url = String(describing: url)
                        try? self.realm.write {
                            self.realm.add(today)
                        }
                        mainImageUrl = today.url
                    }}
            }
        } else {
            // realm 접근 -> 최근에 받은 url id 확인해서 월 바꼈는지 확인
            guard let realmImageId = list.last?.id else { return }
            guard let realmImageUrl = list.last?.url else { return }
            guard let imageUrl = URL(string: realmImageUrl) else { return }
            let realmMonthDate = Date(timeIntervalSince1970: (Double(Int(realmImageId)) / 1000.0))
            dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            dateFormatter.dateFormat = "yyyy-MM"
            let realmMonthString = dateFormatter.string(from: realmMonthDate)
            if nowMonthString.suffix(2) != realmMonthString.suffix(2) {
                try? realm.write {
                    realm.deleteAll()
                }
                self.database.collection("today").whereField("id", isGreaterThan: Int(nowMonthDate.millisecondsSince1970)).getDocuments { [self] (snapshot, error) in
                    if error != nil {
                        print("Error getting documents: \(String(describing: error))")
                    } else {
                        for document in (snapshot?.documents)! {
                            guard let id = document.data()["id"] else { return }
                            guard let url = document.data()["url"] else { return }
                            let today = Today()
                            today.id = Int(String(describing: id)) ?? 0
                            today.url = String(describing: url)
                            try? self.realm.write {
                                self.realm.add(today)
                            }
                            mainImageUrl = today.url
                        }}
                }
            } else {
                if nowDayString.suffix(2) == "01" {
                    // if nowString == 마지막 날짜 -> 이미 접속했다 -> 다운 x
                    // else -> 월이 바뀌고 첫 접속이다 -> realm 전체 delete -> 다운 해야함
                    if realmImageId == nowMonthDate.millisecondsSince1970 {
                        mainImageUrl = String(describing: imageUrl)
                    } else {
                        try? realm.write {
                            realm.deleteAll()
                        }
                        self.database.collection("today").whereField("id", isGreaterThan: Int(nowMonthDate.millisecondsSince1970)).getDocuments { (snapshot, error) in
                            if error != nil {
                                print("Error getting documents: \(String(describing: error))")
                            } else {
                                for document in (snapshot?.documents)! {
                                    guard let id = document.data()["id"] else { return }
                                    guard let url = document.data()["url"] else { return }
                                    let today = Today()
                                    today.id = Int(String(describing: id)) ?? 0
                                    today.url = String(describing: url)
                                    try? self.realm.write {
                                        self.realm.add(today)
                                    }
                                    mainImageUrl = today.url
                                }}
                        }
                    }
                } else {
                    // if nowString == 마지막 날짜 -> 이미 접속했다 -> 다운 x
                    if realmImageId == nowDayDate.millisecondsSince1970 {
                        mainImageUrl = String(describing: imageUrl)
                    } else {
                        // else -> 다운 해야함
                        let docRef = self.database.document("today/\(Int(nowDayDate.millisecondsSince1970))")
                        docRef.getDocument { snapshot, error in
                            if let error = error {
                                print("DEBUG: \(error.localizedDescription)")
                                return
                            } else {
                                guard let id = snapshot?.data()?["id"] else { return }
                                guard let url = snapshot?.data()!["url"] else { return }
                                let today = Today()
                                if let resultId = id as? Int {
                                    today.id = resultId
                                }
                                today.url = String(describing: url)
                                try? self.realm.write {
                                    self.realm.add(today)
                                }
                                guard let imageUrl = URL(string: String(describing: url)) else { return }
                                mainImageUrl = String(describing: imageUrl)
                            }
                        }
                    }
                }
            }
        }
        completion(mainImageUrl)
    }
}

extension TodayWordingPageViewController {
    func setImageView(url: URL, imageClick: UITapGestureRecognizer) {
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(imageClick)
        self.imageView.kf.indicatorType = .activity
        self.imageView.kf.setImage(with: url, options: [.transition(.fade(1.2))])
    }
}

extension TodayWordingPageViewController {
    @objc
    func onTapImage(_ gesture: UITapGestureRecognizer) {
        guard let nextView = self.storyboard?.instantiateViewController(identifier: "AlphaMainPageContainerViewController") as? AlphaMainPageContainerViewController else {
            return
        }
        nextView.modalPresentationStyle = .fullScreen
        self.present(nextView, animated: false, completion: nil)
    }
}

extension UIImageView {
    func setImage(with urlString: String) {
        ImageCache.default.retrieveImage(forKey: urlString, options: nil) { result in
            switch result {
            case .success(let value):
                if let image = value.image {
                    // 캐시가 존재하는 경우
                    self.image = image
                } else {
                    // 캐시가 존재하지 않는 경우
                    guard let url = URL(string: urlString) else { return }
                    let resource = ImageResource(downloadURL: url, cacheKey: urlString)
                    self.kf.setImage(with: resource)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}