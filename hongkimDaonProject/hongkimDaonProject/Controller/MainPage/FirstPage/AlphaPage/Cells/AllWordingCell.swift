import UIKit

class AllWordingCell: UITableViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var allImageView: UIImageView!
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    override func prepareForReuse() {
        self.dayLabel.text = nil
        self.allImageView.image = nil
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = UIColor(named: "bgColor")
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
        contentMode = .scaleAspectFill
        directionalLayoutMargins = .zero
        layoutMargins = .zero
        contentView.directionalLayoutMargins = .zero
        contentView.layoutMargins = .zero
        self.dayLabel.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        self.dayLabel.backgroundColor = .none
        self.dayLabel.textColor = .white
    }
}
