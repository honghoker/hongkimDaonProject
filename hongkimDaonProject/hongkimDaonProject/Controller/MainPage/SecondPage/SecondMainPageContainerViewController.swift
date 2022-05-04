import UIKit

class SecondMainPageContainerViewController: UIViewController {
    @IBOutlet weak var setBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(title: "@@@", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        self.navigationItem.backBarButtonItem?.tintColor = .green
    }
    override func viewWillLayoutSubviews() {
        setBtn.titleLabel?.text = ""
    }
    @IBAction
    func testNavigateToSettingPage() {
        let storyboard: UIStoryboard = UIStoryboard(name: "SettingPageView", bundle: nil)
        guard let SettingPageVC = storyboard.instantiateViewController(withIdentifier: "SettingPageViewController") as? SettingPageViewController else { return }
        // MARK: 화면 전환 애니메이션 설정
        SettingPageVC.modalTransitionStyle = .crossDissolve
        // MARK: 전환된 화면이 보여지는 방법 설정
        SettingPageVC.modalPresentationStyle = .fullScreen
        self.present(SettingPageVC, animated: true, completion: nil)
//        self.navigationController?.pushViewController(SettingPageVC, animated: true)
    }
}
