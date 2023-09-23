import UIKit

class MyStorageCell: UITableViewCell {
    static let identifier = "MyStorageCell"
    
    private let storageImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.kf.indicatorType = .activity
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addView()
        setLayout()
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addView() {
        addSubview(storageImageView)
    }
    
    private func setLayout() {
        storageImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(200)
        }
    }
    
    private func setupView() {
        backgroundColor = UIColor(named: "bgColor")
        contentMode = .scaleAspectFit
        directionalLayoutMargins = .zero
        layoutMargins = .zero
        contentView.directionalLayoutMargins = .zero
        contentView.layoutMargins = .zero
    }
    
    func setImage(urlString: String) {
        let url = URL(string: urlString)
        storageImageView.kf.setImage(with: url, options: nil)
    }
}
