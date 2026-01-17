// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "QuickSnipUploader",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "QuickSnipUploader",
            targets: ["QuickSnipUploader"]
        )
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
