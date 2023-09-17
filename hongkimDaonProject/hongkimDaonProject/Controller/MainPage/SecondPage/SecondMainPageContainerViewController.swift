import UIKit

class SecondMainPageContainerViewController: UIViewController {
	
	let setBtn = UIButton()
	let secondMainPageView = SecondMainPageViewController()
	
	// SecondMainPageViewController에 연결되어있는 뷰 2개 스토리보드 제거하고 연결해봐야할듯
	// 스토리보드 지우고 커플앱 코드 그대로 붙여넣었는데 안뜸
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.addSubview(setBtn)
		setBtn.translatesAutoresizingMaskIntoConstraints = false
		setBtn.setImage(UIImage(systemName: "gearshape"), for: .normal)
		
		NSLayoutConstraint.activate([
			setBtn.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 64),
			setBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)
			// secondMainPageView랑 bottom 32
		])
		setBtn.addTarget(self, action: #selector(setBtnTap), for: .touchUpInside)
		
		self.addChild(secondMainPageView)
		view.addSubview(secondMainPageView.view)
		secondMainPageView.didMove(toParent: self)
		secondMainPageView.view.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			secondMainPageView.view.topAnchor.constraint(equalTo: setBtn.bottomAnchor, constant: 24),
			secondMainPageView.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			secondMainPageView.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			secondMainPageView.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
		])
	}
	
	override func viewWillLayoutSubviews() {
		setBtn.titleLabel?.text = ""
	}
	
	@objc
	func setBtnTap() {
		print("tap")
		//        let storyboard: UIStoryboard = UIStoryboard(name: "SettingPageView", bundle: nil)
		//        guard let SettingPageVC = storyboard.instantiateViewController(withIdentifier: "SettingPageViewController") as? SettingPageViewController else { return }
		//        // 화면 전환 애니메이션 설정
		//        SettingPageVC.modalTransitionStyle = .crossDissolve
		//        // 전환된 화면이 보여지는 방법 설정
		//        SettingPageVC.modalPresentationStyle = .fullScreen
		//        self.present(SettingPageVC, animated: true, completion: nil)
	}
}
