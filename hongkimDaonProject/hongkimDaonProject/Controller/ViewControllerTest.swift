import UIKit

class ViewControllerTest: UIViewController {

    @IBOutlet weak var setBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
//        setBtn.titleLabel?.text = .none
    }
    override func viewDidLayoutSubviews() {
//        setBtn.titleLabel?.text = .none
    }
    override func viewWillLayoutSubviews() {
        setBtn.titleLabel?.text = .none
    }
}
