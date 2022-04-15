import UIKit

class AllWordingPageViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let allWordingTableViewCellNib = UINib(nibName: String(describing: AllWordingCell.self), bundle: nil)
        self.tableView.register(allWordingTableViewCellNib, forCellReuseIdentifier: "allWordingCellId")
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
}

extension AllWordingPageViewController: UITableViewDelegate {
}

extension AllWordingPageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "allWordingCellId", for: indexPath) as? AllWordingCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
}
