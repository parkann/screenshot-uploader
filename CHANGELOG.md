# Changelog

All notable changes to Quick Snip Uploader will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Raycast extension integration
- Background upload service
- MacBook notch integration
- Menu bar mode
- Custom upload destinations

## [1.0.0] - 2026-01-17

### Added - Phase 1 Complete ✨

#### Core Features
- **Drag & Drop Support**: Drop image files directly onto the app window for instant upload
- **Clipboard Integration**: Paste images with `⌘V` for quick uploads
- **File Browser**: Browse and select images from your file system
- **Multiple Image Formats**: Support for PNG, JPEG, GIF, BMP, TIFF, and WebP

#### Upload Functionality
- **Catbox.moe Integration**: Anonymous, free image uploads to Catbox.moe
- **Auto-Copy URL**: Uploaded URLs automatically copied to clipboard
- **Upload Progress**: Visual feedback during upload process
- **Error Handling**: Clear error messages for failed uploads

#### User Interface
- **Native SwiftUI Design**: Beautiful, modern macOS interface
- **Dark Mode Support**: Automatic dark/light mode adaptation
- **Toast Notifications**: Non-intrusive success/error notifications
- **Two-Tab Layout**:
  - Upload tab with drag & drop zone
  - History tab with upload records

#### Upload History
- **Persistent Storage**: Upload history saved across app sessions
- **Thumbnail Previews**: Visual thumbnails for uploaded images
- **History Management**:
  - Copy URL to clipboard
  - Open in browser
  - Delete individual entries
- **Timestamp Tracking**: View when each image was uploaded

#### Global Features
- **Keyboard Shortcut**: `⌘⇧U` to open app from anywhere
- **Settings Panel**: Configure app preferences
  - Toggle global keyboard shortcut
  - Launch at login option
  - Menu bar icon settings
- **About Section**: App information and version details

#### Technical Implementation
- **Swift 5.9+**: Modern Swift language features
- **SwiftUI Framework**: Declarative UI programming
- **macOS 13+ Support**: Ventura and later
- **Swift Package Manager**: Dependency management
- **UserDefaults Storage**: Local data persistence
- **Async/Await**: Modern concurrency for uploads

#### Developer Experience
- **Modular Architecture**:
  - Separated Views, Models, Services, and Utils
  - Clean code organization
  - Easy to extend and maintain
- **Build Script**: Automated build process with `build.sh`
- **Comprehensive Documentation**:
  - README with setup instructions
  - CONTRIBUTING guide
  - ICON_GUIDE for customization
  - Inline code documentation

#### Files Structure
```
QuickSnipUploader/
├── Sources/
│   ├── QuickSnipUploaderApp.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── DropZoneView.swift
│   │   ├── HistoryView.swift
│   │   ├── ToastView.swift
│   │   └── SettingsView.swift
│   ├── Models/
│   │   ├── Upload.swift
│   │   └── UploadManager.swift
│   ├── Services/
│   │   ├── CatboxService.swift
│   │   ├── ClipboardService.swift
│   │   └── StorageService.swift
│   └── Utils/
│       └── GlobalShortcutMonitor.swift
├── Package.swift
├── Info.plist
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── CHANGELOG.md
├── ICON_GUIDE.md
├── build.sh
└── .gitignore
```

### Dependencies
- None - Pure Swift/SwiftUI implementation

### System Requirements
- macOS 13.0 (Ventura) or later
- Xcode 15.0+ (for building)
- Swift 5.9+

### Known Issues
- None currently identified

### Security
- Anonymous uploads (no credentials stored)
- Local-only history storage (UserDefaults)
- No analytics or tracking
- No third-party dependencies

---

## Version History

### Version Naming
- **Major (X.0.0)**: Breaking changes or major feature releases
- **Minor (1.X.0)**: New features, non-breaking
- **Patch (1.0.X)**: Bug fixes and minor improvements

### Release Phases
- **Phase 1 (v1.0.0)**: Standalone macOS app - Current Release
- **Phase 2 (v2.0.0)**: Raycast integration - Planned
- **Phase 3 (v3.0.0)**: MacBook notch features - Future

---

## Links

- [Repository](https://github.com/parkann/screenshot-uploader)
- [Issue Tracker](https://github.com/parkann/screenshot-uploader/issues)
- [Releases](https://github.com/parkann/screenshot-uploader/releases)

---

**Note**: This is the initial release. Future updates will be documented in this changelog following the Keep a Changelog format.
