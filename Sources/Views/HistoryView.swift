import SwiftUI

struct HistoryView: View {
    @Environment(UploadManager.self) private var uploadManager

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Upload History")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Text("\(uploadManager.uploads.count) uploads")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            .padding()

            Divider()

            if uploadManager.uploads.isEmpty {
                VStack(spacing: 16) {
                    Spacer()

                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 64))
                        .foregroundColor(.gray)

                    Text("No uploads yet")
                        .font(.title3)
                        .foregroundColor(.secondary)

                    Text("Your upload history will appear here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()
                }
            } else {
                List {
                    ForEach(uploadManager.uploads) { upload in
                        HistoryRow(upload: upload)
                            .contextMenu {
                                Button("Copy URL") {
                                    uploadManager.copyURL(upload.url)
                                }

                                Button("Open in Browser") {
                                    if let url = URL(string: upload.url) {
                                        NSWorkspace.shared.open(url)
                                    }
                                }

                                Divider()

                                Button("Delete", role: .destructive) {
                                    uploadManager.deleteUpload(upload)
                                }
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

struct HistoryRow: View {
    let upload: Upload
    @Environment(UploadManager.self) private var uploadManager

    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let thumbnailData = upload.thumbnailData,
               let nsImage = NSImage(data: thumbnailData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(upload.fileName)
                    .font(.headline)
                    .lineLimit(1)

                Text(upload.url)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .lineLimit(1)

                Text(upload.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Actions
            HStack(spacing: 8) {
                Button {
                    uploadManager.copyURL(upload.url)
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.plain)
                .help("Copy URL")

                Button {
                    if let url = URL(string: upload.url) {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Image(systemName: "safari")
                }
                .buttonStyle(.plain)
                .help("Open in Browser")

                Button {
                    uploadManager.deleteUpload(upload)
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
                .foregroundColor(.red)
                .help("Delete")
            }
        }
        .padding(.vertical, 8)
    }
}
