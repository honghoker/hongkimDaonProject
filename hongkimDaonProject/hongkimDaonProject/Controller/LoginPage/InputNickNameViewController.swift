import UIKit

class InputNickNameViewController: UIViewController {

    @IBOutlet weak var overlapText: UILabel!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var nickNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let overlapClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapOverlapCheck(_:)))
        overlapText.isUserInteractionEnabled = true
        overlapText.addGestureRecognizer(overlapClick)
        nickNameTextField.addUnderLine()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        confirmBtn.layer.borderWidth = 1
        confirmBtn.layer.borderColor = UIColor.black.cgColor
        confirmBtn.titleLabel?.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        confirmBtn.addTarget(self, action: #selector(onTapConfirmBtn), for: .touchUpInside)
    }
    override func viewWillLayoutSubviews() {
    }
    @objc
    func onTapConfirmBtn() {
        print("tap")
    }
    @objc
    func onTapOverlapCheck(_ gesture: UITapGestureRecognizer) {
        print("overlap tap")
    }
}

extension UITextField {
    func addUnderLine () {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: self.bounds.height + 10, width: self.bounds.width, height: 1)
        bottomLine.backgroundColor = UIColor.lightGray.cgColor
        self.borderStyle = UITextField.BorderStyle.none
        self.layer.addSublayer(bottomLine)
    }
}
