import UIKit

class MyStorageViewController: UIViewController {

    @IBOutlet weak var storageTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let storageTableViewCellNib = UINib(nibName: String(describing: MyStorageCell.self), bundle: nil)
        self.storageTableView.register(storageTableViewCellNib, forCellReuseIdentifier: "myStorageCellId")
        self.storageTableView.rowHeight = UITableView.automaticDimension
        self.storageTableView.separatorStyle = .none
        self.storageTableView.delegate = self
        self.storageTableView.dataSource = self
    }
}

extension MyStorageViewController: UITableViewDelegate {
}

extension MyStorageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = storageTableView.dequeueReusableCell(withIdentifier: "myStorageCellId", for: indexPath) as! MyStorageCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
}
