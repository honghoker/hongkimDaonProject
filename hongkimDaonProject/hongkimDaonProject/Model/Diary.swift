//
//  Diary.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/14.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Diary: Codable, Identifiable {
    @DocumentID var id: String?
    let uid: String
    var imageUrl: String
    let title: String
    let content: String
    let writeTime: Int
}
