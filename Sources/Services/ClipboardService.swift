import AppKit

class ClipboardService {
    static func getImageFromClipboard() -> NSImage? {
        let pasteboard = NSPasteboard.general

        // Try to get image directly
        if let image = NSImage(pasteboard: pasteboard) {
            return image
        }

        // Try to get image from file URL
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL],
           let url = urls.first,
           let image = NSImage(contentsOf: url) {
            return image
        }

        return nil
    }

    static func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    static func hasImageInClipboard() -> Bool {
        let pasteboard = NSPasteboard.general
        return pasteboard.canReadObject(forClasses: [NSImage.self], options: nil)
    }
}
