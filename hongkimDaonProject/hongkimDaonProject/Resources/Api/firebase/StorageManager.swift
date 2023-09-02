import Foundation
import UIKit
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    let storage: Storage
    private init() {
        self.storage = Storage.storage()
    }
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
            strongSelf.storage.reference().child("\(filePath)/\(fileName)").downloadURL { [weak self] url, error in
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
    public func deleteImage(fileName: String, filePath: String) async {
        do {
            try await storage.reference().child("\(filePath)/\(fileName)").delete()
        } catch {
            
        }
    }
    public func deleteImage(downloadURL: String) async {
        do {
            try await storage.reference(forURL: downloadURL).delete()
        } catch {
            
        }
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

    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.reference().child(path)
        reference.downloadURL { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        }
    }
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
}
