import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
    @Environment(UploadManager.self) private var uploadManager
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
