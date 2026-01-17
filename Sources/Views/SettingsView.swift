import SwiftUI

struct SettingsView: View {
    @AppStorage("globalShortcutEnabled") private var shortcutEnabled = true
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("showInMenuBar") private var showInMenuBar = true

    var body: some View {
        TabView {
            GeneralSettingsView(
                shortcutEnabled: $shortcutEnabled,
                launchAtLogin: $launchAtLogin,
                showInMenuBar: $showInMenuBar
            )
            .tabItem {
                Label("General", systemImage: "gear")
            }

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 450, height: 300)
    }
}

struct GeneralSettingsView: View {
    @Binding var shortcutEnabled: Bool
    @Binding var launchAtLogin: Bool
    @Binding var showInMenuBar: Bool

    var body: some View {
        Form {
            Section {
                Toggle("Enable global keyboard shortcut (⌘⇧U)", isOn: $shortcutEnabled)
                    .help("Quickly open Quick Snip Uploader from anywhere")

                Toggle("Launch at login", isOn: $launchAtLogin)
                    .help("Automatically start Quick Snip Uploader when you log in")

                Toggle("Show in menu bar", isOn: $showInMenuBar)
                    .help("Display Quick Snip Uploader icon in the menu bar")
            } header: {
                Text("Preferences")
            }

            Section {
                HStack {
                    Text("Upload service:")
                    Spacer()
                    Text("Catbox.moe")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Anonymous uploads:")
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            } header: {
                Text("Upload Settings")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.blue.gradient)

            Text("Quick Snip Uploader")
                .font(.title)
                .fontWeight(.bold)

            Text("Version 1.0.0")
                .foregroundColor(.secondary)

            Text("Lightning-fast image hosting for macOS")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Divider()
                .frame(width: 200)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "externaldrive.fill.badge.checkmark")
                    Text("Free anonymous uploads")
                }
                HStack {
                    Image(systemName: "bolt.fill")
                    Text("Instant clipboard integration")
                }
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Upload history tracking")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    SettingsView()
}
