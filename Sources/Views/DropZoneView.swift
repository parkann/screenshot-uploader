import SwiftUI
import UniformTypeIdentifiers

struct DropZoneView: View {
    @Environment(UploadManager.self) private var uploadManager
    @State private var isDragging = false
    @State private var showFilePicker = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.height < 500 ? 15 : 30) {
                Spacer()

                // App Icon/Logo
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: min(80, geometry.size.height * 0.12)))
                    .foregroundStyle(.blue.gradient)
                    .symbolEffect(.bounce, value: isDragging)

                Text("Quick Snip Uploader")
                    .font(geometry.size.height < 500 ? .title2 : .largeTitle)
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

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
                VStack(spacing: geometry.size.height < 500 ? 8 : 16) {
                    Text("Drag & Drop an image here")
                        .font(geometry.size.height < 500 ? .body : .title3)
                        .foregroundColor(.primary)
                        .minimumScaleFactor(0.7)

                    Text("or")
                        .foregroundColor(.secondary)
                        .font(geometry.size.height < 500 ? .caption : .body)

                    HStack(spacing: geometry.size.width < 500 ? 8 : 16) {
                        Button {
                            pasteFromClipboard()
                        } label: {
                            if geometry.size.width < 500 {
                                Label("Paste", systemImage: "doc.on.clipboard")
                                    .labelStyle(.iconOnly)
                            } else {
                                Label("Paste (⌘V)", systemImage: "doc.on.clipboard")
                            }
                        }
                        .keyboardShortcut("v", modifiers: .command)

                        Button {
                            showFilePicker = true
                        } label: {
                            if geometry.size.width < 500 {
                                Label("Browse", systemImage: "folder")
                                    .labelStyle(.iconOnly)
                            } else {
                                Label("Browse Files", systemImage: "folder")
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(geometry.size.height < 500 ? .small : .regular)
                }
            }

            Spacer()

            // Drop zone hint
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                .foregroundColor(isDragging ? .blue : .gray.opacity(0.3))
                .frame(height: max(150, min(200, geometry.size.height * 0.3)))
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: isDragging ? "arrow.down.circle.fill" : "photo.on.rectangle")
                            .font(.system(size: min(48, geometry.size.height * 0.08)))
                            .foregroundColor(isDragging ? .blue : .gray)

                        Text(isDragging ? "Drop to upload" : "Drop images here")
                            .font(geometry.size.height < 500 ? .caption : .body)
                            .foregroundColor(isDragging ? .blue : .gray)
                    }
                }
                .padding(.horizontal, max(20, min(40, geometry.size.width * 0.08)))
                .onDrop(of: [.fileURL, .image], isTargeted: $isDragging) { providers in
                    handleDrop(providers: providers)
                    return true
                }

            Spacer()
            }
            .padding()
        }
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
