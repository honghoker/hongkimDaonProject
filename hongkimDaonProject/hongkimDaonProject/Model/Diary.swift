import Foundation
import FirebaseFirestore

struct Diary: Codable, Identifiable {
    var id: String? = UUID().uuidString
    let uid: String
    var imageUrl: String
    var content: String
    let writeTime: Int64
    var imageExist: Bool
    var imageWidth: CGFloat
    var imageHeight: CGFloat
    var imageUploadComplete: Bool
}
