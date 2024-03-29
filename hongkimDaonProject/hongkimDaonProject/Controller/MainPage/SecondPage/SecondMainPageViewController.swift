import UIKit
import Tabman
import Pageboy

class SecondMainPageViewController: TabmanViewController {
    private var viewControllers: Array<UIViewController> = []
    private let isDark = UserDefaults.standard.bool(forKey: "darkModeState")
    private var tintColor = UserDefaults.standard.bool(forKey: "darkModeState") == true ? UIColor.darkGray : UIColor.lightGray
    private var selectedTintColor = UserDefaults.standard.bool(forKey: "darkModeState") == true ? UIColor.lightGray : UIColor.darkGray
    private let tabBar = TMBar.ButtonBar()
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.backgroundColor = UIColor(named: "bgColor")
        setUI()
        dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "darkModeState") == true {
            tintColor = UIColor.darkGray
            selectedTintColor = UIColor.lightGray
            tabBar.buttons.customize { (button) in
                button.tintColor = self.tintColor
                button.selectedTintColor = self.selectedTintColor
            }
            tabBar.indicator.tintColor = selectedTintColor
        } else {
            tintColor = UIColor.lightGray
            selectedTintColor = UIColor.darkGray
            tabBar.buttons.customize { (button) in
                button.tintColor = self.tintColor
                button.selectedTintColor = self.selectedTintColor
            }
            tabBar.indicator.tintColor = selectedTintColor
        }
    }
    // MARK: set UI
    func setUI() {
        tabBar.backgroundView.style = .clear
        tabBar.buttons.customize { (button) in
            button.tintColor = self.tintColor
            button.selectedTintColor = self.selectedTintColor
            button.font = UIFont(name: "JejuMyeongjoOTF", size: 14) ?? UIFont.systemFont(ofSize: 14)
        }
        tabBar.layout.transitionStyle = .snap
        tabBar.layout.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        tabBar.layout.interButtonSpacing = 12
        tabBar.indicator.weight = .custom(value: 1)
        tabBar.indicator.tintColor = selectedTintColor
        tabBar.indicator.overscrollBehavior = .bounce
        addBar(tabBar, dataSource: self, at: .top)

        viewControllers.append(MyDiaryViewController())
        viewControllers.append(MyStorageViewController())
    }
}

extension SecondMainPageViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for testBar: TMBar, at index: Int) -> TMBarItemable {
        let item = TMBarItem(title: "")
        let title: String = index == 0 ? "나의 일기" : "나의 보관함"
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
        return .at(index: 0)
    }
}
