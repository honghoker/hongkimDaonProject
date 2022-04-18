//
//  Daon.swift
//  hongkimDaonProject
//
//  Created by 홍은표 on 2022/04/19.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Daon: Codable, Identifiable {
    @DocumentID var id: String?
    let imageUrl: String
    let storageUser: [String: Int64]
    let uploadTime: Int64
}
