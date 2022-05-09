import UIKit
import Tabman
import Pageboy

class FirstMainPageViewController: TabmanViewController {
    lazy var viewControllers: Array<UIViewController> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        if let todayWordingViewController = storyboard?.instantiateViewController(withIdentifier: "TodayWordingPageViewController") as? TodayWordingPageViewController {
            viewControllers.append(todayWordingViewController)
        }
        if let secondMainViewController = storyboard?.instantiateViewController(withIdentifier: "SecondMainPageContainerViewController") as? SecondMainPageContainerViewController {
            viewControllers.append(secondMainViewController)
        }
        self.dataSource = self
    }
}

extension FirstMainPageViewController: PageboyViewControllerDataSource, TMBarDataSource {
    func barItem(for testBar: TMBar, at index: Int) -> TMBarItemable {
        let item = TMBarItem(title: "")
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
