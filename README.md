# Quick Snip Uploader

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2013+-blue.svg" alt="Platform: macOS 13+">
  <img src="https://img.shields.io/badge/swift-5.9+-orange.svg" alt="Swift 5.9+">
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License: MIT">
</p>

A lightning-fast, native macOS app for instantly uploading screenshots and images to [Catbox.moe](https://catbox.moe). Built to replace paid tools like Shottr's cloud feature with a free, open-source alternative.

## Features

### Phase 1 (Current) - Standalone macOS App

- **Instant Upload**: Drag & drop or paste images for immediate upload
- **Multiple Input Methods**:
  - Drag & Drop files onto the app window
  - Paste from clipboard with `⌘V`
  - Browse and select files
- **Auto-Copy URL**: Uploaded URLs are automatically copied to your clipboard
- **Toast Notifications**: Visual feedback for successful uploads and errors
- **Upload History**: View and manage all your uploaded images with thumbnails
- **Global Keyboard Shortcut**: Quick access with `⌘⇧U` from anywhere
- **Native macOS Design**: Beautiful SwiftUI interface that feels right at home
- **Anonymous Uploads**: No account required, uploads to Catbox.moe

### Planned Features

**Phase 2 - Raycast Integration**
- Raycast command for uploading without opening the app
- Quick paste and upload workflow

**Phase 3 - MacBook Notch Integration**
- Utilize the MacBook notch for quick upload actions
- Innovative UI/UX leveraging the notch area

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later (for building from source)
- Swift 5.9 or later

## Installation

### Building from Source

1. **Clone the repository**:
   ```bash
   git clone https://github.com/parkann/screenshot-uploader.git
   cd screenshot-uploader
   ```

2. **Open in Xcode**:
   ```bash
   open Package.swift
   ```

   Xcode will automatically open and resolve Swift Package Manager dependencies.

3. **Build and Run**:
   - In Xcode, select the scheme: `QuickSnipUploader`
   - Press `⌘R` to build and run
   - Or build from terminal: `swift build`

4. **Create macOS App Bundle** (Optional):
   - In Xcode: Product → Archive
   - Export as macOS app
   - Move to `/Applications` folder

### Alternative: Command Line Build

```bash
# Build release version
swift build -c release

# Run directly
swift run
```

## Usage

### Quick Start

1. **Launch the app**: Open Quick Snip Uploader from Applications or use the global shortcut `⌘⇧U`

2. **Upload an image** using any of these methods:
   - **Drag & Drop**: Drag an image file onto the app window
   - **Paste**: Copy an image to clipboard and press `⌘V` in the app
   - **Browse**: Click "Browse Files" to select an image

3. **Get your link**: The URL is automatically copied to your clipboard. Paste it anywhere!

4. **View history**: Switch to the "History" tab to see all your uploads with thumbnails

### Global Keyboard Shortcut

- **Default shortcut**: `⌘⇧U` (Command + Shift + U)
- Brings the app to front from anywhere
- Configure in Settings (macOS Preferences)

### Settings

Access settings from the menu bar: `Quick Snip Uploader → Settings` or press `⌘,`

- Toggle global keyboard shortcut
- Configure launch at login
- Manage menu bar icon
- View app information

## Architecture

### Project Structure

```
QuickSnipUploader/
├── Sources/
│   ├── QuickSnipUploaderApp.swift    # Main app entry point
│   ├── Views/
│   │   ├── ContentView.swift         # Main view with tabs
│   │   ├── DropZoneView.swift        # Drag & drop zone
│   │   ├── HistoryView.swift         # Upload history list
│   │   ├── ToastView.swift           # Toast notifications
│   │   └── SettingsView.swift        # App settings
│   ├── Models/
│   │   ├── Upload.swift              # Upload data model
│   │   └── UploadManager.swift       # Upload state management
│   ├── Services/
│   │   ├── CatboxService.swift       # Catbox.moe API client
│   │   ├── ClipboardService.swift    # Clipboard operations
│   │   └── StorageService.swift      # Local data persistence
│   └── Utils/
│       └── GlobalShortcutMonitor.swift # Keyboard shortcut handling
├── Info.plist                         # App configuration
├── Package.swift                      # Swift Package Manager manifest
└── README.md                          # This file
```

### Technology Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Platform**: macOS 13+ (Ventura)
- **Dependency Management**: Swift Package Manager
- **Upload Service**: Catbox.moe API
- **Storage**: UserDefaults (for history)

### Key Components

#### CatboxService
Handles image upload to Catbox.moe using multipart/form-data POST requests. Converts NSImage to PNG format and uploads anonymously.

#### ClipboardService
Manages clipboard operations for both reading images and writing URLs. Supports multiple image formats and file URLs.

#### UploadManager
Central state manager using SwiftUI's `@Observable` pattern. Coordinates uploads, manages history, and handles errors.

#### GlobalShortcutMonitor
Registers system-wide keyboard shortcuts using Carbon API for `⌘⇧U` hotkey support.

## Catbox.moe API

This app uses [Catbox.moe](https://catbox.moe/)'s free file hosting API. Features include:

- Anonymous uploads (no account required)
- Permanent file hosting
- No bandwidth limits
- Direct image links
- Fast CDN delivery

**API Endpoint**: `https://catbox.moe/user/api.php`

## Development

### Running in Development

```bash
# Run with Swift Package Manager
swift run

# Or open in Xcode
open Package.swift
```

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftUI best practices
- Maintain clear separation of concerns (Views, Models, Services)
- Add comments for complex logic

### Testing

```bash
# Run tests (when test suite is added)
swift test
```

## Troubleshooting

### App doesn't launch
- Ensure you're running macOS 13+ (Ventura or later)
- Check Console.app for crash logs
- Try rebuilding: `swift build -c release`

### Global shortcut not working
- Grant Accessibility permissions: System Settings → Privacy & Security → Accessibility
- Enable Quick Snip Uploader

### Upload fails
- Check internet connection
- Verify image format is supported (PNG, JPEG, GIF, BMP, TIFF, WebP)
- Try a smaller image file
- Check Catbox.moe status

### Clipboard paste not working
- Ensure you have an image in clipboard
- Try copying the image again
- Check if another app is blocking clipboard access

## Roadmap

- [x] **Phase 1**: Standalone macOS app with drag & drop, paste, and history
  - [x] SwiftUI interface
  - [x] Catbox.moe integration
  - [x] Clipboard support
  - [x] Upload history
  - [x] Global keyboard shortcut
  - [x] Toast notifications
- [ ] **Phase 2**: Raycast integration
  - [ ] Raycast extension
  - [ ] Background upload without opening app
  - [ ] Quick commands
- [ ] **Phase 3**: MacBook Notch integration
  - [ ] Notch-aware UI
  - [ ] Quick actions from notch area
  - [ ] Minimal interface mode

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Catbox.moe](https://catbox.moe/) for providing free image hosting
- Inspired by [Shottr](https://shottr.cc/) and similar screenshot tools
- Built with [SwiftUI](https://developer.apple.com/xcode/swiftui/)

## Support

If you encounter any issues or have questions:

1. Check the [Troubleshooting](#troubleshooting) section
2. Search existing [GitHub Issues](https://github.com/parkann/screenshot-uploader/issues)
3. Open a new issue with detailed information

## Author

Built with ❤️ for the macOS community

---

**Note**: This is an unofficial third-party client. It is not affiliated with or endorsed by Catbox.moe.
