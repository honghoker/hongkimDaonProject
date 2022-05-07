import UIKit
import SnapKit
import FirebaseFirestore
import Toast_Swift

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
        self.setupHideKeyboardOnTap()
        setNotificationValue {
            LoadingIndicator.hideLoading()
        }
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.minuteInterval = 10
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.addTarget(self, action: #selector(timePickerValueChanged(sender:)), for: UIControl.Event.valueChanged)
        timePicker.frame.size = CGSize(width: 0, height: 250)
        switchBtn.onTintColor = DaonConstants.daonColor
        textField.tintColor = .clear
        textField.inputView = timePicker
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        backBtn.layer.borderWidth = 0.0
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        saveBtn.titleLabel?.textAlignment = .center
        saveBtn.layer.borderWidth = 1
        saveBtn.layer.borderColor = UIColor.label.cgColor
        saveBtn.titleLabel?.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        saveBtn.addTarget(self, action: #selector(onTapSaveBtn), for: .touchUpInside)
        LoadingIndicator.showLoading()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            LoadingIndicator.hideLoading()
        }
    }
    override func viewDidLayoutSubviews() {
        textField.text = "변경하기"
    }
    func setNotificationValue(completion: @escaping() -> ()) {
        if let user = AuthManager.shared.auth.currentUser {
            self.database.document("user/\(user.uid)").getDocument {snaphot, error in
                if let error = error {
                    print("DEBUG: \(error.localizedDescription)")
                    return
                }
                guard let userNotificationTime = snaphot?.data()?["notificationTime"] else { return }
                guard let userSwitchValue = snaphot?.data()?["notification"] else { return }
                self.switchBtn.isOn = userSwitchValue as! Bool
                self.textLabel.text = String(describing: userNotificationTime)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    completion()
                }
            }
        } else {
            self.view.makeToast("네트워크 연결을 확인해주세요.", duration: 1.5, position: .bottom)
        }
    }
    @objc
    func onTapSaveBtn() {
        if timeIntValue != "" {
            print("@@@@@@@@@@@@ 111111")
            if let user = AuthManager.shared.auth.currentUser {
                print("@@@@@@@@@@@@ 222222")
                let docRef = database.document("user/\(user.uid)")
                docRef.updateData(["notificationTime": timeIntValue]) { result in
                    guard result == nil else {
                        self.view.makeToast("알림시간 변경이 실패했습니다.", duration: 1.5, position: .center)
                        return
                    }
                    self.view.makeToast("알림시간이 변경되었습니다", duration: 1.5, position: .center)
                }
            } else {
                self.view.makeToast("네트워크 연결을 확인해주세요.", duration: 1.5, position: .bottom)
            }
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
    }
    @IBAction func switchChanged(_ sender: UISwitch) {
        if let user = AuthManager.shared.auth.currentUser {
            let docRef = database.document("user/\(user.uid)")
            docRef.updateData(["notification": sender.isOn])
        } else {
            self.view.makeToast("네트워크 연결을 확인해주세요.", duration: 1.5, position: .bottom)
        }
    }
}
