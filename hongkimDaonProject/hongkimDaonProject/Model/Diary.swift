import Foundation
import FirebaseFirestoreSwift

struct Diary: Codable, Identifiable {
    @DocumentID var id: String?
    let uid: String
    var imageUrl: String
    var content: String
    let writeTime: Int64
    var imageExist: Bool
    var imageWidth: CGFloat
    var imageHeight: CGFloat
    var imageUploadComplete: Bool
}
