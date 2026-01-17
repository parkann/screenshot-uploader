import SwiftUI
import AppKit
import UserNotifications

@main
struct QuickSnipUploaderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var uploadManager = UploadManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(uploadManager)
                .frame(minWidth: 600, minHeight: 500)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }

        Settings {
            SettingsView()
                .environmentObject(uploadManager)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var shortcutMonitor: GlobalShortcutMonitor?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set up global keyboard shortcut
        shortcutMonitor = GlobalShortcutMonitor()
        shortcutMonitor?.setupDefaultShortcut()

        // Request notification permissions
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Keep app running in menu bar
    }
}
