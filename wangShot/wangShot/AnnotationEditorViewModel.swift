import AppKit
import Combine

final class AnnotationEditorViewModel: ObservableObject {
    enum Tool {
        case select
        case rectangle
        case arrow
        case text
    }

    @Published var selectedTool: Tool = .rectangle
    @Published var selectedColor: NSColor = .systemRed
    @Published var selectedLineWidth: CGFloat = 4
    @Published var selectedFontSize: CGFloat = 18
    @Published var annotations: [Annotation] = []
    @Published var undoneAnnotations: [Annotation] = []
    @Published var currentAnnotation: Annotation?

    let cgImage: CGImage
    let nsImage: NSImage

    init(image: CGImage) {
        self.cgImage = image
        self.nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
    }

    func beginAnnotation(at point: CGPoint) {
        guard selectedTool != .select && selectedTool != .text else {
            return
        }

        undoneAnnotations.removeAll()
        let kind: Annotation.Kind
        switch selectedTool {
        case .select:
            kind = .select
        case .rectangle:
            kind = .rectangle
        case .arrow:
            kind = .arrow
        case .text:
            kind = .text
        }

        currentAnnotation = Annotation.create(kind: kind, start: point, end: point, color: selectedColor, lineWidth: selectedLineWidth)
    }

    func addTextAnnotation(text: String, at point: CGPoint) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }

        undoneAnnotations.removeAll()
        let annotation = Annotation.createText(text: trimmed, at: point, color: selectedColor, fontSize: selectedFontSize)
        annotations.append(annotation)
    }

    func updateCurrentAnnotation(to point: CGPoint) {
        guard var current = currentAnnotation else {
            return
        }
        current.end = point
        currentAnnotation = current
    }

    func finishCurrentAnnotation() {
        guard let current = currentAnnotation else {
            return
        }

        let width = abs(current.end.x - current.start.x)
        let height = abs(current.end.y - current.start.y)
        if width < 4 || height < 4 {
            currentAnnotation = nil
            return
        }

        annotations.append(current)
        currentAnnotation = nil
    }

    func undo() {
        guard let last = annotations.popLast() else {
            return
        }
        undoneAnnotations.append(last)
    }

    func redo() {
        guard let restored = undoneAnnotations.popLast() else {
            return
        }
        annotations.append(restored)
    }

    func cancelCurrentAnnotation() {
        currentAnnotation = nil
    }

    func annotatedImage() -> CGImage {
        AnnotationRenderer.render(image: cgImage, annotations: annotations) ?? cgImage
    }

    func saveImage() throws -> URL {
        let annotated = annotatedImage()
        try ScreenshotFileManager.shared.prepareScreenshotDirectory()
        let fileURL = ScreenshotFileManager.shared.nextScreenshotURL()
        try ScreenshotFileManager.shared.savePNG(image: annotated, to: fileURL)
        return fileURL
    }

    func copyImage() throws {
        let annotated = annotatedImage()
        try ClipboardManager.shared.copyImageToClipboard(annotated)
    }
}
