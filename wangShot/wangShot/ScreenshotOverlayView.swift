import AppKit

final class ScreenshotOverlayView: NSView {
    private var startPoint: NSPoint?
    private var currentPoint: NSPoint?
    private let closeHandler: () -> Void
    private let confirmHandler: (CGRect) -> Void

    init(frame frameRect: NSRect, closeHandler: @escaping () -> Void, confirmHandler: @escaping (CGRect) -> Void) {
        self.closeHandler = closeHandler
        self.confirmHandler = confirmHandler
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isFlipped: Bool {
        true
    }

    override var acceptsFirstResponder: Bool {
        true
    }

    override func becomeFirstResponder() -> Bool {
        true
    }

    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .crosshair)
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        NSColor.black.withAlphaComponent(0.45).setFill()
        bounds.fill()

        guard let selection = selectionRect else {
            return
        }

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current?.compositingOperation = .clear
        NSColor.clear.setFill()
        selection.fill()
        NSGraphicsContext.restoreGraphicsState()

        NSColor.white.setStroke()
        let border = NSBezierPath(rect: selection)
        border.lineWidth = 2
        border.stroke()

        drawSelectionLabel(for: selection)
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        addCursorRect(bounds, cursor: .crosshair)
    }

    override func mouseDown(with event: NSEvent) {
        startPoint = convert(event.locationInWindow, from: nil)
        currentPoint = startPoint
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        currentPoint = convert(event.locationInWindow, from: nil)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        currentPoint = convert(event.locationInWindow, from: nil)
        needsDisplay = true
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {
            closeHandler()
            return
        }

        if event.keyCode == 36 || event.keyCode == 76 || event.charactersIgnoringModifiers == "\r" || event.charactersIgnoringModifiers == "\n" {
            guard let selection = selectionRect, selection.width >= 5, selection.height >= 5 else {
                closeHandler()
                return
            }
            confirmHandler(selection)
            return
        }

        super.keyDown(with: event)
    }

    private var selectionRect: CGRect? {
        guard let start = startPoint, let current = currentPoint else {
            return nil
        }
        return CGRect(
            x: min(start.x, current.x),
            y: min(start.y, current.y),
            width: abs(current.x - start.x),
            height: abs(current.y - start.y)
        )
    }

    private func drawSelectionLabel(for selection: CGRect) {
        let text = "\(Int(selection.width)) × \(Int(selection.height))"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 12, weight: .semibold),
            .foregroundColor: NSColor.white
        ]
        let attributed = NSAttributedString(string: text, attributes: attributes)
        let size = attributed.size()
        let padding: CGFloat = 8
        let labelRect = CGRect(
            x: max(10, selection.minX + 10),
            y: max(10, selection.minY - size.height - 14),
            width: size.width + padding,
            height: size.height + 8
        )

        NSColor.black.withAlphaComponent(0.55).setFill()
        NSBezierPath(roundedRect: labelRect, xRadius: 6, yRadius: 6).fill()
        attributed.draw(at: CGPoint(x: labelRect.minX + 6, y: labelRect.minY + 4))
    }
}
