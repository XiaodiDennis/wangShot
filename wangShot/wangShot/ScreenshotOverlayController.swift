import AppKit

final class ScreenshotOverlayController {
    static let shared = ScreenshotOverlayController()

    private var overlayWindow: ScreenshotOverlayWindow?

    func showOverlay() {
        guard overlayWindow == nil else {
            overlayWindow?.makeKeyAndOrderFront(nil)
            return
        }

        guard let screen = activeScreen() else {
            print("[wangShot] Unable to find active screen")
            return
        }

        let window = ScreenshotOverlayWindow(contentRect: screen.frame)
        let overlayView = ScreenshotOverlayView(frame: NSRect(origin: .zero, size: screen.frame.size)) {
            self.closeOverlay()
        } confirmHandler: { rect in
            print("[wangShot] Selected rect: \(rect)")
            self.closeOverlay()
        }

        window.contentView = overlayView
        overlayWindow = window

        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        window.makeFirstResponder(overlayView)
        NSApp.activate(ignoringOtherApps: true)
    }

    func closeOverlay() {
        overlayWindow?.orderOut(nil)
        overlayWindow = nil
    }

    private func activeScreen() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        return NSScreen.screens.first { $0.frame.contains(mouseLocation) } ?? NSScreen.main
    }
}
