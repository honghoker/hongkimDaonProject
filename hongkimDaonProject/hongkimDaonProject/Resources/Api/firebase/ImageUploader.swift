//
//  ImageUploader.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/09.
//

/*
import FirebaseStorage
import Foundation
import UIKit

struct ImageUploader {
    //파베 스토리지에 업로드
    static func uploadImage(image: UIImage
//                            completion: @escaping(String) -> Void
    ) {
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let filename = NSUUID().uuidString
        let reference = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        reference.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("DEBUG: Failed to upload image \(error.localizedDescription)")
                return
            }
            reference.downloadURL { (downloadURL, error) in
                guard let imageUrl = downloadURL?.absoluteString else { return }
//                completion(imageUrl)
            }
        }
    }
}
*/
