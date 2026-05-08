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
            let captureRect = self.selectionRectInScreenCoordinates(selectionRect: rect, screenFrame: screen.frame)

            self.closeOverlay {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                    ScreenshotCaptureEngine.shared.captureAndSave(region: captureRect)
                }
            }
        }

        window.contentView = overlayView
        overlayWindow = window

        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        window.makeFirstResponder(overlayView)
        NSApp.activate(ignoringOtherApps: true)
    }

    func closeOverlay(completion: (() -> Void)? = nil) {
        overlayWindow?.orderOut(nil)
        overlayWindow?.contentView = nil
        overlayWindow = nil

        if let completion = completion {
            DispatchQueue.main.async {
                completion()
            }
        }
    }

    private func activeScreen() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        return NSScreen.screens.first { $0.frame.contains(mouseLocation) } ?? NSScreen.main
    }

    private func selectionRectInScreenCoordinates(selectionRect: CGRect, screenFrame: CGRect) -> CGRect {
        let x = screenFrame.minX + selectionRect.minX
        let y = screenFrame.maxY - selectionRect.maxY
        return CGRect(x: x, y: y, width: selectionRect.width, height: selectionRect.height)
    }
}
