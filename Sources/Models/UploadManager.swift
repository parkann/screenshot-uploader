import Foundation
import SwiftUI
import AppKit

@MainActor
class UploadManager: ObservableObject {
    @Published var uploadHistory: [Upload] = []
    @Published var isUploading = false
    @Published var lastUploadedURL: String?
    @Published var uploadError: String?

    private let storageService = StorageService()
    private let catboxService = CatboxService()

    init() {
        loadHistory()
    }

    func uploadImage(_ image: NSImage) {
        isUploading = true
        uploadError = nil

        Task {
            do {
                let url = try await catboxService.uploadImage(image)

                // Create thumbnail
                let thumbnail = createThumbnail(from: image)

                // Save to history
                let upload = Upload(url: url, thumbnail: thumbnail)
                uploadHistory.append(upload)
                storageService.saveHistory(uploadHistory)

                // Notify success
                lastUploadedURL = url
            } catch {
                uploadError = error.localizedDescription
            }

            isUploading = false
        }
    }

    func deleteUpload(_ upload: Upload) {
        uploadHistory.removeAll { $0.id == upload.id }
        storageService.saveHistory(uploadHistory)
    }

    func clearHistory() {
        uploadHistory.removeAll()
        storageService.saveHistory(uploadHistory)
    }

    private func loadHistory() {
        uploadHistory = storageService.loadHistory()
    }

    private func createThumbnail(from image: NSImage, maxSize: CGFloat = 120) -> NSImage {
        let size = image.size
        let ratio = min(maxSize / size.width, maxSize / size.height)
        let newSize = NSSize(width: size.width * ratio, height: size.height * ratio)

        let thumbnail = NSImage(size: newSize)
        thumbnail.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: newSize),
                   from: NSRect(origin: .zero, size: size),
                   operation: .copy,
                   fraction: 1.0)
        thumbnail.unlockFocus()

        return thumbnail
    }
}
