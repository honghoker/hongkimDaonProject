import UIKit

class AllWordingCell: UITableViewCell {
    @IBOutlet weak var allImageView: UIImageView!
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0))
    }
}
