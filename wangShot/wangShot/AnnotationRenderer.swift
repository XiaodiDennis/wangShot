import AppKit
import CoreGraphics
import Foundation

final class AnnotationRenderer {
    static func render(image: CGImage, annotations: [Annotation]) -> CGImage? {
        let width = image.width
        let height = image.height
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return nil
        }

        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        context.clear(CGRect(x: 0, y: 0, width: width, height: height))
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

        for annotation in annotations {
            draw(annotation: annotation, in: context, imageHeight: CGFloat(height))
        }

        return context.makeImage()
    }

    private static func draw(annotation: Annotation, in context: CGContext, imageHeight: CGFloat) {
        guard let cgColor = annotation.color.usingColorSpace(.deviceRGB)?.cgColor else {
            return
        }

        context.setStrokeColor(cgColor)
        context.setLineWidth(annotation.lineWidth)
        context.setLineCap(.round)
        context.setLineJoin(.round)

        switch annotation.kind {
        case .rectangle:
            let rect = rectangle(for: annotation, imageHeight: imageHeight)
            context.stroke(rect)

        case .arrow:
            let start = cgPoint(from: annotation.start, imageHeight: imageHeight)
            let end = cgPoint(from: annotation.end, imageHeight: imageHeight)
            context.beginPath()
            context.move(to: start)
            context.addLine(to: end)
            context.strokePath()
            drawArrowHead(from: start, to: end, lineWidth: annotation.lineWidth, in: context)

        case .select:
            break
        }
    }

    private static func rectangle(for annotation: Annotation, imageHeight: CGFloat) -> CGRect {
        let origin = CGPoint(x: min(annotation.start.x, annotation.end.x),
                             y: min(annotation.start.y, annotation.end.y))
        let size = CGSize(width: abs(annotation.end.x - annotation.start.x),
                          height: abs(annotation.end.y - annotation.start.y))
        let bottomY = imageHeight - origin.y - size.height
        return CGRect(x: origin.x, y: bottomY, width: size.width, height: size.height)
    }

    private static func cgPoint(from point: CGPoint, imageHeight: CGFloat) -> CGPoint {
        CGPoint(x: point.x, y: imageHeight - point.y)
    }

    private static func drawArrowHead(from start: CGPoint, to end: CGPoint, lineWidth: CGFloat, in context: CGContext) {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let angle = atan2(dy, dx)
        let headLength = max(16, lineWidth * 4)
        let angleOffset = CGFloat.pi * 3 / 4

        let point1 = CGPoint(x: end.x + cos(angle + angleOffset) * headLength,
                             y: end.y + sin(angle + angleOffset) * headLength)
        let point2 = CGPoint(x: end.x + cos(angle - angleOffset) * headLength,
                             y: end.y + sin(angle - angleOffset) * headLength)

        context.beginPath()
        context.move(to: end)
        context.addLine(to: point1)
        context.strokePath()

        context.beginPath()
        context.move(to: end)
        context.addLine(to: point2)
        context.strokePath()
    }
}
