import Foundation

class StorageService {
    private let historyKey = "upload_history"
    private let defaults = UserDefaults.standard

    func saveHistory(_ history: [Upload]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(history) {
            defaults.set(encoded, forKey: historyKey)
        }
    }

    func loadHistory() -> [Upload] {
        guard let data = defaults.data(forKey: historyKey) else {
            return []
        }

        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode([Upload].self, from: data) {
            return decoded
        }

        return []
    }

    func clearHistory() {
        defaults.removeObject(forKey: historyKey)
    }
}
