import Foundation
import AppKit

enum CatboxError: LocalizedError {
    case invalidImage
    case invalidResponse
    case uploadFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image format"
        case .invalidResponse:
            return "Invalid response from server"
        case .uploadFailed(let message):
            return "Upload failed: \(message)"
        }
    }
}

class CatboxService {
    private let uploadURL = "https://catbox.moe/user/api.php"

    func uploadImage(_ image: NSImage) async throws -> String {
        // Convert NSImage to PNG data
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let imageData = bitmap.representation(using: .png, properties: [:]) else {
            throw CatboxError.invalidImage
        }

        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()

        // Add reqtype parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"reqtype\"\r\n\r\n".data(using: .utf8)!)
        body.append("fileupload\r\n".data(using: .utf8)!)

        // Add fileToUpload parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        // Create request
        var request = URLRequest(url: URL(string: uploadURL)!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        // Perform upload
        let (data, response) = try await URLSession.shared.data(for: request)

        // Check response
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw CatboxError.invalidResponse
        }

        // Parse URL from response
        guard let urlString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !urlString.isEmpty else {
            throw CatboxError.invalidResponse
        }

        // Check for error responses
        if urlString.lowercased().contains("error") || urlString.lowercased().contains("fail") {
            throw CatboxError.uploadFailed(urlString)
        }

        return urlString
    }
}
