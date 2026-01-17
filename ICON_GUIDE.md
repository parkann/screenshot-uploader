# App Icon Guide

This guide will help you create and add a custom app icon for Quick Snip Uploader.

## Quick Start

The app currently uses SF Symbols for the icon display. To add a custom app icon:

### Option 1: Using SF Symbols (Current)

The app currently uses the built-in SF Symbol `arrow.up.circle.fill` which displays nicely in the UI. This requires no additional setup.

### Option 2: Creating a Custom Icon

#### 1. Design Your Icon

**Requirements**:
- Size: 1024x1024px (base size)
- Format: PNG with transparency
- Style: Simple, recognizable design
- macOS style guidelines: Rounded corners, subtle gradients

**Design Suggestions**:
- An upward arrow (upload symbol)
- A cloud with an arrow
- A paperclip or pin (representing quick snipping)
- Combination of screenshot + cloud symbols

**Tools**:
- [Figma](https://figma.com) (free, browser-based)
- [Sketch](https://sketch.com) (macOS native)
- [Affinity Designer](https://affinity.serif.com/designer/)
- [Icon Slate](https://www.kodlian.com/apps/icon-slate) (macOS, generates .icns directly)

#### 2. Generate macOS Icon Set

You'll need multiple sizes for macOS:

**Required Sizes**:
```
16x16    - Menubar icon
32x32    - Menubar icon @2x
64x64    - Menubar icon @2x (Retina)
128x128  - App icon small
256x256  - App icon
512x512  - App icon @2x
1024x1024 - App Store
```

**Automated Tools**:

1. **Using Icon Slate** (Easiest):
   - Import your 1024x1024 PNG
   - It automatically generates all sizes
   - Export as `.icns` file

2. **Using iconutil (macOS built-in)**:
   ```bash
   # 1. Create iconset directory
   mkdir QuickSnipUploader.iconset

   # 2. Copy your icons with correct naming
   # icon_16x16.png
   # icon_16x16@2x.png (32x32)
   # icon_32x32.png
   # icon_32x32@2x.png (64x64)
   # icon_128x128.png
   # icon_128x128@2x.png (256x256)
   # icon_256x256.png
   # icon_256x256@2x.png (512x512)
   # icon_512x512.png
   # icon_512x512@2x.png (1024x1024)

   # 3. Generate .icns file
   iconutil -c icns QuickSnipUploader.iconset
   ```

3. **Online Tools**:
   - [AppIcon Generator](https://appicon.co/)
   - [CloudConvert](https://cloudconvert.com/png-to-icns)

#### 3. Add to Xcode Project

1. Open project in Xcode
2. Create `Assets.xcassets` folder if it doesn't exist
3. Add `AppIcon.appiconset`
4. Drag your icon sizes into the appropriate slots
5. Update `Info.plist`:
   ```xml
   <key>CFBundleIconFile</key>
   <string>AppIcon</string>
   ```

#### 4. Alternative: Quick Icon Setup (No Xcode Asset Catalog)

Place your `.icns` file in the project:

```
QuickSnipUploader/
├── Resources/
│   └── AppIcon.icns
```

Then update `Info.plist`:
```xml
<key>CFBundleIconFile</key>
<string>AppIcon</string>
```

## Icon Design Tips

### Color Palette Suggestions

**Option 1: Blue Gradient** (Modern, trustworthy)
- Primary: `#007AFF` (Apple Blue)
- Secondary: `#5AC8FA` (Light Blue)

**Option 2: Purple Gradient** (Creative, unique)
- Primary: `#5856D6` (Purple)
- Secondary: `#AF52DE` (Magenta)

**Option 3: Green Gradient** (Success, upload complete)
- Primary: `#34C759` (Green)
- Secondary: `#30D158` (Light Green)

### Design Elements

Consider incorporating:
- **Arrow pointing up**: Universal upload symbol
- **Cloud**: Cloud storage reference
- **Lightning bolt**: Speed/instant upload
- **Circular background**: macOS icon style
- **Subtle shadow/glow**: Depth and polish

### macOS Icon Guidelines

1. **Use a grid**: Follow Apple's icon grid system
2. **Rounded corners**: macOS automatically applies, but design with them in mind
3. **Consistent lighting**: Top-left light source
4. **Avoid text**: Icons should be recognizable without text
5. **Test at small sizes**: Ensure icon is clear at 16x16

## Example Icon Prompt for AI Generation

If using AI tools like DALL-E or Midjourney:

```
"A modern macOS app icon for an image upload tool. Features a clean upward arrow symbol in bright blue (#007AFF) on a subtle gradient background from light blue to white. Minimalist design with rounded corners, slight shadow, following Apple's Big Sur icon style. 1024x1024 pixels, PNG with transparency."
```

## Testing Your Icon

1. Build and run the app
2. Check the icon in:
   - Dock
   - Applications folder
   - Spotlight search
   - Command+Tab switcher
   - Menu bar (if applicable)

3. Verify at different screen densities (Retina vs non-Retina)

## Resources

- [Apple Human Interface Guidelines - macOS Icons](https://developer.apple.com/design/human-interface-guidelines/macos/icons-and-images/app-icon/)
- [macOS Icon Template (Figma)](https://www.figma.com/community/file/857303226040719059)
- [SF Symbols](https://developer.apple.com/sf-symbols/) - Apple's icon library

## Current Implementation

The app currently uses SF Symbols throughout the interface:
- **Main icon**: `arrow.up.circle.fill`
- **History**: `clock.arrow.circlepath`
- **Settings**: `gear`
- **Drag & Drop**: `photo.on.rectangle.angled`

These provide a consistent, native macOS look without requiring custom assets.

---

**Note**: Adding a custom icon is optional. The app works perfectly with SF Symbols. A custom icon is recommended if you plan to distribute the app or want a unique brand identity.
