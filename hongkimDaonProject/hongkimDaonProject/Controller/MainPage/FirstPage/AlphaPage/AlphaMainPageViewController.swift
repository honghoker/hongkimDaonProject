import UIKit
import Tabman
import Pageboy
import FirebaseStorage

class AlphaMainPageViewController: TabmanViewController {
    private var viewControllers: Array<UIViewController> = []
    let isDark = UserDefaults.standard.bool(forKey: "darkModeState")
    var tintColor = UIColor.darkGray
    var selectedTintColor = UIColor(red: 213/255, green: 182/255, blue: 124/255, alpha: 1)
    var uploadTime: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    // MARK: set UI
    func setUI() {
        if let allWordingPageViewController = storyboard?.instantiateViewController(withIdentifier: "AllWordingPageViewController") as? AllWordingPageViewController {
            viewControllers.append(allWordingPageViewController)
        }
        if let alphaTodayWordingPageViewController = storyboard?.instantiateViewController(withIdentifier: "AlphaTodayWordingPageViewController") as? AlphaTodayWordingPageViewController {
            viewControllers.append(alphaTodayWordingPageViewController)
        }
        self.dataSource = self
        let tabBar = TMBar.ButtonBar()
        tabBar.backgroundView.style = .clear
        tabBar.buttons.customize { (button) in
            button.tintColor = self.tintColor
            button.selectedTintColor = self.selectedTintColor
            button.font = UIFont(name: "JejuMyeongjoOTF", size: 14) ?? UIFont.systemFont(ofSize: 14)
        }
        tabBar.layout.transitionStyle = .snap
        tabBar.layout.alignment = .centerDistributed
        tabBar.layout.interButtonSpacing = 12
        tabBar.indicator.weight = .custom(value: 1)
        tabBar.indicator.tintColor = selectedTintColor
        tabBar.indicator.overscrollBehavior = .bounce
        addBar(tabBar, dataSource: self, at: .top)
    }
}

extension AlphaMainPageViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for testBar: TMBar, at index: Int) -> TMBarItemable {
        let item = TMBarItem(title: "")
        let title: String = index == 0 ? "전체" : "오늘"
        item.title = title
        return item
    }
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return .at(index: 1)
    }
}
