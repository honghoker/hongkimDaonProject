import UIKit
import SnapKit
import Toast_Swift
import FirebaseFirestore
import FirebaseAuth

class SetNotificationPageViewController: UIViewController {

    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    let database = Firestore.firestore()
    override func viewDidLoad() {
        super.viewDidLoad()
        // true false 도 store 에서 받아서 세팅하고 세팅끝나면 알림 받기 true false이랑 시간변경 저장누르면 store 업데이트시키기, 이거 끝나면 초반세팅 불러올때 컴프레션 블락으로 불러오기전까지 로딩돌리고 다 불러오면 로딩 풀기
        if let user = Auth.auth().currentUser {
            self.database.document("user/\(user.uid)").getDocument {snaphot, error in
                if let error = error {
                    print("DEBUG: \(error.localizedDescription)")
                    return
                }
                guard let userNotificationTime = snaphot?.data()?["notificationTime"] else { return }
                print("user userNotificationTime \(userNotificationTime)")
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ko_KR")
                formatter.dateFormat = "HH:mm"
                let userNotificationDate = Date(timeIntervalSince1970: (Double(Int(String(describing: userNotificationTime))!) / 1000.0))
                let userNotificationTimeString = formatter.string(from: userNotificationDate)
                print("userNotificationTimeString \(userNotificationTimeString)")
                self.textLabel.text = userNotificationTimeString
            }
        }
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.minuteInterval = 10
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.addTarget(self, action: #selector(timePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
        timePicker.frame.size = CGSize(width: 0, height: 250)
        textField.tintColor = .clear
        textField.inputView = timePicker
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        backBtn.layer.borderWidth = 0.0
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        saveBtn.titleLabel?.textAlignment = .center
        saveBtn.layer.borderWidth = 1
        saveBtn.layer.borderColor = UIColor.black.cgColor
        saveBtn.titleLabel?.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        saveBtn.addTarget(self, action: #selector(onTapSaveBtn), for: .touchUpInside)
    }
    override func viewDidLayoutSubviews() {
        textField.text = "변경하기"
    }
    @objc
    func onTapSaveBtn() {
        print("save")
        self.view.makeToast("알림시간이 변경되었습니다", duration: 1.5, position: .center)
    }
    @objc
    func back() {
        self.presentingViewController?.dismiss(animated: false)
    }
    @objc
    func timePickerValueChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "HH:mm"
        textLabel.text = formatter.string(from: sender.date)
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let timeString = formatter.string(from: sender.date)
        print("timePicker.date \(timeString)")
        formatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let timeDate: Date = formatter.date(from: timeString)!
        print("timePicker.date.millisecondsSince1970 \(timeDate.millisecondsSince1970)")
    }
}
