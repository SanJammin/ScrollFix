import SwiftUI

@main
struct ScrollFixApp: App {
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
