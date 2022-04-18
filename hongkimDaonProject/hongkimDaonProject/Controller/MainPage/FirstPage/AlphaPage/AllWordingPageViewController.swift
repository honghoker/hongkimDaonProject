import UIKit
import FirebaseStorage

class AllWordingPageViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    //    var image: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        let allWordingTableViewCellNib = UINib(nibName: String(describing: AllWordingCell.self), bundle: nil)
        self.tableView.register(allWordingTableViewCellNib, forCellReuseIdentifier: "allWordingCellId")
        self.tableView.separatorInset = .zero
        self.tableView.directionalLayoutMargins = .zero
        self.tableView.layoutMargins = .zero
        self.tableView.rowHeight = UITableView.automaticDimension
        //        self.tableView.rowHeight = 300
        //        self.tableView.estimatedRowHeight = 200
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
}

func cropToBounds(image: UIImage, width: Double, height: Double) ->
UIImage {
    let cgimage = image.cgImage!
    let contextImage: UIImage = UIImage(cgImage: cgimage)
    let contextSize: CGSize = contextImage.size
    var posX: CGFloat = 0.0
    var posY: CGFloat = 0.0
    var cgwidth: CGFloat = CGFloat(width)
    var cgheight: CGFloat = CGFloat(height)
    // See what size is longer and create the center off of that
    if contextSize.width > contextSize.height {
        posX = ((contextSize.width - contextSize.height) / 2)
        posY = 0
        cgwidth = contextSize.height
        cgheight = contextSize.height
    } else {
        posX = 0
        posY = ((contextSize.height - contextSize.width) / 2)
        //                cgwidth = UIScreen.main.bounds.size.width
        cgwidth = contextSize.width
        cgheight = contextSize.width
    }
    print("cgwidth \(cgwidth)")
    print("cgheight \(cgheight)")
    let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
    // Create bitmap image from context using the rect
    let imageRef: CGImage = cgimage.cropping(to: rect)!
    // Create a new image based on the imageRef and rotate back to the original orientation
    let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
    return image
}

extension AllWordingPageViewController: UITableViewDelegate {
}

extension AllWordingPageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "allWordingCellId", for: indexPath) as? AllWordingCell else {
            return UITableViewCell()
        }
        // MARK: 테스트 1
        let url = URL(string: "https://firebasestorage.googleapis.com/v0/b/hongkimdaonproject.appspot.com/o/allWordPageTest.png?alt=media&token=5ee1f5df-b2a3-47d0-94ea-8bc1764ac91a")
        var image: UIImage?
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                image = UIImage(data: data!)
                cell.allImageView.image = image
                cell.contentMode = .scaleAspectFit
            }
        }
        // MARK: 테스트 2
        //        cell.allImageView.image = UIImage(named: "testPage")
        // MARK: 테스트 3
        //        cell.allImageView.image = cropToBounds(image: UIImage(named: "testPage")!, width: 1, height: 1)
        cell.directionalLayoutMargins = .zero
        cell.layoutMargins = .zero
        cell.contentView.directionalLayoutMargins = .zero
        cell.contentView.layoutMargins = .zero
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
