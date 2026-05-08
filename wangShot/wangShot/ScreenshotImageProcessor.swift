import CoreGraphics
import Foundation

final class ScreenshotImageProcessor {
    static let cornerRadius: CGFloat = 20
    static let padding: CGFloat = 32
    static let shadowOffset: CGSize = CGSize(width: 8, height: -10)
    static let shadowBlur: CGFloat = 22
    static let shadowColor: CGColor = CGColor(gray: 0, alpha: 0.25)

    static func beautify(_ image: CGImage) -> CGImage? {
        let width = image.width
        let height = image.height
        let outputWidth = width + Int(padding * 2)
        let outputHeight = height + Int(padding * 2)

        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return nil
        }

        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

        guard let maskContext = CGContext(
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

        let imageRect = CGRect(x: 0, y: 0, width: width, height: height)
        let roundedPath = CGPath(roundedRect: imageRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
        maskContext.addPath(roundedPath)
        maskContext.clip()
        maskContext.draw(image, in: imageRect)

        guard let maskedImage = maskContext.makeImage() else {
            return nil
        }

        guard let outputContext = CGContext(
            data: nil,
            width: outputWidth,
            height: outputHeight,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        outputContext.clear(CGRect(x: 0, y: 0, width: outputWidth, height: outputHeight))
        outputContext.saveGState()
        outputContext.setShadow(offset: shadowOffset, blur: shadowBlur, color: shadowColor)
        let destRect = CGRect(x: padding, y: padding, width: CGFloat(width), height: CGFloat(height))
        outputContext.draw(maskedImage, in: destRect)
        outputContext.restoreGState()

        return outputContext.makeImage()
    }
}
