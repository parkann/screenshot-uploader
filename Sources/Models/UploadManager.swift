import Foundation
import SwiftUI

@MainActor
@Observable
class UploadManager {
    var uploads: [Upload] = []
    var isUploading = false
    var currentProgress: Double = 0.0
    var toastMessage: String?
    var showToast = false

    private let catboxService = CatboxService()
    private let clipboardService = ClipboardService()
    private let storageService = StorageService()

    init() {
        loadHistory()
    }

    func uploadImage(_ image: NSImage, fileName: String) async {
        isUploading = true
        currentProgress = 0.0

        do {
            currentProgress = 0.3
            let url = try await catboxService.uploadImage(image)
            currentProgress = 0.7

            // Copy to clipboard
            clipboardService.copyToClipboard(url)

            // Create thumbnail
            let thumbnailData = createThumbnail(from: image)

            // Save to history
            let upload = Upload(url: url, fileName: fileName, thumbnailData: thumbnailData)
            uploads.insert(upload, at: 0)
            saveHistory()

            currentProgress = 1.0
            showToastMessage("Link Copied ✓")
        } catch let error as CatboxError {
            let message: String
            switch error {
            case .invalidImage:
                message = "Upload Failed: Invalid image format"
            case .uploadFailed(let reason):
                message = "Upload Failed: \(reason)"
            case .invalidResponse:
                message = "Upload Failed: Server returned invalid response"
            case .invalidURL:
                message = "Upload Failed: Invalid upload URL"
            }
            showToastMessage(message)
        } catch {
            showToastMessage("Upload Failed: \(error.localizedDescription)")
        }

        isUploading = false
    }

    func deleteUpload(_ upload: Upload) {
        uploads.removeAll { $0.id == upload.id }
        saveHistory()
    }

    func copyURL(_ url: String) {
        clipboardService.copyToClipboard(url)
        showToastMessage("Link Copied ✓")
    }

    private func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true

        Task {
            try? await Task.sleep(for: .seconds(2))
            showToast = false
        }
    }

    private func createThumbnail(from image: NSImage) -> Data? {
        let targetSize = CGSize(width: 100, height: 100)
        let thumbnail = NSImage(size: targetSize)

        thumbnail.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: targetSize),
                   from: NSRect(origin: .zero, size: image.size),
                   operation: .copy,
                   fraction: 1.0)
        thumbnail.unlockFocus()

        guard let tiffData = thumbnail.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            return nil
        }

        return bitmapImage.representation(using: .png, properties: [:])
    }

    private func loadHistory() {
        uploads = storageService.loadUploads()
    }

    private func saveHistory() {
        storageService.saveUploads(uploads)
    }
}
