import AppKit
import ScreenCaptureKit

final class ScreenshotCaptureEngine {
    static let shared = ScreenshotCaptureEngine()

    private init() {}

    func capture(region: CGRect) {
        SCScreenshotManager.captureImage(in: region) { image, error in
            if let error = error {
                print("[wangShot] Screenshot capture failed: \(error.localizedDescription)")
                return
            }

            guard let image = image else {
                print("[wangShot] Screenshot capture failed: image was nil")
                return
            }

            let outputImage = ScreenshotImageProcessor.beautify(image) ?? image

            DispatchQueue.main.async {
                AnnotationEditorWindowController.present(with: outputImage)
            }
        }
    }
}
