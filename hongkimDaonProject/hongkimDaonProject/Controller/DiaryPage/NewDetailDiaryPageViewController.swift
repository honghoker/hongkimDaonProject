//
//  NewDiaryPageViewController.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/28.
//

import Foundation
import UIKit
import SnapKit
import AuthenticationServices
import Kingfisher
import Toast_Swift

class NewDetailDiaryPageViewController: UIViewController {
    var docId: String?
    var diary: Diary?
    var delegate: DispatchDiary?
    var imageLoadComplete: Bool = false
    var scrolldirection: Bool = false
    let toolBar = UIToolbar()
    let scrollView = UIScrollView()
    let contentsView = UIView()
    lazy var backBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.tintColor = .systemGray
        return button
    }()
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    lazy var writeTimeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        label.textColor = .systemGray
        return label
    }()
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        label.textColor = .label
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(named: "bgColor")
        self.view.addSubview(self.backBtn)
        self.backBtn.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        self.backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.toolBar)
        self.toolBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        // MARK: toolBar 배경 transparent
        self.toolBar.setBackgroundImage(UIImage(),
                                        forToolbarPosition: UIBarPosition.any,
                                        barMetrics: UIBarMetrics.default)
        self.toolBar.setShadowImage(UIImage(),
                                    forToolbarPosition: UIBarPosition.any)
        self.toolBar.tintColor = .systemGray
        self.toolBar.clipsToBounds = true
        let toolbarEditItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(tabEditBtn))
        let toolbarRemoveItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(tabRemoveBtn))
        self.toolBar.setItems([.flexibleSpace(), toolbarEditItem, toolbarRemoveItem], animated: true)
        self.scrollView.snp.makeConstraints {
            $0.top.equalTo(self.backBtn.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        self.scrollView.addSubview(contentsView)
        self.scrollView.delegate = self
        self.contentsView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
            $0.width.equalToSuperview()
        }
        self.contentsView.addSubview(self.writeTimeLabel)
        self.contentsView.addSubview(self.imageView)
        self.contentsView.addSubview(self.contentLabel)
        // MARK: Firestore diary data 가져오기
        getDiary()
    }
    func getDiary() {
        // MARK: Loading 시작
        DatabaseManager.shared.fireStore.collection("diary").document(docId!).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard document.data() != nil else {
                print("Document data was empty.")
                return
            }
            guard let diary: Diary = try? document.data(as: Diary.self) else { return }
            self.diary = diary
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateFormat = "# yyyy.MM.dd"
            myDateFormatter.locale = Locale(identifier: "ko_KR")
            let convertNowStr = myDateFormatter.string(from: Date(milliseconds: diary.writeTime))
            self.writeTimeLabel.text = convertNowStr
            self.writeTimeLabel.snp.makeConstraints {
                $0.top.equalTo(self.scrollView.snp.top).offset(16)
                $0.leading.equalToSuperview().offset(16)
            }
            // label 행간 조절
            self.contentLabel.numberOfLines = 0
            let attrString = NSMutableAttributedString(string: diary.content)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 10
            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
            self.contentLabel.attributedText = attrString
            if diary.imageExist == false {
                self.contentLabel.snp.remakeConstraints {
                    $0.top.equalTo(self.writeTimeLabel.snp.bottom).offset(32)
                    $0.leading.equalToSuperview().offset(16)
                    $0.trailing.equalToSuperview().offset(-16)
                    $0.bottom.equalToSuperview()
                }
                self.imageLoadComplete = true
            } else {
                let ratio = diary.imageHeight / diary.imageWidth
                let height = self.view.frame.width * ratio
                self.imageView.snp.remakeConstraints {
                    $0.top.equalTo(self.writeTimeLabel.snp.bottom).offset(32)
                    $0.left.right.equalToSuperview()
                    $0.height.equalTo(height)
                }
                self.contentLabel.snp.remakeConstraints {
                    $0.top.equalTo(self.imageView.snp.bottom).offset(32)
                    $0.leading.equalToSuperview().offset(16)
                    $0.trailing.equalToSuperview().offset(-16)
                    $0.bottom.equalToSuperview()
                }
                // MARK: 이미지 리사이징
                let processor = ResizingImageProcessor(referenceSize: CGSize(width: self.view.frame.width, height: height))
                if diary.imageUploadComplete == true {
                    let url = URL(string: diary.imageUrl)
                    self.imageView.kf.indicatorType = .activity
                    self.imageView.kf.setImage(with: url, options: [.processor(processor)])
                    self.imageLoadComplete = true
                } else {
                    // MARK: 이미지 업로드 중
                    DispatchQueue.global().async { [weak self] in
                        DispatchQueue.main.async {
                            self?.imageView.contentMode = .center
                            self?.imageView.image = UIImage(named: "ImageUploading")
                        }
                    }
                }
            }
        }
    }
}

extension NewDetailDiaryPageViewController {
    @objc
    func back() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @objc
    func tabEditBtn(_ sender: Any) {
        if let diary = self.diary {
            // MARK: 이미지 저장이 아직 덜 된거 처리
            if diary.imageUploadComplete == false {
                print("@@@@@@@@@ 이미지 저장 기다리라는 토스트")
            } else {
                // MARK: 이미지 불러오기가 아직 덜 된거 처리
                if self.imageLoadComplete == false {
                    print("@@@@@@@@ 이미지 로딩 기다리라는 토스트")
                } else {
                    let storyboard: UIStoryboard = UIStoryboard(name: "EditDiaryPageView", bundle: nil)
                    guard let editDiaryPageVC = storyboard.instantiateViewController(withIdentifier: "EditDiaryPageViewController") as? EditDiaryPageViewController else { return }
                    editDiaryPageVC.delegate = self
                    editDiaryPageVC.diary = diary
                    editDiaryPageVC.image = self.imageView.image
                    editDiaryPageVC.modalTransitionStyle = .crossDissolve
                    editDiaryPageVC.modalPresentationStyle = .fullScreen
                    self.present(editDiaryPageVC, animated: true, completion: nil)
                }
            }
        }
    }
    @objc
    func tabRemoveBtn(_ sender: Any) {
        let alert = UIAlertController(title: "일기를 삭제하시겠습니까?",
                                      message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "취소", style: UIAlertAction.Style.default, handler: { _ in
        }))
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: { _ in
            DatabaseManager.shared.fireStore.collection("diary").document(self.docId!).delete { result in
                guard result == nil else {
                    self.view.makeToast("일기 삭제에 실패했습니다.", duration: 1.5, position: .bottom)
                    return
                }
                self.delegate?.delete(self, Delete: self.docId)
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension NewDetailDiaryPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if translation.y > 0 {
            if self.scrolldirection == true {
                DispatchQueue.main.async {
                    UIView.transition(with: self.toolBar, duration: 0.6,
                                      options: .transitionCrossDissolve,
                                      animations: {
                        self.toolBar.isHidden = false
                    })
                }
                self.scrolldirection = false
            }
        } else {
            if self.scrolldirection == false {
                self.toolBar.isHidden = true
                self.scrolldirection = true
            }
        }
    }
}

extension NewDetailDiaryPageViewController: DispatchDiary {
    func update(_ vc: UIViewController, Input value: Diary?) {
        if let diary = value {
            self.delegate?.update(self, Input: diary)
        }
    }
    func delete(_ vc: UIViewController, Delete id: String?) {}
    func dispatch(_ vc: UIViewController, Input value: Diary?) {}
}

extension NewDetailDiaryPageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isEqual(navigationController?.interactivePopGestureRecognizer) {
            navigationController?.popViewController(animated: true)
        }
        return false
    }
}
