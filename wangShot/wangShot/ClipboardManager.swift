import AppKit
import UniformTypeIdentifiers

final class ClipboardManager {
    static let shared = ClipboardManager()

    private init() {}

    func copyImageToClipboard(_ image: CGImage) throws {
        let nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
        guard let tiffData = nsImage.tiffRepresentation else {
            throw NSError(domain: "ClipboardManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create TIFF data from image."])
        }

        guard let bitmap = NSBitmapImageRep(data: tiffData) else {
            throw NSError(domain: "ClipboardManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to create bitmap representation."])
        }

        guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
            throw NSError(domain: "ClipboardManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Unable to encode PNG data."])
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        var items: [NSPasteboardItem] = []
        let item = NSPasteboardItem()
        item.setData(pngData, forType: .png)
        item.setData(tiffData, forType: .tiff)
        items.append(item)

        if !pasteboard.writeObjects(items) {
            throw NSError(domain: "ClipboardManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to write image to clipboard."])
        }
    }
}
