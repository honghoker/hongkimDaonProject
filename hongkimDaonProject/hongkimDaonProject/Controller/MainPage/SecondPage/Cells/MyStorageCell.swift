import UIKit

class MyStorageCell: UITableViewCell {
    @IBOutlet weak var myStorageImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
//        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
    }
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        contentView.layer.borderWidth = 1
//        contentView.layer.borderColor = UIColor.lightGray.cgColor
//    }
}
