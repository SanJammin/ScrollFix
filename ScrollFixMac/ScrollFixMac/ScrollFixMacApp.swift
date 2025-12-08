import SwiftUI

@main
struct ScrollFixMacApp: App {
    private let scrollEventTap = ScrollEventTap()
    private var statusBarController: StatusBarController?

    init() {
        scrollEventTap.start()

        // Set up the status bar icon and quit action
        statusBarController = StatusBarController {
            NSApplication.shared.terminate(nil)
        }
    }

    var body: some Scene {
        // You can keep the window for now, or remove it later.
        WindowGroup {
            ContentView()
        }
    }
}
