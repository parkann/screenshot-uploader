import Cocoa
import Carbon

class GlobalShortcutMonitor {
    private var eventHotKey: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?

    func setupDefaultShortcut() {
        // Register Cmd+Shift+U as the default shortcut
        registerShortcut(keyCode: UInt32(kVK_ANSI_U), modifiers: UInt32(cmdKey | shiftKey))
    }

    private func registerShortcut(keyCode: UInt32, modifiers: UInt32) {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        // Install event handler
        InstallEventHandler(GetApplicationEventTarget(), { (_, event, userData) -> OSStatus in
            GlobalShortcutMonitor.handleHotKeyEvent()
            return noErr
        }, 1, &eventType, nil, &eventHandler)

        // Register hot key
        var hotKeyID = EventHotKeyID(signature: OSType(0x4B455921), id: 1) // 'KEY!'
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &eventHotKey)
    }

    private static func handleHotKeyEvent() {
        DispatchQueue.main.async {
            // Activate the app and bring window to front
            NSApp.activate(ignoringOtherApps: true)

            // If there's a main window, bring it forward
            if let window = NSApp.windows.first(where: { $0.isVisible }) {
                window.makeKeyAndOrderFront(nil)
            }
        }
    }

    deinit {
        if let eventHotKey = eventHotKey {
            UnregisterEventHotKey(eventHotKey)
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }
}
