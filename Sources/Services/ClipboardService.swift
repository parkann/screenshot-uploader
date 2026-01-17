import AppKit

class ClipboardService {
    func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    func getImageFromClipboard() -> NSImage? {
        let pasteboard = NSPasteboard.general

        // Try to get image directly
        if let image = NSImage(pasteboard: pasteboard) {
            return image
        }

        // Try to get file URL
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL],
           let url = urls.first,
           let image = NSImage(contentsOf: url) {
            return image
        }

        return nil
    }
}
