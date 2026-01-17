import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject var uploadManager: UploadManager
    @State private var isDragging = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue.gradient)

                Text("Quick Snip Uploader")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Drag & Drop or Paste (⌘V) to upload")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 30)
            .padding(.bottom, 20)

            // Tab picker
            Picker("", selection: $selectedTab) {
                Text("Upload").tag(0)
                Text("History").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 20)

            // Content
            TabView(selection: $selectedTab) {
                DropZoneView(isDragging: $isDragging)
                    .tag(0)

                HistoryView()
                    .tag(1)
            }
            .tabViewStyle(.automatic)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
        .overlay(
            ToastView(message: $toastMessage, isShowing: $showToast)
                .padding(.bottom, 20),
            alignment: .bottom
        )
        .onAppear {
            setupPasteMonitoring()
        }
        .onChange(of: uploadManager.lastUploadedURL) { oldValue, newValue in
            if let url = newValue {
                copyToClipboard(url)
                showToastMessage("Link Copied! ✓")
            }
        }
        .onChange(of: uploadManager.uploadError) { oldValue, newValue in
            if let error = newValue {
                showToastMessage("Error: \(error)")
            }
        }
    }

    private func setupPasteMonitoring() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "v" {
                handlePaste()
                return nil
            }
            return event
        }
    }

    private func handlePaste() {
        guard let image = ClipboardService.getImageFromClipboard() else {
            showToastMessage("No image found in clipboard")
            return
        }

        uploadManager.uploadImage(image)
    }

    private func copyToClipboard(_ text: String) {
        ClipboardService.copyToClipboard(text)
    }

    private func showToastMessage(_ message: String) {
        toastMessage = message
        withAnimation(.spring(response: 0.3)) {
            showToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring(response: 0.3)) {
                showToast = false
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UploadManager())
        .frame(width: 600, height: 500)
}
