import Foundation

class StorageService {
    private let uploadsKey = "savedUploads"

    func saveUploads(_ uploads: [Upload]) {
        if let encoded = try? JSONEncoder().encode(uploads) {
            UserDefaults.standard.set(encoded, forKey: uploadsKey)
        }
    }

    func loadUploads() -> [Upload] {
        guard let data = UserDefaults.standard.data(forKey: uploadsKey),
              let uploads = try? JSONDecoder().decode([Upload].self, from: data) else {
            return []
        }
        return uploads
    }
}
