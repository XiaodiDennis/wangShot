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

        for annotation in annotations where annotation.kind == .mosaic {
            draw(annotation: annotation, in: context, image: image, imageHeight: CGFloat(height))
        }

        for annotation in annotations where annotation.kind != .mosaic {
            draw(annotation: annotation, in: context, image: image, imageHeight: CGFloat(height))
        }

        return context.makeImage()
    }

    private static func draw(annotation: Annotation, in context: CGContext, image: CGImage, imageHeight: CGFloat) {
        switch annotation.kind {
        case .mosaic:
            drawMosaic(annotation: annotation, in: context, image: image, imageHeight: imageHeight)

        case .rectangle:
            guard let cgColor = annotation.color.usingColorSpace(.deviceRGB)?.cgColor else {
                return
            }
            context.setStrokeColor(cgColor)
            context.setLineWidth(annotation.lineWidth)
            context.setLineCap(.round)
            context.setLineJoin(.round)
            let rect = rectangle(for: annotation, imageHeight: imageHeight)
            context.stroke(rect)

        case .arrow:
            guard let cgColor = annotation.color.usingColorSpace(.deviceRGB)?.cgColor else {
                return
            }
            context.setStrokeColor(cgColor)
            context.setLineWidth(annotation.lineWidth)
            context.setLineCap(.round)
            let start = cgPoint(from: annotation.start, imageHeight: imageHeight)
            let end = cgPoint(from: annotation.end, imageHeight: imageHeight)
            context.beginPath()
            context.move(to: start)
            context.addLine(to: end)
            context.strokePath()
            drawArrowHead(from: start, to: end, lineWidth: annotation.lineWidth, in: context)

        case .text:
            drawText(annotation: annotation, in: context, imageHeight: imageHeight)

        case .select:
            break
        }
    }

    private static func drawText(annotation: Annotation, in context: CGContext, imageHeight: CGFloat) {
        guard let text = annotation.text else {
            return
        }

        let font = NSFont.systemFont(ofSize: annotation.fontSize)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: annotation.color,
            .paragraphStyle: paragraphStyle
        ]

        let point = cgPoint(from: annotation.start, imageHeight: imageHeight)
        let baselineY = point.y - font.ascender

        let nsContext = NSGraphicsContext(cgContext: context, flipped: false)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = nsContext
        (text as NSString).draw(at: CGPoint(x: point.x, y: baselineY), withAttributes: attributes)
        NSGraphicsContext.restoreGraphicsState()
    }

    private static func drawMosaic(annotation: Annotation, in context: CGContext, image: CGImage, imageHeight: CGFloat) {
        guard let pixelated = pixelatedRegion(for: annotation, in: image) else {
            return
        }

        let rect = rectangle(for: annotation, imageHeight: imageHeight)
        context.draw(pixelated, in: rect)
    }

    static func pixelatedRegion(for annotation: Annotation, in image: CGImage) -> CGImage? {
        guard annotation.mosaicStyle == .pixelate else {
            return nil
        }

        let cropRect = croppingRect(for: annotation)
        guard cropRect.width > 0, cropRect.height > 0,
              let cropped = image.cropping(to: cropRect) else {
            return nil
        }

        let blockSize = blockSize(for: annotation.mosaicStrength ?? .medium)
        let scaledWidth = max(1, Int(cropRect.width) / blockSize)
        let scaledHeight = max(1, Int(cropRect.height) / blockSize)
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return nil
        }

        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        guard let smallContext = CGContext(
            data: nil,
            width: scaledWidth,
            height: scaledHeight,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        smallContext.interpolationQuality = .none
        smallContext.draw(cropped, in: CGRect(x: 0, y: 0, width: CGFloat(scaledWidth), height: CGFloat(scaledHeight)))
        guard let smallImage = smallContext.makeImage() else {
            return nil
        }

        guard let largeContext = CGContext(
            data: nil,
            width: Int(cropRect.width),
            height: Int(cropRect.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        largeContext.interpolationQuality = .none
        largeContext.draw(smallImage, in: CGRect(x: 0, y: 0, width: cropRect.width, height: cropRect.height))
        return largeContext.makeImage()
    }

    private static func croppingRect(for annotation: Annotation) -> CGRect {
        let origin = CGPoint(x: min(annotation.start.x, annotation.end.x),
                             y: min(annotation.start.y, annotation.end.y))
        let size = CGSize(width: abs(annotation.end.x - annotation.start.x),
                          height: abs(annotation.end.y - annotation.start.y))
        return CGRect(origin: origin, size: size)
    }

    private static func blockSize(for strength: Annotation.MosaicStrength) -> Int {
        switch strength {
        case .low:
            return 24
        case .medium:
            return 12
        case .high:
            return 6
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
