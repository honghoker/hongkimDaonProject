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
        setBtn.addTarget(self, action: #selector(navigateToSettingPage), for: .touchUpInside)
    }
    @objc
    func navigateToSettingPage() {
        let storyboard: UIStoryboard = UIStoryboard(name: "SettingPageView", bundle: nil)
        guard let SettingPageVC = storyboard.instantiateViewController(withIdentifier: "SettingPageViewController") as? SettingPageViewController else {
            return }
        SettingPageVC.modalTransitionStyle = .coverVertical
        SettingPageVC.modalPresentationStyle = .fullScreen
        self.present(SettingPageVC, animated: true, completion: nil)
    }
}
