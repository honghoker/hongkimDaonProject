import UIKit

class MyDiaryCell: UITableViewCell {

    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var title: UILabel!
    // 셀이 랜더링(그릴때) 될때
    override func awakeFromNib() {
        super.awakeFromNib()
        print("cell called")
    }
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))
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
