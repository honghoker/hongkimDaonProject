//
//  DatabaseManager.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/15.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Accelerate

final class DatabaseManager {
    static let shared = DatabaseManager()
    private let db = Firestore.firestore()
    private var diaryDocumentListener: ListenerRegistration?
    public typealias DiaryCompletion = (Result<String, Error>) -> Void
    public func writeDiary(diary: Diary, completion: @escaping DiaryCompletion) {
        try? db.collection("diary").document(String(describing: diary.writeTime)).setData(from: diary, completion: { error in
            guard error == nil else {
                completion(.failure(DiaryErros.failedToWrite))
                return
            }
            completion(.success(""))
        })
    }
    public func updateDiary(diary: Diary, completion: @escaping DiaryCompletion) {
        db.collection("diary").document(String(diary.writeTime)).updateData(["imageExist": diary.imageExist, "imageWidth": diary.imageWidth, "imageHeight": diary.imageHeight, "imageUploadComplete": diary.imageUploadComplete, "content": diary.content], completion: {error in
            guard error == nil else {
                completion(.failure(DiaryErros.failedToUpdate))
                return
            }
            completion(.success(""))
        })
    }
    public func updateImageUrl(docId: String, imageUrl: String, completion: @escaping DiaryCompletion) {
        db.collection("diary").document(docId).updateData([
            "imageUploadComplete": true,
            "imageUrl": imageUrl], completion: {error in
            guard error == nil else {
                completion(.failure(DiaryErros.failedToUpdateImageUrl))
                return
            }
            completion(.success(""))
        })
    }
    public func deleteDiray(diary: Diary) {
    }
    public func daonStorageSave(docId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let user = Auth.auth().currentUser
        guard let uid = user?.uid else { return }
        let nowTime = Int64(Date().millisecondsSince1970)
        db.collection("daon").document(docId).updateData(["storageUser.\(uid)": nowTime ], completion: {error in
            guard error == nil else {
                completion(.failure(DaonErros.failedToSave))
                return
            }
            completion(.success(""))
        })
    }
    public enum DiaryErros: Error {
        case failedToGet
        case failedToDecoded
        case failedToWrite
        case failedToUpdate
        case failedToUpdateImageUrl
        case failedToDelete
    }
    public enum DaonErros: Error {
        case failedToSave
    }
    func removeListener() {
        diaryDocumentListener?.remove()
    }
}
