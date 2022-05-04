//
//  NewDiaryPageViewController.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/28.
//

import Foundation
import UIKit
import FirebaseFirestore
import SnapKit
import AuthenticationServices

class NewDetailDiaryPageViewController: UIViewController {
    var docId: String?
    var diary: Diary?
    var delegate: DispatchDiary?
    var imageLoadComplete: Bool = false
    var scrolldirection: Bool = false
    @IBOutlet weak var toolBar: UIToolbar!
    let scrollView = UIScrollView()
    let contentsView = UIView()
    let backBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    let writeTimeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        label.textColor = .gray
        return label
    }()
    let contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "JejuMyeongjoOTF", size: 14)
        label.textColor = .black
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.backBtn)
        self.backBtn.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.top.equalToSuperview().offset(64)
            $0.leading.equalToSuperview().offset(16)
        }
        self.backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints {
            $0.top.equalTo(self.backBtn.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        //        self.scrollView.contentInsetAdjustmentBehavior = .never
        self.scrollView.addSubview(contentsView)
        self.scrollView.delegate = self
        self.contentsView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        self.contentsView.addSubview(self.contentLabel)
        self.contentsView.addSubview(self.writeTimeLabel)
        self.contentsView.addSubview(self.imageView)
        self.writeTimeLabel.snp.makeConstraints {
            $0.top.equalTo(self.scrollView.snp.top).offset(32)
            $0.leading.equalToSuperview().offset(16)
        }
        Firestore.firestore().collection("diary").document(docId!).addSnapshotListener { documentSnapshot, error in
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
            self.contentLabel.text = diary.content
            let myDateFormatter = DateFormatter()
            myDateFormatter.dateFormat = "yyyy년 MM월 dd일 a h:mm" // 2020.08.13 오후 04시 30분
            myDateFormatter.locale = Locale(identifier: "ko_KR") // PM, AM을 언어에 맞게 setting (ex: PM -> 오후)
            let convertNowStr = myDateFormatter.string(from: Date(milliseconds: diary.writeTime)) // 현재 시간의 Date를 format에 맞춰 string으로 반환
            self.writeTimeLabel.text = convertNowStr
            if diary.imageUrl == "" {
                // MARK: 이미지 뷰 크기 0으로 조절
                print("@@@@@@@ image not exist")
                self.imageLoadComplete = true
                self.contentLabel.snp.makeConstraints {
                    $0.top.equalTo(self.writeTimeLabel.snp.bottom).offset(32)
                    $0.leading.equalToSuperview().offset(16)
                    $0.bottom.equalToSuperview()
                }
            } else {
                let url = URL(string: diary.imageUrl)
                var image: UIImage?
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!)
                    DispatchQueue.main.async {
                        image = UIImage(data: data!)
                        if let image = image {
                            self.imageView.image = image
                            let ratio = image.size.height / image.size.width
                            let height = self.view.frame.width * ratio
                            self.imageView.snp.makeConstraints {
                                $0.top.equalTo(self.writeTimeLabel.snp.bottom).offset(32)
                                $0.left.right.equalToSuperview()
                                $0.height.equalTo(height)
                            }
                            self.contentLabel.snp.makeConstraints {
                                $0.top.equalTo(self.imageView.snp.bottom).offset(32)
                                $0.leading.equalToSuperview().offset(16)
                                $0.bottom.equalToSuperview()
                            }
                            self.imageLoadComplete = true
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

extension NewDetailDiaryPageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isEqual(navigationController?.interactivePopGestureRecognizer) {
            navigationController?.popViewController(animated: true)
        }
        return false
    }
}
