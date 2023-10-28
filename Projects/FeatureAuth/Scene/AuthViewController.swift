//
//  AuthViewController.swift
//  ProjectDescriptionHelpers
//
//  Created by 홍은표 on 10/14/23.
//

import UIKit
import AuthenticationServices
import CryptoKit
import Common
import DesignSystem
import SnapKit

public final class AuthViewController: BaseViewController {
	
	//MARK: - Life Cycle
	
	public override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	public override func viewDidAppear(_ animated: Bool) { }
	
	//MARK: - Views
	
	private let logoView = LogoView()
	private let loginButtonsView = LoginButtonsView()
	
	//MARK: - UI
	
	public override func addView() {
		[logoView, loginButtonsView].forEach {
			view.addSubview($0)
		}
	}
	
	public override func setLayout() {
		logoView.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.leading.trailing.equalToSuperview()
			$0.height.equalToSuperview().multipliedBy(0.5)
		}
		
		loginButtonsView.snp.makeConstraints {
			$0.top.equalTo(logoView.snp.bottom)
			$0.bottom.equalToSuperview()
			$0.leading.trailing.equalToSuperview()
		}
	}
	
	public override func setupView() {
		view.backgroundColor = DesignSystemAsset.Colors.background.color
	}
}
