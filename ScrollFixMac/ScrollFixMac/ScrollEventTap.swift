import Cocoa

final class ScrollEventTap {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    func start() {
        // Listen for scroll wheel events
        let mask = (1 << CGEventType.scrollWheel.rawValue)

        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: { proxy, type, cgEvent, userInfo in
                guard type == .scrollWheel else {
                    return Unmanaged.passRetained(cgEvent)
                }

                // Wrap as NSEvent so we can check hasPreciseScrollingDeltas
                guard let nsEvent = NSEvent(cgEvent: cgEvent) else {
                    return Unmanaged.passRetained(cgEvent)
                }

                let precise = nsEvent.hasPreciseScrollingDeltas
                let deviceType = precise ? "trackpad" : "mouse"

                // Read current deltas
                let deltaY = cgEvent.getIntegerValueField(.scrollWheelEventDeltaAxis1)
                let preciseDeltaY = cgEvent.getDoubleValueField(.scrollWheelEventPointDeltaAxis1)

                // Log for debugging
                print("[\(deviceType)] before: deltaY=\(deltaY), precise=\(preciseDeltaY)")

                // If this is from the mouse, invert scroll
                if !precise {
                    cgEvent.setIntegerValueField(.scrollWheelEventDeltaAxis1, value: -deltaY)
                    cgEvent.setDoubleValueField(.scrollWheelEventPointDeltaAxis1, value: -preciseDeltaY)
                }

                // Log after modification
                let newDeltaY = cgEvent.getIntegerValueField(.scrollWheelEventDeltaAxis1)
                let newPreciseDeltaY = cgEvent.getDoubleValueField(.scrollWheelEventPointDeltaAxis1)

                print("[\(deviceType)] after:  deltaY=\(newDeltaY), precise=\(newPreciseDeltaY)")

                return Unmanaged.passRetained(cgEvent)
            },
            userInfo: nil
        ) else {
            print("Failed to create event tap")
            return
        }

        self.eventTap = eventTap

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        self.runLoopSource = runLoopSource

        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)

        print("ScrollEventTap started")
    }

    deinit {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        if let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }
    }
}
