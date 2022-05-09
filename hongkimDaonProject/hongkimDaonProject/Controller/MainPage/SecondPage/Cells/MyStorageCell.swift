import UIKit

class MyStorageCell: UITableViewCell {
    @IBOutlet weak var myStorageImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
    }
}
