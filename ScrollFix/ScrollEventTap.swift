import Cocoa

final class ScrollEventTap {
    private var monitor: Any?

    func start() {
        // Listen globally for scroll wheel events
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .scrollWheel) { event in
            let deltaY = event.scrollingDeltaY
            let deltaX = event.scrollingDeltaX
            let precise = event.hasPreciseScrollingDeltas

            let deviceType = precise ? "trackpad" : "mouse"
            
            print("[\(deviceType)]Scroll event: deltaY=\(deltaY), deltaX=\(deltaX), precise=\(precise)")
        }

        if monitor == nil {
            print("Failed to start global monitor")
        } else {
            print("Global scroll monitor started")
        }
    }

    deinit {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
