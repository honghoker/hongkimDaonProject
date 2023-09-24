import UIKit
import SnapKit
import FirebaseFirestore

class SetNotificationPageViewController: UIViewController {
    
    private let database = Firestore.firestore()
    private var timeIntValue: String = ""
    
    private let verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 32
        return stackView
    }()
    
    private let notificationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()
 
    private let notificationLabel: UILabel = {
        let label = UILabel()
        label.text = "알림 받기"
        label.font = UIFont(name: "JejuMyeongjoOTF", size: 16)
        label.textColor = .label
        return label
    }()
    
    private lazy var notificationSwitch: UISwitch = {
        let view = UISwitch()
        view.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        view.onTintColor = DaonConstants.daonColor
        return view
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        button.setTitle("저장", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.label.cgColor
        button.titleLabel?.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(.init(systemName: "chevron.backward"), for: .normal)
        button.tintColor = .systemGray
        button.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return button
    }()
    
    private let timeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private let timeTextLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .label
        label.font = UIFont(name: "JejuMyeongjoOTF", size: 18)
        return label
    }()
    
    // FIXME: Button으로 변경 필요
    private lazy var timeChangeButton: UITextField = {
        let textField = UITextField()
        textField.text = "변경하기"
        textField.textColor = .label
        textField.tintColor = .clear
        textField.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        textField.inputView = timePicker
        return textField
    }()
    
    private lazy var timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.minuteInterval = 10
        picker.preferredDatePickerStyle = .wheels
        picker.addTarget(self, action: #selector(timePickerValueChanged), for: .valueChanged)
        picker.frame.size = CGSize(width: 0, height: 250)
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addView()
        setLayout()
        setupView()
        
        setupHideKeyboardOnTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // FIXME: viewDidLoad로 이동, loading Indicator 표시안되는 문제 수정 필요
        fetchNotificationSetting()
    }

    private func addView() {
        [
            notificationLabel,
            notificationSwitch
        ].forEach {
            notificationStackView.addArrangedSubview($0)
        }
        
        [
            timeTextLabel,
            timeChangeButton
        ].forEach {
            timeStackView.addArrangedSubview($0)
        }
        
        [
            notificationStackView,
            timeStackView,
            saveButton
        ].forEach {
            verticalStackView.addArrangedSubview($0)
        }
        
        [
            backButton,
            verticalStackView
        ].forEach {
            view.addSubview($0)
        }
    }
    
    private func setLayout() {
        backButton.snp.makeConstraints {
            $0.top.left.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        saveButton.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        verticalStackView.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(60)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(32)
        }
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(named: "bgColor")
    }
    
    private func fetchNotificationSetting() {
        if let user = AuthManager.shared.auth.currentUser {
            LoadingIndicator.showLoading()
            
            database.document("user/\(user.uid)").getDocument { [weak self] (snaphot, error) in
                guard error == nil else { return }
                
                guard
                    let userNotificationTime = snaphot?.data()?["notificationTime"] as? String,
                    let userSwitchValue = snaphot?.data()?["notification"] as? Bool
                else {
                    return
                }
                
                self?.notificationSwitch.isOn = userSwitchValue
                self?.timeTextLabel.text = userNotificationTime
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    LoadingIndicator.hideLoading()
                }
            }
        } else {
//            self.view.makeToast("네트워크 연결을 확인해주세요.", duration: 1.5, position: .bottom)
        }
    }
}

// MARK: Actions

extension SetNotificationPageViewController {
    @objc private func didTapSaveButton() {
        if timeIntValue != "" {
            if let user = AuthManager.shared.auth.currentUser {
                let docRef = database.document("user/\(user.uid)")
                docRef.updateData(["notificationTime": timeIntValue]) { result in
                    guard result == nil else {
//                        self.view.makeToast("알림시간 변경이 실패했습니다.", duration: 1.5, position: .center)
                        return
                    }
//                    self.view.makeToast("알림시간이 변경되었습니다", duration: 1.5, position: .center)
                }
            } else {
//                self.view.makeToast("네트워크 연결을 확인해주세요.", duration: 1.5, position: .bottom)
            }
        }
    }
    
    @objc private func didTapBackButton() {
        presentingViewController?.dismiss(animated: false)
    }
    
    @objc private func timePickerValueChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "HH:mm"
        timeTextLabel.text = formatter.string(from: sender.date)
        timeIntValue = formatter.string(from: sender.date)
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        if let user = AuthManager.shared.auth.currentUser {
            let docRef = database.document("user/\(user.uid)")
            docRef.updateData(["notification": sender.isOn])
        } else {
//            self.view.makeToast("네트워크 연결을 확인해주세요.", duration: 1.5, position: .bottom)
        }
    }
}
