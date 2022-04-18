import UIKit
import FirebaseFirestore

class DetailDiaryViewController: UIViewController {
    var docId: String?
    @IBOutlet weak var diaryTitle: UILabel!
    @IBOutlet weak var writeTime: UILabel!
    @IBOutlet weak var diaryImage: UIImageView!
    @IBOutlet weak var diaryContent: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let width = self.view.frame.width
        let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        navigationBar.barTintColor = .blue
        self.view.addSubview(navigationBar)
        Firestore.firestore().collection("diary").document(docId!).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            do {
                let diary: Diary = try document.data(as: Diary.self)
                let url = URL(string: diary.imageUrl)
                var image: UIImage?
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!)
                    DispatchQueue.main.async {
                        image = UIImage(data: data!)
                        self.diaryImage.image = image
                    }
                }
                self.diaryTitle.text = diary.title
                self.diaryContent.text = diary.content
                let myDateFormatter = DateFormatter()
                myDateFormatter.dateFormat = "yyyy년 MM월 dd일 a h:mm" // 2020.08.13 오후 04시 30분
                myDateFormatter.locale = Locale(identifier: "ko_KR") // PM, AM을 언어에 맞게 setting (ex: PM -> 오후)
                let convertNowStr = myDateFormatter.string(from: Date(milliseconds: diary.writeTime)) // 현재 시간의 Date를 format에 맞춰 string으로 반환
                self.writeTime.text = convertNowStr
            } catch {
            }
        }
    }
}
