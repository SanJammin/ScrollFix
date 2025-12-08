import Cocoa

final class StatusBarController {
    private let statusItem: NSStatusItem

    init(onQuit: @escaping () -> Void) {
        // Create an item in the menu bar with variable length
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.title = "⇅"   // simple placeholder title; you can swap for an image later
            button.toolTip = "ScrollFix"
        }

        // Build a basic menu
        let menu = NSMenu()

        let quitItem = NSMenuItem(
            title: "Quit ScrollFix",
            action: #selector(quitTapped),
            keyEquivalent: "q"
        )
        quitItem.target = self

        menu.addItem(quitItem)

        statusItem.menu = menu

        self.onQuit = onQuit
    }

    // Stored callback for quitting the app
    private var onQuit: (() -> Void)?

    @objc private func quitTapped() {
        onQuit?()
    }
}
