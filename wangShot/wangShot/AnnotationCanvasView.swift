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

final class AnnotationCanvasNSView: NSView {
    private let viewModel: AnnotationEditorViewModel
    private var imageFrame: CGRect = .zero

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

        for annotation in viewModel.annotations {
            draw(annotation: annotation, in: imageFrame, imageSize: imageSize)
        }

        if let current = viewModel.currentAnnotation {
            draw(annotation: current, in: imageFrame, imageSize: imageSize)
        }
    }

    override func mouseDown(with event: NSEvent) {
        guard viewModel.selectedTool != .select else {
            return
        }

        let location = convert(event.locationInWindow, from: nil)
        guard imageFrame.contains(location) else {
            return
        }

        let imagePoint = convertToImagePoint(location)
        viewModel.beginAnnotation(at: imagePoint)
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        guard viewModel.selectedTool != .select else {
            return
        }

        let location = convert(event.locationInWindow, from: nil)
        let imagePoint = convertToImagePoint(location)
        viewModel.updateCurrentAnnotation(to: imagePoint)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        guard viewModel.selectedTool != .select else {
            return
        }

        viewModel.finishCurrentAnnotation()
        needsDisplay = true
    }

    private func draw(annotation: Annotation, in imageFrame: CGRect, imageSize: CGSize) {
        guard annotation.kind != .select else {
            return
        }

        let start = displayPoint(from: annotation.start, imageSize: imageSize, imageFrame: imageFrame)
        let end = displayPoint(from: annotation.end, imageSize: imageSize, imageFrame: imageFrame)

        let path = NSBezierPath()
        path.lineWidth = annotation.lineWidth
        path.lineCapStyle = .round
        path.lineJoinStyle = .round

        annotation.color.setStroke()

        switch annotation.kind {
        case .rectangle:
            let rect = CGRect(x: min(start.x, end.x),
                              y: min(start.y, end.y),
                              width: abs(end.x - start.x),
                              height: abs(end.y - start.y))
            path.appendRect(rect)
            path.stroke()

        case .arrow:
            path.move(to: start)
            path.line(to: end)
            path.stroke()
            drawArrowHead(from: start, to: end, lineWidth: annotation.lineWidth, color: annotation.color)

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
