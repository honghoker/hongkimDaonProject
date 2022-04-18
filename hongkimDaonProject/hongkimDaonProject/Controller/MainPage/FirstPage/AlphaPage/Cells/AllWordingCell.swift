import UIKit

class AllWordingCell: UITableViewCell {
    @IBOutlet weak var allImageView: UIImageView!
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
//        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0))
//        allWordImageView.snp.makeConstraints { make in
//            make.left.right.equalToSuperview()
//        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            contentView.layer.borderWidth = 2
            contentView.layer.borderColor = UIColor.blue.cgColor
        } else {
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
}
