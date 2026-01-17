import Foundation
import AppKit

enum CatboxError: Error {
    case invalidImage
    case uploadFailed(String)
    case invalidResponse
    case invalidURL
}

class CatboxService {
    private let uploadURL = "https://catbox.moe/user/api.php"

    func uploadImage(_ image: NSImage) async throws -> String {
        guard let pngData = image.pngData else {
            throw CatboxError.invalidImage
        }

        guard let url = URL(string: uploadURL) else {
            throw CatboxError.invalidURL
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // reqtype parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"reqtype\"\r\n\r\n".data(using: .utf8)!)
        body.append("fileupload\r\n".data(using: .utf8)!)

        // fileToUpload parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"image.png\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(pngData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw CatboxError.uploadFailed("Server returned error")
        }

        guard let urlString = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
              urlString.starts(with: "https://") else {
            throw CatboxError.invalidResponse
        }

        return urlString
    }
}

extension NSImage {
    var pngData: Data? {
        guard let tiffData = tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        return bitmapImage.representation(using: .png, properties: [:])
    }
}
