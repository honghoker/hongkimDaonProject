//
//  SettingView.swift
//  ProjectDescriptionHelpers
//
//  Created by 홍은표 on 10/14/23.
//

import UIKit
import AuthenticationServices
import Common
import CryptoKit
import DesignSystem
import SnapKit

public class SettingViewController: BaseViewController {
    
    // MARK: - Views
        
    private lazy var backButton = makeButton(
        image: .init(systemName: "chevron.backward"),
        foregroundColor: DesignSystemAsset.Colors.grey500.color,
        actionHandler: didTapBackButton
    )
    
    private let verticalStackView: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 50
        v.alignment = .center
        return v
    }()
    
    private lazy var notificationConfigButton = makeButton(
        title: "알림 설정",
        foregroundColor: DesignSystemAsset.Colors.black.color,
        actionHandler: didTapNotificationSetting
    )
    
    private lazy var darkModeButton = makeButton(
        title: "다크모드 설정",
        foregroundColor: DesignSystemAsset.Colors.black.color,
        actionHandler: didTapChangeDarkMode
    )
    
    private lazy var logoutButton = makeButton(
        title: "로그아웃",
        foregroundColor: DesignSystemAsset.Colors.black.color,
        actionHandler: didTapLogout
    )
    
    private lazy var withdrawalButton = makeButton(
        title: "회원 탈퇴",
        foregroundColor: DesignSystemAsset.Colors.warning300.color,
        actionHandler: didTapWithdrawal
    )
    
    private let divider: UIView = {
        let v = UIView()
        v.backgroundColor = DesignSystemAsset.Colors.grey200.color
        return v
    }()
    
    // MARK: - UI
    
    public override func addView() {
        [
            backButton,
            verticalStackView
        ].forEach {
            view.addSubview($0)
        }
        
        [
            notificationConfigButton,
            darkModeButton,
            divider,
            logoutButton,
            withdrawalButton
        ].forEach {
            verticalStackView.addArrangedSubview($0)
        }
    }
    
    public override func setLayout() {
        backButton.snp.makeConstraints {
            $0.top.left.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
      
        divider.snp.makeConstraints {
            $0.width.equalTo(10)
            $0.height.equalTo(1)
        }
      
        verticalStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    public override func setupView() {
        view.backgroundColor = DesignSystemAsset.Colors.background.color
    }
}

fileprivate extension SettingViewController {
    func makeButton(
        image: UIImage? = nil,
        title: String? = nil,
        foregroundColor: UIColor,
        backgroundColor: UIColor = .clear,
        actionHandler handler: @escaping UIActionHandler
    ) -> UIButton {
        let action = UIAction(handler: handler)
        let button = UIButton(primaryAction: action)
        var config = UIButton.Configuration.filled()
        config.image = image
        config.title = title
        config.baseForegroundColor = foregroundColor
        config.baseBackgroundColor = backgroundColor
        button.configuration = config
        // TODO: JejuMyeongjoOTF, size: 14
        return button
    }
}

// MARK: - Actions

extension SettingViewController {
    private func didTapBackButton(_ action: UIAction) {
        print("didTapBackButton")
    }
  
    private func didTapChangeDarkMode(_ action: UIAction) {
        print("didTapChangeDarkMode")
    }
  
    private func didTapNotificationSetting(_ action: UIAction) {
        print("didTapNotificationSetting")
    }
  
    private func didTapLogout(_ action: UIAction) {
        print("didTapLogout")
    }
  
    private func didTapWithdrawal(_ action: UIAction) {
        print("didTapWithdrawal")
    }
}
