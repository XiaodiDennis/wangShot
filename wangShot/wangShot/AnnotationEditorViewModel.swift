import AppKit

final class AnnotationEditorViewModel {
    let cgImage: CGImage
    let nsImage: NSImage

    init(image: CGImage) {
        self.cgImage = image
        self.nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
    }

    func saveImage() throws -> URL {
        try ScreenshotFileManager.shared.prepareScreenshotDirectory()
        let fileURL = ScreenshotFileManager.shared.nextScreenshotURL()
        try ScreenshotFileManager.shared.savePNG(image: cgImage, to: fileURL)
        return fileURL
    }

    func copyImage() throws {
        try ClipboardManager.shared.copyImageToClipboard(cgImage)
    }
}
