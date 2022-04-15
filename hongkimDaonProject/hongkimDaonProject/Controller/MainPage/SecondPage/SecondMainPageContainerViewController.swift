import UIKit
import Firebase

class SecondMainPageContainerViewController: UIViewController {
    @IBOutlet weak var setBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillLayoutSubviews() {
        setBtn.titleLabel?.text = ""
        setBtn.addTarget(self, action: #selector(logout), for: .touchUpInside)
    }
    @objc
    func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.navigationController?.popToRootViewController(animated: true)
            self.presentingViewController?.dismiss(animated: true)
            print("@@@@@@@@ logout complete")
        } catch let signOutError as NSError {
            print("ERROR: signOutError \(signOutError.localizedDescription)")
        }
    }
}
