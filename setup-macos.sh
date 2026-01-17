#!/bin/bash

# Quick Snip Uploader - macOS Setup Script
# This script creates the entire project structure on your Mac

set -e

echo "🚀 Quick Snip Uploader - Setup Script"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: This script must be run on macOS"
    exit 1
fi

# Create project directory
PROJECT_NAME="QuickSnipUploader"
echo -e "${BLUE}📁 Creating project directory: $PROJECT_NAME${NC}"
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create directory structure
echo -e "${BLUE}📂 Creating directory structure...${NC}"
mkdir -p Sources/{Views,Models,Services,Utils}

# Create Package.swift
echo -e "${BLUE}📝 Creating Package.swift...${NC}"
cat > Package.swift << 'PACKAGE_EOF'
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "QuickSnipUploader",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "QuickSnipUploader",
            dependencies: [],
            path: "Sources"
        )
    ]
)
PACKAGE_EOF

# Create main app file
echo -e "${BLUE}📝 Creating QuickSnipUploaderApp.swift...${NC}"
cat > Sources/QuickSnipUploaderApp.swift << 'APP_EOF'
import SwiftUI
import AppKit
import UserNotifications

@main
struct QuickSnipUploaderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var uploadManager = UploadManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(uploadManager)
                .frame(minWidth: 600, minHeight: 500)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }

        Settings {
            SettingsView()
                .environmentObject(uploadManager)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var shortcutMonitor: GlobalShortcutMonitor?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set up global keyboard shortcut
        shortcutMonitor = GlobalShortcutMonitor()
        shortcutMonitor?.setupDefaultShortcut()

        // Request notification permissions
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Keep app running in menu bar
    }
}
APP_EOF

echo -e "${BLUE}📝 Creating model files...${NC}"

# Upload.swift
cat > Sources/Models/Upload.swift << 'UPLOAD_EOF'
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
UPLOAD_EOF

# UploadManager.swift
cat > Sources/Models/UploadManager.swift << 'UPLOADMGR_EOF'
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
UPLOADMGR_EOF

echo -e "${BLUE}📝 Creating service files...${NC}"

# CatboxService.swift
cat > Sources/Services/CatboxService.swift << 'CATBOX_EOF'
import Foundation
import AppKit

enum CatboxError: Error {
    case invalidImage
    case uploadFailed(String)
    case invalidResponse
}

class CatboxService {
    private let uploadURL = "https://catbox.moe/user/api.php"

    func uploadImage(_ image: NSImage) async throws -> String {
        guard let pngData = image.pngData() else {
            throw CatboxError.invalidImage
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: uploadURL)!)
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
CATBOX_EOF

# ClipboardService.swift
cat > Sources/Services/ClipboardService.swift << 'CLIPBOARD_EOF'
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
CLIPBOARD_EOF

# StorageService.swift
cat > Sources/Services/StorageService.swift << 'STORAGE_EOF'
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
STORAGE_EOF

echo -e "${BLUE}📝 Creating utility files...${NC}"

# GlobalShortcutMonitor.swift
cat > Sources/Utils/GlobalShortcutMonitor.swift << 'SHORTCUT_EOF'
import Cocoa
import Carbon

class GlobalShortcutMonitor {
    private var eventHotKey: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?

    func setupDefaultShortcut() {
        // Register Cmd+Shift+U as the default shortcut
        registerShortcut(keyCode: UInt32(kVK_ANSI_U), modifiers: UInt32(cmdKey | shiftKey))
    }

    private func registerShortcut(keyCode: UInt32, modifiers: UInt32) {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        // Install event handler
        InstallEventHandler(GetApplicationEventTarget(), { (_, event, userData) -> OSStatus in
            GlobalShortcutMonitor.handleHotKeyEvent()
            return noErr
        }, 1, &eventType, nil, &eventHandler)

        // Register hot key
        var hotKeyID = EventHotKeyID(signature: OSType(0x4B455921), id: 1) // 'KEY!'
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &eventHotKey)
    }

    private static func handleHotKeyEvent() {
        DispatchQueue.main.async {
            // Activate the app and bring window to front
            NSApp.activate(ignoringOtherApps: true)

            // If there's a main window, bring it forward
            if let window = NSApp.windows.first(where: { $0.isVisible }) {
                window.makeKeyAndOrderFront(nil)
            }
        }
    }

    deinit {
        if let eventHotKey = eventHotKey {
            UnregisterEventHotKey(eventHotKey)
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }
}
SHORTCUT_EOF

echo -e "${BLUE}📝 Creating view files...${NC}"

# I'll continue with the views in the next part...
# ContentView.swift - part 1
cat > Sources/Views/ContentView.swift << 'CONTENTVIEW_EOF'
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var uploadManager: UploadManager

    var body: some View {
        ZStack {
            TabView {
                DropZoneView()
                    .tabItem {
                        Label("Upload", systemImage: "arrow.up.circle.fill")
                    }

                HistoryView()
                    .tabItem {
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }
            }
            .frame(minWidth: 600, minHeight: 500)

            if uploadManager.showToast, let message = uploadManager.toastMessage {
                ToastView(message: message)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(100)
            }
        }
    }
}
CONTENTVIEW_EOF

# DropZoneView.swift
cat > Sources/Views/DropZoneView.swift << 'DROPZONE_EOF'
import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
    @EnvironmentObject var uploadManager: UploadManager
    @State private var isDragging = false
    @State private var showFilePicker = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // App Icon/Logo
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)
                .symbolEffect(.bounce, value: isDragging)

            Text("Quick Snip Uploader")
                .font(.largeTitle)
                .fontWeight(.bold)

            if uploadManager.isUploading {
                VStack(spacing: 12) {
                    ProgressView(value: uploadManager.currentProgress)
                        .progressViewStyle(.linear)
                        .frame(width: 300)

                    Text("Uploading...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(spacing: 16) {
                    Text("Drag & Drop an image here")
                        .font(.title3)
                        .foregroundColor(.primary)

                    Text("or")
                        .foregroundColor(.secondary)

                    HStack(spacing: 16) {
                        Button {
                            pasteFromClipboard()
                        } label: {
                            Label("Paste (⌘V)", systemImage: "doc.on.clipboard")
                        }
                        .keyboardShortcut("v", modifiers: .command)

                        Button {
                            showFilePicker = true
                        } label: {
                            Label("Browse Files", systemImage: "folder")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            Spacer()

            // Drop zone hint
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                .foregroundColor(isDragging ? .blue : .gray.opacity(0.3))
                .frame(height: 200)
                .overlay {
                    VStack {
                        Image(systemName: isDragging ? "arrow.down.circle.fill" : "photo.on.rectangle")
                            .font(.system(size: 48))
                            .foregroundColor(isDragging ? .blue : .gray)

                        Text(isDragging ? "Drop to upload" : "Drop images here")
                            .foregroundColor(isDragging ? .blue : .gray)
                    }
                }
                .padding(.horizontal, 40)
                .onDrop(of: [.fileURL, .image], isTargeted: $isDragging) { providers in
                    handleDrop(providers: providers)
                    return true
                }

            Spacer()
        }
        .padding()
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                loadImage(from: url)
            }
        }
    }

    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                    if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                        loadImage(from: url)
                    }
                }
            } else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { item, error in
                    if let data = item as? Data, let image = NSImage(data: data) {
                        uploadImage(image, fileName: "dropped-image.png")
                    }
                }
            }
        }
    }

    private func pasteFromClipboard() {
        let clipboardService = ClipboardService()
        if let image = clipboardService.getImageFromClipboard() {
            uploadImage(image, fileName: "pasted-image.png")
        }
    }

    private func loadImage(from url: URL) {
        if let image = NSImage(contentsOf: url) {
            uploadImage(image, fileName: url.lastPathComponent)
        }
    }

    private func uploadImage(_ image: NSImage, fileName: String) {
        Task {
            await uploadManager.uploadImage(image, fileName: fileName)
        }
    }
}
DROPZONE_EOF

# HistoryView.swift
cat > Sources/Views/HistoryView.swift << 'HISTORY_EOF'
import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var uploadManager: UploadManager

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Upload History")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Text("\(uploadManager.uploads.count) uploads")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            .padding()

            Divider()

            if uploadManager.uploads.isEmpty {
                VStack(spacing: 16) {
                    Spacer()

                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 64))
                        .foregroundColor(.gray)

                    Text("No uploads yet")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    Text("Your upload history will appear here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()
                }
            } else {
                List {
                    ForEach(uploadManager.uploads) { upload in
                        HistoryRow(upload: upload)
                            .contextMenu {
                                Button("Copy URL") {
                                    uploadManager.copyURL(upload.url)
                                }

                                Button("Open in Browser") {
                                    if let url = URL(string: upload.url) {
                                        NSWorkspace.shared.open(url)
                                    }
                                }

                                Divider()

                                Button("Delete", role: .destructive) {
                                    uploadManager.deleteUpload(upload)
                                }
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

struct HistoryRow: View {
    let upload: Upload
    @EnvironmentObject var uploadManager: UploadManager

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let thumbnailData = upload.thumbnailData,
               let nsImage = NSImage(data: thumbnailData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(upload.fileName)
                    .font(.headline)
                    .lineLimit(1)

                Text(upload.url)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .lineLimit(1)

                Text(upload.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Actions
            HStack(spacing: 8) {
                Button {
                    uploadManager.copyURL(upload.url)
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.plain)
                .help("Copy URL")

                Button {
                    if let url = URL(string: upload.url) {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Image(systemName: "safari")
                }
                .buttonStyle(.plain)
                .help("Open in Browser")

                Button {
                    uploadManager.deleteUpload(upload)
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
                .foregroundColor(.red)
                .help("Delete")
            }
        }
        .padding(.vertical, 8)
    }
}
HISTORY_EOF

# ToastView.swift
cat > Sources/Views/ToastView.swift << 'TOAST_EOF'
import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)

                Text(message)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            .padding(.top, 20)

            Spacer()
        }
        .animation(.spring(), value: message)
    }
}
TOAST_EOF

# SettingsView.swift
cat > Sources/Views/SettingsView.swift << 'SETTINGS_EOF'
import SwiftUI

struct SettingsView: View {
    @AppStorage("globalShortcutEnabled") private var shortcutEnabled = true
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("showInMenuBar") private var showInMenuBar = true

    var body: some View {
        TabView {
            GeneralSettingsView(
                shortcutEnabled: $shortcutEnabled,
                launchAtLogin: $launchAtLogin,
                showInMenuBar: $showInMenuBar
            )
            .tabItem {
                Label("General", systemImage: "gear")
            }

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 450, height: 300)
    }
}

struct GeneralSettingsView: View {
    @Binding var shortcutEnabled: Bool
    @Binding var launchAtLogin: Bool
    @Binding var showInMenuBar: Bool

    var body: some View {
        Form {
            Section {
                Toggle("Enable global keyboard shortcut (⌘⇧U)", isOn: $shortcutEnabled)
                    .help("Quickly open Quick Snip Uploader from anywhere")

                Toggle("Launch at login", isOn: $launchAtLogin)
                    .help("Automatically start Quick Snip Uploader when you log in")

                Toggle("Show in menu bar", isOn: $showInMenuBar)
                    .help("Display Quick Snip Uploader icon in the menu bar")
            } header: {
                Text("Preferences")
            }

            Section {
                HStack {
                    Text("Upload service:")
                    Spacer()
                    Text("Catbox.moe")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Anonymous uploads:")
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            } header: {
                Text("Upload Settings")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.blue.gradient)

            Text("Quick Snip Uploader")
                .font(.title)
                .fontWeight(.bold)

            Text("Version 1.0.0")
                .foregroundColor(.secondary)

            Text("Lightning-fast image hosting for macOS")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Divider()
                .frame(width: 200)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "externaldrive.fill.badge.checkmark")
                    Text("Free anonymous uploads")
                }
                HStack {
                    Image(systemName: "bolt.fill")
                    Text("Instant clipboard integration")
                }
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Upload history tracking")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
SETTINGS_EOF

# Create Info.plist
echo -e "${BLUE}📝 Creating Info.plist...${NC}"
cat > Info.plist << 'PLIST_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Quick Snip Uploader</string>
    <key>CFBundleDisplayName</key>
    <string>Quick Snip Uploader</string>
    <key>CFBundleIdentifier</key>
    <string>com.quicksnip.uploader</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>CFBundleExecutable</key>
    <string>QuickSnipUploader</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
PLIST_EOF

# Create .gitignore
echo -e "${BLUE}📝 Creating .gitignore...${NC}"
cat > .gitignore << 'GITIGNORE_EOF'
.DS_Store
.build/
*.xcodeproj
*.xcworkspace
xcuserdata/
DerivedData/
.swiftpm/
GITIGNORE_EOF

# Create README
echo -e "${BLUE}📝 Creating README.md...${NC}"
cat > README.md << 'README_EOF'
# Quick Snip Uploader

Lightning-fast macOS app for instantly uploading screenshots and images to Catbox.moe.

## Features

- **Drag & Drop** images onto the app window
- **Paste** from clipboard with ⌘V
- **Browse** and select files
- **Auto-copy** uploaded URLs to clipboard
- **Upload History** with thumbnails
- **Global Shortcut** ⌘⇧U to open from anywhere
- **Toast Notifications** for feedback
- **Native macOS** design with dark mode

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0+ (for building)

## Installation

### Build from Source

1. Open in Xcode:
   ```bash
   open Package.swift
   ```

2. Build and run (⌘R)

### Command Line Build

```bash
swift build -c release
swift run
```

## Usage

1. Launch the app or press ⌘⇧U
2. Drop an image, paste with ⌘V, or browse
3. URL is auto-copied to clipboard
4. Paste anywhere!

## Architecture

- **Language**: Swift 5.9+
- **UI**: SwiftUI
- **Platform**: macOS 13+
- **Upload Service**: Catbox.moe

## License

MIT License
README_EOF

echo ""
echo -e "${GREEN}✅ Project setup complete!${NC}"
echo ""
echo -e "${BLUE}📦 Next steps:${NC}"
echo "  1. cd $PROJECT_NAME"
echo "  2. open Package.swift    # Opens in Xcode"
echo "  3. Press ⌘R to build and run"
echo ""
echo -e "${GREEN}🚀 Your Quick Snip Uploader is ready!${NC}"
