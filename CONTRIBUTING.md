# Contributing to Quick Snip Uploader

First off, thank you for considering contributing to Quick Snip Uploader! It's people like you that make this tool better for everyone.

## Code of Conduct

By participating in this project, you are expected to uphold our Code of Conduct:

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on what is best for the community
- Show empathy towards other community members

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

**Template for Bug Reports**:

```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment:**
 - macOS Version: [e.g. 14.0 Sonoma]
 - App Version: [e.g. 1.0.0]
 - Build Method: [Xcode / Command Line]

**Additional context**
Add any other context about the problem here.
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- Use a clear and descriptive title
- Provide a detailed description of the suggested enhancement
- Explain why this enhancement would be useful
- List any similar features in other apps if applicable

### Pull Requests

1. **Fork the repo** and create your branch from `main`
2. **Make your changes**:
   - Follow the Swift style guide
   - Add comments for complex logic
   - Update documentation if needed
3. **Test your changes**:
   - Ensure the app builds without errors
   - Test all affected functionality
   - Test on different macOS versions if possible
4. **Commit your changes**:
   - Use clear commit messages
   - Reference issue numbers if applicable
5. **Push to your fork** and submit a pull request

## Development Setup

### Prerequisites

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- Swift 5.9 or later
- Git

### Setting Up Your Development Environment

1. **Clone your fork**:
   ```bash
   git clone https://github.com/your-username/screenshot-uploader.git
   cd screenshot-uploader
   ```

2. **Open in Xcode**:
   ```bash
   open Package.swift
   ```

3. **Build and run**:
   - Press `⌘R` in Xcode
   - Or use command line: `swift build && swift run`

### Project Structure

```
QuickSnipUploader/
├── Sources/
│   ├── QuickSnipUploaderApp.swift    # App entry point
│   ├── Views/                         # SwiftUI views
│   ├── Models/                        # Data models
│   ├── Services/                      # Business logic
│   └── Utils/                         # Helper utilities
├── Tests/                             # Unit tests
├── Package.swift                      # SPM manifest
└── README.md
```

## Coding Style

### Swift Style Guide

Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/):

- Use `camelCase` for variables and functions
- Use `PascalCase` for types and protocols
- Use meaningful names that describe purpose
- Prefer clarity over brevity

**Example**:

```swift
// Good
func uploadImage(_ image: NSImage) async throws -> String {
    let imageData = try convertToData(image)
    return try await performUpload(imageData)
}

// Avoid
func upl(i: NSImage) async throws -> String {
    let d = try conv(i)
    return try await up(d)
}
```

### SwiftUI Best Practices

- Keep views small and focused
- Extract complex views into separate components
- Use `@StateObject` for view-owned objects
- Use `@EnvironmentObject` for shared state
- Prefer composition over inheritance

**Example**:

```swift
// Good - Small, focused view
struct UploadButton: View {
    let action: () -> Void

    var body: some View {
        Button("Upload", action: action)
            .buttonStyle(.borderedProminent)
    }
}

// Avoid - Too many responsibilities
struct UploadView: View {
    // 200+ lines of code handling multiple concerns
}
```

### Documentation

- Add doc comments for public APIs
- Use `///` for documentation
- Include parameter and return descriptions
- Add usage examples for complex functions

**Example**:

```swift
/// Uploads an image to Catbox.moe and returns the hosted URL.
///
/// - Parameter image: The NSImage to upload
/// - Returns: The URL string where the image is hosted
/// - Throws: CatboxError if the upload fails
func uploadImage(_ image: NSImage) async throws -> String {
    // Implementation
}
```

## Testing

### Running Tests

```bash
swift test
```

### Writing Tests

- Write unit tests for new functionality
- Test error cases and edge conditions
- Use descriptive test names

**Example**:

```swift
import XCTest
@testable import QuickSnipUploader

final class ClipboardServiceTests: XCTestCase {
    func testCopyToClipboard_copiesTextSuccessfully() {
        // Arrange
        let testString = "https://example.com/image.png"

        // Act
        ClipboardService.copyToClipboard(testString)

        // Assert
        let pasteboard = NSPasteboard.general
        XCTAssertEqual(pasteboard.string(forType: .string), testString)
    }
}
```

## Commit Messages

Follow these guidelines for commit messages:

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and pull requests when applicable

**Examples**:

```
Good:
✅ Add drag and drop support for multiple file types
✅ Fix clipboard paste issue on macOS Sonoma
✅ Update README with installation instructions
✅ Refactor upload service for better error handling

Avoid:
❌ Fixed stuff
❌ Updated files
❌ WIP
❌ asdf
```

## Branching Strategy

- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/feature-name` - New features
- `fix/bug-description` - Bug fixes
- `docs/update-description` - Documentation updates

## Release Process

1. Update version in `Package.swift` and `Info.plist`
2. Update `CHANGELOG.md`
3. Create release notes
4. Tag the release: `git tag -a v1.0.0 -m "Release v1.0.0"`
5. Push tags: `git push --tags`

## Feature Roadmap

### Phase 1 (Current)
- [x] Standalone macOS app
- [x] Drag & drop support
- [x] Clipboard integration
- [x] Upload history
- [x] Global keyboard shortcut

### Phase 2 (Planned)
- [ ] Raycast extension
- [ ] Background upload service
- [ ] Quick share menu integration

### Phase 3 (Future)
- [ ] MacBook notch integration
- [ ] Menu bar mode
- [ ] Custom upload destinations

## Getting Help

- **Documentation**: Check the [README](README.md) first
- **Issues**: Search [existing issues](https://github.com/parkann/screenshot-uploader/issues)
- **Discussions**: Start a [discussion](https://github.com/parkann/screenshot-uploader/discussions)

## Recognition

Contributors will be recognized in:
- The README file
- Release notes
- Project documentation

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Quick Snip Uploader! 🚀
