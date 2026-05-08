import AppKit
import SwiftUI

struct AnnotationCanvasView: NSViewRepresentable {
    @ObservedObject var viewModel: AnnotationEditorViewModel

    func makeNSView(context: Context) -> AnnotationCanvasNSView {
        AnnotationCanvasNSView(viewModel: viewModel)
    }

    func updateNSView(_ nsView: AnnotationCanvasNSView, context: Context) {
        nsView.needsDisplay = true
    }
}

final class AnnotationCanvasNSView: NSView, NSTextFieldDelegate {
    private let viewModel: AnnotationEditorViewModel
    private var imageFrame: CGRect = .zero
    private var textField: NSTextField?
    private var textFieldImagePoint: CGPoint?
    private var isCancellingText: Bool = false

    init(viewModel: AnnotationEditorViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        wantsLayer = true
        layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isFlipped: Bool {
        true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let image = viewModel.cgImage

        let imageSize = CGSize(width: image.width, height: image.height)
        imageFrame = aspectFitFrame(for: imageSize, in: bounds.size)

        NSColor.black.withAlphaComponent(0.02).setFill()
        bounds.fill()

        let nsImage = viewModel.nsImage
        nsImage.draw(in: imageFrame, from: .zero, operation: .sourceOver, fraction: 1.0)

        let sortedAnnotations = viewModel.annotations.sorted { first, second in
            first.kind == .mosaic && second.kind != .mosaic
        }

        for annotation in sortedAnnotations {
            draw(annotation: annotation, in: imageFrame, imageSize: imageSize)
        }

        if let current = viewModel.currentAnnotation {
            draw(annotation: current, in: imageFrame, imageSize: imageSize)
        }
    }

    override func mouseDown(with event: NSEvent) {
        if textField != nil {
            commitTextField()
        }

        let location = convert(event.locationInWindow, from: nil)
        guard imageFrame.contains(location) else {
            return
        }

        let imagePoint = convertToImagePoint(location)

        if viewModel.selectedTool == .text {
            presentTextField(at: location, imagePoint: imagePoint)
            return
        }

        guard viewModel.selectedTool != .select else {
            return
        }

        viewModel.beginAnnotation(at: imagePoint)
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        guard viewModel.selectedTool != .select && viewModel.selectedTool != .text else {
            return
        }

        let location = convert(event.locationInWindow, from: nil)
        let imagePoint = convertToImagePoint(location)
        viewModel.updateCurrentAnnotation(to: imagePoint)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        guard viewModel.selectedTool != .select && viewModel.selectedTool != .text else {
            return
        }

        viewModel.finishCurrentAnnotation()
        needsDisplay = true
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            commitTextField()
            return true
        }

        if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
            cancelTextField()
            return true
        }

        return false
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        if isCancellingText {
            isCancellingText = false
            return
        }

        commitTextField()
    }

    private func presentTextField(at location: CGPoint, imagePoint: CGPoint) {
        removeTextField()

        let width: CGFloat = min(320, bounds.width - location.x - 20)
        let height: CGFloat = 28
        let x = min(location.x, bounds.width - width - 10)
        let y = min(location.y, bounds.height - height - 10)
        let frame = CGRect(x: max(10, x), y: max(10, y), width: width, height: height)

        let field = NSTextField(frame: frame)
        field.delegate = self
        field.font = NSFont.systemFont(ofSize: viewModel.selectedFontSize)
        field.textColor = viewModel.selectedColor
        field.backgroundColor = .clear
        field.isBordered = true
        field.isBezeled = true
        field.focusRingType = .default
        field.placeholderString = "Type text and press Enter"
        field.stringValue = ""

        addSubview(field)
        textField = field
        textFieldImagePoint = imagePoint
        window?.makeFirstResponder(field)
    }

    private func commitTextField() {
        guard let field = textField, let position = textFieldImagePoint else {
            removeTextField()
            return
        }

        let text = field.stringValue
        viewModel.addTextAnnotation(text: text, at: position)
        removeTextField()
        needsDisplay = true
    }

    private func cancelTextField() {
        isCancellingText = true
        removeTextField()
        needsDisplay = true
    }

    private func removeTextField() {
        textField?.removeFromSuperview()
        textField = nil
        textFieldImagePoint = nil
    }

    private func draw(annotation: Annotation, in imageFrame: CGRect, imageSize: CGSize) {
        guard annotation.kind != .select else {
            return
        }

        let start = displayPoint(from: annotation.start, imageSize: imageSize, imageFrame: imageFrame)
        let end = displayPoint(from: annotation.end, imageSize: imageSize, imageFrame: imageFrame)

        switch annotation.kind {
        case .rectangle:
            let path = NSBezierPath()
            path.lineWidth = annotation.lineWidth
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            annotation.color.setStroke()
            let rect = CGRect(x: min(start.x, end.x),
                              y: min(start.y, end.y),
                              width: abs(end.x - start.x),
                              height: abs(end.y - start.y))
            path.appendRect(rect)
            path.stroke()

        case .arrow:
            let path = NSBezierPath()
            path.lineWidth = annotation.lineWidth
            path.lineCapStyle = .round
            annotation.color.setStroke()
            path.move(to: start)
            path.line(to: end)
            path.stroke()
            drawArrowHead(from: start, to: end, lineWidth: annotation.lineWidth, color: annotation.color)

        case .text:
            guard let text = annotation.text else {
                return
            }
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: annotation.fontSize),
                .foregroundColor: annotation.color
            ]
            (text as NSString).draw(at: start, withAttributes: attributes)

        case .mosaic:
            let rect = CGRect(x: min(start.x, end.x),
                              y: min(start.y, end.y),
                              width: abs(end.x - start.x),
                              height: abs(end.y - start.y))
            if rect.width > 0, rect.height > 0,
               let pixelated = AnnotationRenderer.pixelatedRegion(for: annotation, in: viewModel.cgImage) {
                let nsImage = NSImage(cgImage: pixelated, size: rect.size)
                nsImage.draw(in: rect, from: NSRect.zero, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
            }

        case .select:
            break
        }
    }

    private func drawArrowHead(from start: CGPoint, to end: CGPoint, lineWidth: CGFloat, color: NSColor) {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let angle = atan2(dy, dx)
        let headLength = max(16, lineWidth * 4)
        let angleOffset = CGFloat.pi * 3 / 4

        let point1 = CGPoint(x: end.x + cos(angle + angleOffset) * headLength,
                             y: end.y + sin(angle + angleOffset) * headLength)
        let point2 = CGPoint(x: end.x + cos(angle - angleOffset) * headLength,
                             y: end.y + sin(angle - angleOffset) * headLength)

        let headPath = NSBezierPath()
        headPath.lineWidth = lineWidth
        headPath.lineCapStyle = .round
        color.setStroke()
        headPath.move(to: end)
        headPath.line(to: point1)
        headPath.stroke()

        headPath.removeAllPoints()
        headPath.move(to: end)
        headPath.line(to: point2)
        headPath.stroke()
    }

    private func aspectFitFrame(for imageSize: CGSize, in boundsSize: CGSize) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else {
            return .zero
        }

        let imageAspect = imageSize.width / imageSize.height
        let boundsAspect = boundsSize.width / boundsSize.height

        if imageAspect > boundsAspect {
            let width = boundsSize.width
            let height = width / imageAspect
            let y = (boundsSize.height - height) / 2
            return CGRect(x: 0, y: y, width: width, height: height)
        } else {
            let height = boundsSize.height
            let width = height * imageAspect
            let x = (boundsSize.width - width) / 2
            return CGRect(x: x, y: 0, width: width, height: height)
        }
    }

    private func convertToImagePoint(_ point: CGPoint) -> CGPoint {
        let imageSize = CGSize(width: viewModel.cgImage.width, height: viewModel.cgImage.height)
        let x = min(max(point.x - imageFrame.minX, 0), imageFrame.width)
        let y = min(max(point.y - imageFrame.minY, 0), imageFrame.height)
        let imageX = x / imageFrame.width * imageSize.width
        let imageY = y / imageFrame.height * imageSize.height
        return CGPoint(x: imageX, y: imageY)
    }

    private func displayPoint(from imagePoint: CGPoint, imageSize: CGSize, imageFrame: CGRect) -> CGPoint {
        let x = imageFrame.minX + (imagePoint.x / imageSize.width) * imageFrame.width
        let y = imageFrame.minY + (imagePoint.y / imageSize.height) * imageFrame.height
        return CGPoint(x: x, y: y)
    }
}
