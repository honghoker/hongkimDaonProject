import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage()
    public typealias StorageCompletion = (Result<String, Error>) -> Void
    public func uploadImage(with data: Data, filePath: String, fileName: String, completion: @escaping StorageCompletion) {
        storage.reference().child("\(filePath)/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard let strongSelf = self else {
                return
            }
            guard error == nil else {
                // failed
                print("failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            strongSelf.storage.reference().child("\(filePath)/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            }
        })
    }
    public func downloadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        let reference = storage.reference(forURL: url.absoluteString)
        let megaByte = Int64(1 * 1024 * 1024)
        reference.getData(maxSize: megaByte) { data, error in
            guard let imageData = data else {
                completion(nil)
                return
            }
            completion(UIImage(data: imageData))
        }
    }
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
}
