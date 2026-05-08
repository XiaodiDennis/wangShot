import AppKit
import SwiftUI

final class AnnotationEditorWindowController: NSWindowController, NSWindowDelegate {
    private static var activeControllers = [AnnotationEditorWindowController]()
    private let viewModel: AnnotationEditorViewModel

    init(image: CGImage) {
        self.viewModel = AnnotationEditorViewModel(image: image)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 600),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Annotation Editor"
        window.isReleasedWhenClosed = false
        window.center()
        window.minSize = NSSize(width: 640, height: 480)
        window.level = .normal

        super.init(window: window)

        let contentView = AnnotationEditorView(
            viewModel: viewModel,
            onSave: { [weak self] in self?.saveAction() },
            onCopy: { [weak self] in self?.copyAction() },
            onCancel: { [weak self] in self?.cancelAction() }
        )

        let hostingController = NSHostingController(rootView: contentView)
        window.contentViewController = hostingController
        window.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func present(with image: CGImage) {
        let controller = AnnotationEditorWindowController(image: image)
        activeControllers.append(controller)
        controller.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func saveAction() {
        do {
            let savedURL = try viewModel.saveImage()
            ScreenshotFileManager.shared.revealInFinder(savedURL)
            closeEditor()
            print("[wangShot] Screenshot saved to \(savedURL.path)")
        } catch {
            print("[wangShot] Save failed: \(error.localizedDescription)")
        }
    }

    private func copyAction() {
        do {
            try viewModel.copyImage()
            closeEditor()
            print("[wangShot] Copied screenshot image to clipboard")
        } catch {
            print("[wangShot] Clipboard copy failed: \(error.localizedDescription)")
        }
    }

    private func cancelAction() {
        closeEditor()
    }

    private func closeEditor() {
        window?.close()
    }

    func windowWillClose(_ notification: Notification) {
        Self.activeControllers.removeAll { $0 === self }
    }
}
