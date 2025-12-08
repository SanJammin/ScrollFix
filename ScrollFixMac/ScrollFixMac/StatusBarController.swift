import Cocoa

final class StatusBarController {
    private let statusItem: NSStatusItem
    private var toggleItem: NSMenuItem!
    private var isEnabled: Bool
    private let onToggle: (Bool) -> Void
    private let onQuit: () -> Void

    init(
        isInitiallyEnabled: Bool = true,
        onToggle: @escaping (Bool) -> Void,
        onQuit: @escaping () -> Void
    ) {
        self.isEnabled = isInitiallyEnabled
        self.onToggle = onToggle
        self.onQuit = onQuit

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            // Simple SF Symbol as a logo for now
            button.image = NSImage(
                systemSymbolName: "arrow.up.arrow.down.circle",
                accessibilityDescription: "ScrollFix"
            )
            button.image?.isTemplate = true
            button.toolTip = "ScrollFix"
        }

        let menu = NSMenu()

        toggleItem = NSMenuItem(
            title: "Enabled",
            action: #selector(toggleClicked),
            keyEquivalent: ""
        )
        toggleItem.target = self
        toggleItem.state = isEnabled ? .on : .off
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(
            title: "Quit ScrollFixMac",
            action: #selector(quitClicked),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu

        // Apply initial state once at startup
        onToggle(isEnabled)
    }

    @objc private func toggleClicked() {
        isEnabled.toggle()
        toggleItem.state = isEnabled ? .on : .off
        onToggle(isEnabled)
    }

    @objc private func quitClicked() {
        onQuit()
    }
}
