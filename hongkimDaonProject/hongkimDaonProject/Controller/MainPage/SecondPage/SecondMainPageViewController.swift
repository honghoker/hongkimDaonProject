import UIKit
import Tabman
import Pageboy

class SecondMainPageViewController: TabmanViewController {
    private var viewControllers: Array<UIViewController> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        if let myDiaryViewController = storyboard?.instantiateViewController(withIdentifier: "MyDiaryViewController") as? MyDiaryViewController {
            viewControllers.append(myDiaryViewController)
        }
        if let myStorageViewController = storyboard?.instantiateViewController(withIdentifier: "MyStorageViewController") as? MyStorageViewController {
            viewControllers.append(myStorageViewController)
        }
        self.dataSource = self
        let tabBar = TMBar.ButtonBar()
        tabBar.backgroundView.style = .blur(style: .regular)
        tabBar.buttons.customize { (button) in
            button.tintColor = .gray
            button.selectedTintColor = .black
            button.font = UIFont(name: "JejuMyeongjoOTF", size: 14) ?? UIFont.systemFont(ofSize: 14)
        }
        tabBar.layout.transitionStyle = .snap
        tabBar.layout.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        tabBar.layout.interButtonSpacing = 12
        tabBar.indicator.weight = .custom(value: 1)
        tabBar.indicator.tintColor = .black
        tabBar.indicator.overscrollBehavior = .bounce
        addBar(tabBar, dataSource: self, at: .top)
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
