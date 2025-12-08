import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let scrollEventTap = ScrollEventTap()
    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Start the scroll event tap once the app has finished launching
        scrollEventTap.start()

        // Set up the status bar icon and wire up toggle + quit
        statusBarController = StatusBarController(
            isInitiallyEnabled: true,
            onToggle: { [weak self] enabled in
                self?.scrollEventTap.setEnabled(enabled)
            },
            onQuit: {
                NSApplication.shared.terminate(nil)
            }
        )
    }
}
