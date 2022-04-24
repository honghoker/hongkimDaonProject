import UIKit
import SnapKit
import Toast_Swift
import FirebaseFirestore
import FirebaseAuth

class SetNotificationPageViewController: UIViewController {
    @IBOutlet weak var switchBtn: UISwitch!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    let database = Firestore.firestore()
    lazy var timeIntValue: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view load")
        setNotificationValue {
            LoadingIndicator.hideLoading()
            print("set 완료")
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
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear")
//        LoadingIndicator.showLoading()
    }
    override func viewWillLayoutSubviews() {
        print("view will layout")
        super.viewWillLayoutSubviews()
        backBtn.layer.borderWidth = 0.0
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        saveBtn.titleLabel?.textAlignment = .center
        saveBtn.layer.borderWidth = 1
        saveBtn.layer.borderColor = UIColor.black.cgColor
        saveBtn.titleLabel?.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        saveBtn.addTarget(self, action: #selector(onTapSaveBtn), for: .touchUpInside)
        LoadingIndicator.showLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            LoadingIndicator.hideLoading()
        }
    }
    override func viewDidLayoutSubviews() {
        print("view did layout")
        textField.text = "변경하기"
    }
    func setNotificationValue(completion: @escaping() -> ()) {
        if let user = Auth.auth().currentUser {
            self.database.document("user/\(user.uid)").getDocument {snaphot, error in
                if let error = error {
                    print("DEBUG: \(error.localizedDescription)")
                    return
                }
                guard let userNotificationTime = snaphot?.data()?["notificationTime"] else { return }
                guard let userSwitchValue = snaphot?.data()?["notification"] else { return }
                self.switchBtn.isOn = userSwitchValue as! Bool
//                print("user userNotificationTime \(userNotificationTime)")
//                let formatter = DateFormatter()
//                formatter.locale = Locale(identifier: "ko_KR")
//                formatter.dateFormat = "HH:mm"
//                let userNotificationDate = Date(timeIntervalSince1970: (Double(Int(String(describing: userNotificationTime))!) / 1000.0))
//                let userNotificationTimeString = formatter.string(from: userNotificationDate)
//                print("userNotificationTimeString \(userNotificationTimeString)")
                self.textLabel.text = String(describing: userNotificationTime)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    completion()
                }
            }
        }
    }
    @objc
    func onTapSaveBtn() {
        if timeIntValue != "" {
            if let user = Auth.auth().currentUser {
                let docRef = database.document("user/\(user.uid)")
                docRef.updateData(["notificationTime": timeIntValue])
            }
            self.view.makeToast("알림시간이 변경되었습니다", duration: 1.5, position: .center)
        }
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
        timeIntValue = formatter.string(from: sender.date)
//        formatter.dateFormat = "yyyy-MM-dd HH:mm"
//        let timeString = formatter.string(from: sender.date)
//        print("timePicker.date \(timeString)")
//        formatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
//        let timeDate: Date = formatter.date(from: timeString)!
//        timeIntValue = timeDate.millisecondsSince1970
//        print("timePicker.date.millisecondsSince1970 \(timeIntValue)")
    }
    @IBAction func switchChanged(_ sender: UISwitch) {
        if let user = Auth.auth().currentUser {
            let docRef = database.document("user/\(user.uid)")
            docRef.updateData(["notification": sender.isOn])
        }
    }
}
