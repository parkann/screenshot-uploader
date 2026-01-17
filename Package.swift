// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "QuickSnipUploader",
    platforms: [
        .macOS(.v14)
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
