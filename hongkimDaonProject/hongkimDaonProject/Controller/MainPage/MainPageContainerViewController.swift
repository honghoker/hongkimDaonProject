import UIKit

class MainPageContainerViewController: UIViewController {

    @IBOutlet weak var setBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillLayoutSubviews() {
        setBtn.titleLabel?.text = ""
    }
}
