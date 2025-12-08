import Cocoa
import ApplicationServices // add this line

final class ScrollEventTap {
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    // Time of last mouse scroll (in seconds, from system clock)
    private var lastMouseScrollTime: CFAbsoluteTime = 0
    // How long after a mouse scroll we kill trackpad momentum (in seconds)
    private let momentumCutoff: CFTimeInterval = 0.2

    func start() {
        // Listen for scroll wheel events
        let mask = (1 << CGEventType.scrollWheel.rawValue)
        
        // Quick debug to check accessibility trust
        let trusted = AXIsProcessTrusted()
        print("ScrollEventTap.start called, AX trusted = \(trusted)")
        
        // Pass self into the callback via userInfo so we can update/read state
        let userInfo = Unmanaged.passUnretained(self).toOpaque()

        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: { proxy, type, cgEvent, userInfoPointer in
                guard type == .scrollWheel else {
                    return Unmanaged.passRetained(cgEvent)
                }
                
                guard let userInfoPointer = userInfoPointer else {
                    return Unmanaged.passRetained(cgEvent)
                }
                
                // Get back our ScrollEventTap instance
                let tapSelf = Unmanaged<ScrollEventTap>
                    .fromOpaque(userInfoPointer)
                    .takeUnretainedValue()

                // Wrap as NSEvent so we can check hasPreciseScrollingDeltas
                guard let nsEvent = NSEvent(cgEvent: cgEvent) else {
                    return Unmanaged.passRetained(cgEvent)
                }

                let isPrecise = nsEvent.hasPreciseScrollingDeltas
                let deviceType = isPrecise ? "trackpad" : "mouse"
                let now = CFAbsoluteTimeGetCurrent()
                
                let momentumPhase = nsEvent.momentumPhase
                let phase = nsEvent.phase

                // Read current deltas
                let deltaY = cgEvent.getIntegerValueField(.scrollWheelEventDeltaAxis1)
                let preciseDeltaY = cgEvent.getDoubleValueField(.scrollWheelEventPointDeltaAxis1)

                // 1. If this is a mouse scroll, update last mouse time and invert
                if !isPrecise {
                    // Record the time of mouse scroll
                    tapSelf.lastMouseScrollTime = now
                    
                    // Invert mouse scroll
                    cgEvent.setIntegerValueField(.scrollWheelEventDeltaAxis1, value: -deltaY)
                    cgEvent.setDoubleValueField(.scrollWheelEventPointDeltaAxis1, value: -preciseDeltaY)
                    
                    let newDeltaY = cgEvent.getIntegerValueField(.scrollWheelEventDeltaAxis1)
                    let newPreciseDeltaY = cgEvent.getDoubleValueField(.scrollWheelEventPointDeltaAxis1)

                    print("[\(deviceType)] after:  deltaY=\(newDeltaY), precise=\(newPreciseDeltaY)")

                    return Unmanaged.passRetained(cgEvent)
                }
                // 2. If this is a trackpad event, we normally leave it alone
                //    But we may want to kill "momentum" if it is very soon after mouse use
                
                // Deteck trackpad momentum scrolls
                let isMomentum = !momentumPhase.isEmpty
                
                if isMomentum {
                    let dt = now - tapSelf.lastMouseScrollTime
                    
                    // If momentum is happening very shortly after mouse scroll drop,
                    // returning nil here cancels the momentum event completely.
                    if dt >= 0 && dt < tapSelf.momentumCutoff {
                        print("[trackpad] dropping momentum (dt=\(dt)) after mouse scroll")
                        return nil
                    }
                }
                
                // For non-momentum trackpad scrolls (normal finger scroll),
                // or momentum far away from mouse usage, just pass through
                print("[trackpad] phase=\(phase.rawValue), momentum=\(momentumPhase.rawValue) y=\(deltaY) precise=\(preciseDeltaY)")
                
                return Unmanaged.passRetained(cgEvent)
            },
            userInfo: userInfo
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
