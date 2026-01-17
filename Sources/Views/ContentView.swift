import SwiftUI

struct ContentView: View {
    @Environment(UploadManager.self) private var uploadManager

    var body: some View {
        ZStack {
            TabView {
                DropZoneView()
                    .tabItem {
                        Label("Upload", systemImage: "arrow.up.circle.fill")
                    }

                HistoryView()
                    .tabItem {
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }
            }
            .frame(minWidth: 600, minHeight: 500)

            if uploadManager.showToast, let message = uploadManager.toastMessage {
                ToastView(message: message)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(100)
            }
        }
    }
}
