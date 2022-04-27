import UIKit
import FirebaseFirestore
import Toast_Swift

class DetailDiaryViewController: UIViewController {
    var docId: String?
    var delegate: DispatchDiary?
    var diary: Diary?
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var diaryTitle: UILabel!
    @IBOutlet weak var writeTime: UILabel!
    @IBOutlet weak var diaryImage: UIImageView!
    @IBOutlet weak var diaryContent: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var editBtn: UIBarButtonItem!
    @IBOutlet weak var removeBtn: UIBarButtonItem!
    var imageLoadComplete: Bool = false
    var scrolldirection: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        Firestore.firestore().collection("diary").document(docId!).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard document.data() != nil else {
                print("Document data was empty.")
                return
            }
            guard let diary: Diary = try? document.data(as: Diary.self) else { return }
            self.diary = diary
            if diary.imageUrl == "" {
                // MARK: 이미지 뷰 크기 0으로 조절
                self.imageLoadComplete = true
            } else {
                let url = URL(string: diary.imageUrl)
                var image: UIImage?
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!)
                    DispatchQueue.main.async {
                        image = UIImage(data: data!)
                        self.diaryImage.image = image
                        self.imageLoadComplete = true
                    }
                }
                self.diaryContent.text = diary.content
                let myDateFormatter = DateFormatter()
                myDateFormatter.dateFormat = "yyyy년 MM월 dd일 a h:mm" // 2020.08.13 오후 04시 30분
                myDateFormatter.locale = Locale(identifier: "ko_KR") // PM, AM을 언어에 맞게 setting (ex: PM -> 오후)
                let convertNowStr = myDateFormatter.string(from: Date(milliseconds: diary.writeTime)) // 현재 시간의 Date를 format에 맞춰 string으로 반환
                self.writeTime.text = convertNowStr
            }
        }
    }
}

extension DetailDiaryViewController {
    @objc
    func back() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func tapEditBtn(_ sender: Any) {
        // MARK: 이미지 저장이 아직 덜 된거 처리
        // MARK: 이미지 불러오기가 아직 덜 될거 처리
        if let diary = self.diary {
            let storyboard: UIStoryboard = UIStoryboard(name: "EditDiaryPageView", bundle: nil)
            guard let editDiaryPageVC = storyboard.instantiateViewController(withIdentifier: "EditDiaryPageViewController") as? EditDiaryPageViewController else { return }
            editDiaryPageVC.diary = diary
            editDiaryPageVC.image = self.diaryImage.image
            editDiaryPageVC.modalTransitionStyle = .crossDissolve
            editDiaryPageVC.modalPresentationStyle = .fullScreen
            self.present(editDiaryPageVC, animated: true, completion: nil)
        }
    }
    @IBAction func tapRemoveBtn(_ sender: Any) {
        let alert = UIAlertController(title: "일기를 삭제하시겠습니까?",
                                      message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: { _ in
            // Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: { _ in
            Firestore.firestore().collection("diary").document(self.docId!).delete { result in
                guard result == nil else {
                    self.view.makeToast("일기 삭제에 실패했습니다.", duration: 1.5, position: .bottom)
                    return
                }
                self.delegate?.delete(self, Delete: self.docId)
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                self.view.makeToast("일기를 삭제했습니다.", duration: 1.5, position: .bottom)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension DetailDiaryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if translation.y > 0 {
            if self.scrolldirection == true {
                DispatchQueue.main.async {
                    UIView.transition(with: self.toolBar, duration: 0.6,
                                      options: .transitionCrossDissolve,
                                      animations: {
                        self.toolBar.isHidden = false
                    })
                }
                self.scrolldirection = false
            }
        } else {
            if self.scrolldirection == false {
                DispatchQueue.main.async {
                    UIView.transition(with: self.toolBar, duration: 0.6,
                                      options: .transitionCrossDissolve,
                                      animations: {
                        self.toolBar.isHidden = true
                    })
                }
                self.scrolldirection = true
            }
        }
    }
}
