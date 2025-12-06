import SwiftUI

@main
struct ScrollFixMacApp: App {
    private let scrollEventTap = ScrollEventTap()

    init() {
        scrollEventTap.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
