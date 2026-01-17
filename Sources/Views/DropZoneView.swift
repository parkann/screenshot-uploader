import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct DropZoneView: View {
    @EnvironmentObject var uploadManager: UploadManager
    @Binding var isDragging: Bool

    var body: some View {
        VStack(spacing: 20) {
            if uploadManager.isUploading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Uploading...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            style: StrokeStyle(
                                lineWidth: 3,
                                dash: [10, 5]
                            )
                        )
                        .foregroundColor(isDragging ? .blue : .gray.opacity(0.5))
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(isDragging ? Color.blue.opacity(0.1) : Color.clear)
                        )

                    VStack(spacing: 16) {
                        Image(systemName: isDragging ? "arrow.down.circle.fill" : "photo.on.rectangle.angled")
                            .font(.system(size: 64))
                            .foregroundStyle(isDragging ? .blue : .gray)

                        Text(isDragging ? "Drop to upload" : "Drop image here")
                            .font(.title3)
                            .fontWeight(.medium)

                        Text("or press ⌘V to paste from clipboard")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Divider()
                            .frame(width: 200)
                            .padding(.vertical, 8)

                        Button(action: selectFile) {
                            HStack {
                                Image(systemName: "folder")
                                Text("Browse Files")
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(40)
                .onDrop(of: [.fileURL, .image], isTargeted: $isDragging) { providers in
                    handleDrop(providers: providers)
                    return true
                }
            }
        }
    }

    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            // Try to load as file URL first
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                    if let data = item as? Data,
                       let path = String(data: data, encoding: .utf8),
                       let url = URL(string: path) {
                        loadImageFromURL(url)
                    }
                }
            }
            // Try to load as image
            else if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { item, error in
                    if let data = item as? Data,
                       let image = NSImage(data: data) {
                        DispatchQueue.main.async {
                            uploadManager.uploadImage(image)
                        }
                    }
                }
            }
        }
    }

    private func loadImageFromURL(_ url: URL) {
        guard let image = NSImage(contentsOf: url) else { return }
        DispatchQueue.main.async {
            uploadManager.uploadImage(image)
        }
    }

    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.png, .jpeg, .gif, .bmp, .tiff, .webP]
        panel.message = "Select an image to upload"

        panel.begin { response in
            if response == .OK, let url = panel.url {
                loadImageFromURL(url)
            }
        }
    }
}

#Preview {
    DropZoneView(isDragging: .constant(false))
        .environmentObject(UploadManager())
        .frame(width: 600, height: 400)
}
