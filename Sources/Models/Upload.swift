import Foundation

struct Upload: Identifiable, Codable {
    let id: UUID
    let url: String
    let fileName: String
    let timestamp: Date
    let thumbnailData: Data?

    init(id: UUID = UUID(), url: String, fileName: String, timestamp: Date = Date(), thumbnailData: Data? = nil) {
        self.id = id
        self.url = url
        self.fileName = fileName
        self.timestamp = timestamp
        self.thumbnailData = thumbnailData
    }
}
