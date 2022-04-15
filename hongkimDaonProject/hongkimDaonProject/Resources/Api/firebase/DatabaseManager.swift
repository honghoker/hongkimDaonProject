//
//  DatabaseManager.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/15.
//

import Foundation
import FirebaseFirestore

final class DatabaseManager {
    static let shared = DatabaseManager()
    private let db = Firestore.firestore()
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
    public func updateDiary(diary: Diary) {
        
    }
    public func updateImageUrl(docId: String, imageUrl: String, completion: @escaping DiaryCompletion) {
        db.collection("diary").document(docId).updateData(["imageUrl": imageUrl], completion: {error in
            guard error == nil else {
                completion(.failure(DiaryErros.failedToUpdateImageUrl))
                return
            }
            completion(.success(""))
        })
    }
    public func deleteDiray(diary: Diary) {
        
    }
    public enum DiaryErros: Error {
        case failedToWrite
        case failedToUpdate
        case failedToUpdateImageUrl
        case failedToDelete
    }
}
