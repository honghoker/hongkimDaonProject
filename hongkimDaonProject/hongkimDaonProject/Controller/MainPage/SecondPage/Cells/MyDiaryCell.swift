import Foundation
import UIKit

class MyDiaryCell: UITableViewCell {
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var time: UILabel!
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0))
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
    }
}
