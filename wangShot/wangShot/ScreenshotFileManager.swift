import AppKit
import UniformTypeIdentifiers

final class ScreenshotFileManager {
    static let shared = ScreenshotFileManager()

    let screenshotDirectory: URL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Pictures/wangShot/Screenshots")

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()

    private init() {}

    func prepareScreenshotDirectory() throws {
        try FileManager.default.createDirectory(at: screenshotDirectory, withIntermediateDirectories: true, attributes: nil)
    }

    func nextScreenshotURL() -> URL {
        let filename = "wangShot_\(dateFormatter.string(from: Date())).png"
        return screenshotDirectory.appendingPathComponent(filename)
    }

    func savePNG(image: CGImage, to url: URL) throws {
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
            throw NSError(domain: "ScreenshotFileManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create PNG destination."])
        }

        CGImageDestinationAddImage(destination, image, nil)

        guard CGImageDestinationFinalize(destination) else {
            throw NSError(domain: "ScreenshotFileManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to write PNG file."])
        }
    }

    func revealInFinder(_ url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}
