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
