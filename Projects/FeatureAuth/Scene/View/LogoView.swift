//
//  LogoView.swift
//  Auth
//
//  Created by Kim SungHun on 2023/10/28.
//  Copyright © 2023 com.hongkim. All rights reserved.
//

import UIKit
import DesignSystem
import SnapKit

final class LogoView: UIView {
	
	//MARK: - Life Cycle
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		addView()
		setLayout()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	//MARK: - Views
	
	private let appIconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "loginViewAppIcon")
		imageView.contentMode = .scaleAspectFit
		imageView.backgroundColor = .yellow
		return imageView
	}()
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.text = "다온"
		label.font = UIFont(name: "JejuMyeongjoOTF", size: 36)
		label.textColor = DesignSystemAsset.Colors.black.color
		return label
	}()
	
	private let subtitleLabel: UILabel = {
		let label = UILabel()
		label.text = "좋은 일이 다오는,"
		label.font = UIFont(name: "JejuMyeongjoOTF", size: 20)
		label.textColor = DesignSystemAsset.Colors.black.color
		return label
	}()
	
	//MARK: - UI
	
	private func addView() {
		[
			appIconImageView,
			titleLabel,
			subtitleLabel
		].forEach {
			addSubview($0)
		}
	}
	
	private func setLayout() {
		appIconImageView.snp.makeConstraints {
			$0.top.equalTo(self.safeAreaLayoutGuide).inset(140)
			$0.centerX.equalToSuperview()
			$0.size.equalTo(100)
		}
		
		subtitleLabel.snp.makeConstraints {
			$0.top.equalTo(appIconImageView.snp.bottom).offset(12)
			$0.centerX.equalToSuperview()
		}
		
		titleLabel.snp.makeConstraints {
			$0.top.equalTo(subtitleLabel.snp.bottom).offset(24)
			$0.centerX.equalToSuperview()
		}
	}
}
