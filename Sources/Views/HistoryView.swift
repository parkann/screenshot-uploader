import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var uploadManager: UploadManager
    @State private var copiedURL: String?

    var body: some View {
        VStack(spacing: 0) {
            if uploadManager.uploadHistory.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)

                    Text("No uploads yet")
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text("Your upload history will appear here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(uploadManager.uploadHistory.reversed()) { upload in
                            HistoryItemView(
                                upload: upload,
                                isCopied: copiedURL == upload.url,
                                onCopy: {
                                    ClipboardService.copyToClipboard(upload.url)
                                    copiedURL = upload.url

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        if copiedURL == upload.url {
                                            copiedURL = nil
                                        }
                                    }
                                },
                                onDelete: {
                                    uploadManager.deleteUpload(upload)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct HistoryItemView: View {
    let upload: Upload
    let isCopied: Bool
    let onCopy: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let thumbnail = upload.thumbnail {
                Image(nsImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(upload.url)
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(1)
                    .truncationMode(.middle)

                Text(upload.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Actions
            HStack(spacing: 8) {
                Button(action: onCopy) {
                    Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                        .foregroundColor(isCopied ? .green : .blue)
                }
                .buttonStyle(.plain)
                .help(isCopied ? "Copied!" : "Copy URL")

                Button(action: { NSWorkspace.shared.open(URL(string: upload.url)!) }) {
                    Image(systemName: "arrow.up.forward.square")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .help("Open in browser")

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Delete from history")
            }
            .font(.title3)
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    HistoryView()
        .environmentObject(UploadManager())
        .frame(width: 600, height: 400)
}
