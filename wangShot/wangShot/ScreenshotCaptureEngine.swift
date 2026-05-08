import AppKit
import ScreenCaptureKit

final class ScreenshotCaptureEngine {
    static let shared = ScreenshotCaptureEngine()

    private init() {}

    func captureAndSave(region: CGRect) {
        SCScreenshotManager.captureImage(in: region) { image, error in
            if let error = error {
                print("[wangShot] Screenshot capture failed: \(error.localizedDescription)")
                return
            }

            guard let image = image else {
                print("[wangShot] Screenshot capture failed: image was nil")
                return
            }

            do {
                try ScreenshotFileManager.shared.prepareScreenshotDirectory()
                let fileURL = ScreenshotFileManager.shared.nextScreenshotURL()
                try ScreenshotFileManager.shared.savePNG(image: image, to: fileURL)

                DispatchQueue.main.async {
                    print("[wangShot] Saved screenshot to \(fileURL.path)")
                    ScreenshotFileManager.shared.revealInFinder(fileURL)
                }
            } catch {
                print("[wangShot] Screenshot save failed: \(error.localizedDescription)")
            }
        }
    }
}
