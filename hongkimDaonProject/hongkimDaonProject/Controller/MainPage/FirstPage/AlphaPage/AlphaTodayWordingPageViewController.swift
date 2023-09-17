import UIKit
import SnapKit
import FirebaseAuth
import FirebaseStorage
import Kingfisher
import RealmSwift
//import Toast_Swift
import MobileCoreServices

class AlphaTodayWordingPageViewController: UIViewController {
	let downloadBtn = UIButton()
	let saveBtn = UIButton()
	let imageView = UIImageView()
	let stackView = UIStackView()
	let backgroundUIView = UIView()
	
	// 임시
	let url = "https://firebasestorage.googleapis.com/v0/b/hongkimdaonproject.appspot.com/o/today%2F2022%2F04%2F1651104000000.jpg?alt=media&token=53edc93b-8898-4501-80e1-84ef29610e97"
	
	var realm: Realm!
	override func viewDidLoad() {
		super.viewDidLoad()
		
		[imageView, stackView, backgroundUIView].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview($0)
		}
		
		[downloadBtn, saveBtn].forEach {
			stackView.addArrangedSubview($0)
		}
		
		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: self.view.topAnchor),
			imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
		])
		
		NSLayoutConstraint.activate([
			backgroundUIView.topAnchor.constraint(equalTo: self.view.topAnchor),
			backgroundUIView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			backgroundUIView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			backgroundUIView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
		])
		
		let configuration = UIImage.SymbolConfiguration(pointSize: 20)
		saveBtn.setImage(UIImage(systemName: "bag", withConfiguration: configuration), for: .normal)
		saveBtn.tintColor = DaonConstants.daonColor
		downloadBtn.setImage(UIImage(systemName: "square.and.arrow.down", withConfiguration: configuration), for: .normal)
		downloadBtn.tintColor = DaonConstants.daonColor
		
		stackView.alignment = .fill
		stackView.distribution = .fillEqually
		stackView.axis = .horizontal
		stackView.spacing = 20
		NSLayoutConstraint.activate([
			stackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16),
			stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16)
		])
		
		setUI()
	}
	// MARK: set UI
	func setUI() {
		let imageClick: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapImage(_:)))
		backgroundUIView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
		backgroundUIView.isUserInteractionEnabled = true
		backgroundUIView.addGestureRecognizer(imageClick)
		imageView.kf.indicatorType = .activity
		//        let url = URL(string: String(describing: mainImageUrl))
		//        imageView.kf.setImage(with: url, options: nil)
		imageView.kf.setImage(with: URL(string: url), options: nil)
		saveBtn.addTarget(self, action: #selector(daonStorageSave), for: .touchUpInside)
		downloadBtn.addTarget(self, action: #selector(imageDownload), for: .touchUpInside)
	}
}

// MARK: btns action
extension AlphaTodayWordingPageViewController {
	@objc
	func onTapImage(_ gesture: UITapGestureRecognizer) {
		let nextView = FirstMainPageContainerViewController()
		nextView.modalPresentationStyle = .fullScreen
		self.present(nextView, animated: false, completion: nil)
	}
	@objc
	func imageDownload() {
		LoadingIndicator.showLoading()
		let url = URL(string: String(describing: mainImageUrl))
		URLSession.shared.dataTask(with: url!) { [weak self] data, response, error in
			guard let data = data,
				  let response = response as? HTTPURLResponse,
				  error == nil
			else {
				print("network error:", error ?? "Unknown error")
				return
			}
			guard 200..<300 ~= response.statusCode else {
				print("invalid status code, expected 2xx, received", response.statusCode)
				return
			}
			guard let image = UIImage(data: data) else {
				print("Not valid image")
				return
			}
			UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
			DispatchQueue.main.async {
				LoadingIndicator.hideLoading()
				//                self?.backgroundUIView.makeToast("사진첩에 저장되었습니다", duration: 1.5, position: .center)
			}
		}.resume()
	}
	@objc
	func daonStorageSave() {
		DatabaseManager.shared.daonStorageSave(docId: "\(mainUploadTime)") { result in
			switch result {
			case .success(let success):
				print("\(success)")
			case .failure(let error):
				print("\(error)")
			}
		}
		realm = try? Realm()
		let list = realm.objects(MyStorage.self).filter("uploadTime == \(mainUploadTime)")
		if list.isEmpty == true {
			let myStorage = MyStorage()
			myStorage.uploadTime = mainUploadTime
			myStorage.imageUrl = mainImageUrl
			myStorage.storageTime = Int(Date().millisecondsSince1970)
			try? self.realm.write {
				self.realm.add(myStorage)
			}
			//            self.backgroundUIView.makeToast("보관함에 추가되었습니다", duration: 1.5, position: .center)
		} else {
			try? realm.write {
				realm.delete(list)
			}
			//            self.backgroundUIView.makeToast("보관함에서 삭제되었습니다", duration: 1.5, position: .center)
		}
	}
}
