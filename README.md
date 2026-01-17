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

- macOS 14.0 (Sonoma) or later
- Xcode 15.0+ (for building)

## Installation

### Option 1: Download Pre-built App (Coming Soon)
Download the latest release from the [Releases](https://github.com/parkann/screenshot-uploader/releases) page.

### Option 2: Build from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/parkann/screenshot-uploader.git
   cd screenshot-uploader
   ```

2. Build with Swift Package Manager:
   ```bash
   swift build -c release
   ```

3. Create the app bundle:
   ```bash
   mkdir -p QuickSnipUploader.app/Contents/MacOS
   mkdir -p QuickSnipUploader.app/Contents/Resources
   cp .build/release/QuickSnipUploader QuickSnipUploader.app/Contents/MacOS/
   cp Info.plist QuickSnipUploader.app/Contents/
   cp AppIcon.icns QuickSnipUploader.app/Contents/Resources/
   ```

4. Launch the app:
   ```bash
   open QuickSnipUploader.app
   ```

### Option 3: Build with Xcode

1. Open in Xcode:
   ```bash
   open Package.swift
   ```

2. Build and run (⌘R)

## Usage

1. Launch the app or press ⌘⇧U
2. Drop an image, paste with ⌘V, or browse
3. URL is auto-copied to clipboard
4. Paste anywhere!

## Architecture

- **Language**: Swift 5.9+
- **UI**: SwiftUI
- **Platform**: macOS 14+ (Sonoma)
- **Upload Service**: Catbox.moe (anonymous, free)
- **Dependencies**: Zero external dependencies
- **State Management**: Modern @Observable pattern

## Project Structure

```
Sources/
├── Models/              # Data models and state management
│   ├── Upload.swift    # Upload data structure
│   └── UploadManager.swift  # Main state manager
├── Services/           # Business logic services
│   ├── CatboxService.swift  # Image upload API
│   ├── ClipboardService.swift  # macOS clipboard
│   └── StorageService.swift   # Local persistence
├── Views/              # SwiftUI components
│   ├── ContentView.swift
│   ├── DropZoneView.swift
│   ├── HistoryView.swift
│   ├── SettingsView.swift
│   └── ToastView.swift
└── Utils/
    └── GlobalShortcutMonitor.swift  # Keyboard shortcuts
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Privacy

- All uploads are anonymous (no account required)
- Upload history stored locally on your Mac
- No tracking or analytics
- Images uploaded to Catbox.moe (see their [privacy policy](https://catbox.moe/legal.php))

## Troubleshooting

**App won't open**: Make sure you're on macOS 14 or later

**Global shortcut not working**: Check System Settings → Privacy & Security → Accessibility

**Upload fails**: Check your internet connection and try again

## Credits

Built with Swift, SwiftUI, and ❤️

Upload service provided by [Catbox.moe](https://catbox.moe)

## License

MIT License - see LICENSE file for details
