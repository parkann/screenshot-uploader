import Foundation
import AppKit

struct Upload: Identifiable, Codable {
    let id: UUID
    let url: String
    let timestamp: Date
    var thumbnailData: Data?

    var thumbnail: NSImage? {
        guard let data = thumbnailData else { return nil }
        return NSImage(data: data)
    }

    init(id: UUID = UUID(), url: String, timestamp: Date = Date(), thumbnail: NSImage? = nil) {
        self.id = id
        self.url = url
        self.timestamp = timestamp

        // Store thumbnail as PNG data
        if let thumbnail = thumbnail,
           let tiffData = thumbnail.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData) {
            self.thumbnailData = bitmap.representation(using: .png, properties: [:])
        }
    }
}
