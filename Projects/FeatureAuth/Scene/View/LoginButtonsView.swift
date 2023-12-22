//
//  LoginButtonsView.swift
//  Auth
//
//  Created by Kim SungHun on 2023/10/28.
//  Copyright © 2023 com.hongkim. All rights reserved.
//

import UIKit
import AuthenticationServices
import Common
import CryptoKit
import DesignSystem
import SnapKit

final class LoginButtonsView: BaseView {
	
	// MARK: - Life Cycle
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Views
	
	private let dividerStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.distribution = .fillEqually
		stackView.alignment = .center
		stackView.spacing = 10
		stackView.axis = .horizontal
		return stackView
	}()
	
	private let leftDivider: UIView = {
		let view = UIView()
		view.backgroundColor = DesignSystemAsset.Colors.black.color
		return view
	}()
	
	private let rightDivider: UIView = {
		let view = UIView()
		view.backgroundColor = DesignSystemAsset.Colors.black.color
		return view
	}()
	
	private let snsLoginLabel: UILabel = {
		let label = UILabel()
		label.text = "SNS 로그인"
        label.font = .caption
		label.textColor = DesignSystemAsset.Colors.black.color
		label.textAlignment = .center
		return label
	}()
	
	private let loginButtonStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.spacing = 48
		stackView.axis = .horizontal
		return stackView
	}()
	
	private lazy var googleLoginButton: UIButton = {
		let action = UIAction(handler: didTapGoogleLoginButton)
		var button = UIButton(primaryAction: action)
		var config = UIButton.Configuration.plain()
		config.image = UIImage(systemName: "square.and.arrow.up.fill")
		config.baseForegroundColor = DesignSystemAsset.Colors.black.color
		button.configuration = config
		return button
	}()
	
	private lazy var appleLoginButton: UIButton = {
		let action = UIAction(handler: didTapAppleLoginButton)
		let button = UIButton(primaryAction: action)
		var config = UIButton.Configuration.plain()
		config.image = UIImage(systemName: "square.and.arrow.up.fill")
		config.baseForegroundColor = DesignSystemAsset.Colors.black.color
		button.configuration = config
		return button
	}()
	
	private lazy var previewButton: UIButton = {
		let action = UIAction(handler: didTapPreviewButton)
		let button = UIButton(primaryAction: action)
		var config = UIButton.Configuration.plain()
		config.title = "오늘의 글 미리보기"
		config.baseForegroundColor = DesignSystemAsset.Colors.grey200.color
		button.configuration = config
        // TODO: JejuMyeongjoOTF, size: 12
		return button
	}()
	
	// MARK: - UI
	
	override func addView() {
		[
			leftDivider,
			snsLoginLabel,
			rightDivider
		].forEach {
			dividerStackView.addArrangedSubview($0)
		}
		
		[
			googleLoginButton,
			appleLoginButton
		].forEach {
			loginButtonStackView.addArrangedSubview($0)
		}
		
		[
			dividerStackView,
			loginButtonStackView,
			previewButton
		].forEach {
			addSubview($0)
		}
	}
	
	override func setLayout() {
		[
			leftDivider,
			rightDivider
		].forEach {
			$0.snp.makeConstraints {
				$0.height.equalTo(1)
			}
		}
		
		dividerStackView.snp.makeConstraints {
			$0.horizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(32)
		}
		
		[
			googleLoginButton,
			appleLoginButton
		]
			.forEach {
			$0.snp.makeConstraints {
				$0.size.equalTo(48)
			}
		}
		
		loginButtonStackView.snp.makeConstraints {
			$0.top.equalTo(dividerStackView.snp.bottom).offset(40)
			$0.centerX.equalToSuperview()
		}
		
		previewButton.snp.makeConstraints {
			$0.top.equalTo(loginButtonStackView.snp.bottom).offset(30)
			$0.centerX.equalToSuperview()
			$0.bottom.equalTo(self.safeAreaLayoutGuide).inset(50)
		}
	}
	
	override func setupView() { }
}

//MARK: - Actions

private extension LoginButtonsView {
	func didTapGoogleLoginButton(_ action: UIAction) {
		print("didTapGoogleLoginButton")
	}
	func didTapAppleLoginButton(_ action: UIAction) {
		print("didTapAppleLoginButton")
	}
	func didTapPreviewButton(_ action: UIAction) {
		print("didTapPreviewButton")
	}
}
