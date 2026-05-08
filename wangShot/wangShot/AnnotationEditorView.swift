import SwiftUI

struct AnnotationEditorView: View {
    @ObservedObject var viewModel: AnnotationEditorViewModel
    let onSave: () -> Void
    let onCopy: () -> Void
    let onCancel: () -> Void

    private let colors: [NSColor] = [.systemRed, .systemBlue, .systemYellow, .systemGreen, .black, .white]
    private let lineWidths: [CGFloat] = [2, 4, 6]

    var body: some View {
        VStack(spacing: 0) {
            toolbar
                .padding(.horizontal, 12)
                .padding(.vertical, 10)

            Divider()

            AnnotationCanvasView(viewModel: viewModel)
                .frame(minWidth: 640, minHeight: 420)

            Divider()

            actionButtons
                .padding(12)
        }
        .frame(minWidth: 640, minHeight: 520)
    }

    private var toolbar: some View {
        HStack(spacing: 16) {
            toolButtons
            colorButtons
            widthButtons
            Spacer()
            undoRedoButtons
        }
    }

    private var toolButtons: some View {
        HStack(spacing: 8) {
            toolButton(title: "Select", tool: .select)
            toolButton(title: "Rectangle", tool: .rectangle)
            toolButton(title: "Arrow", tool: .arrow)
        }
    }

    private func toolButton(title: String, tool: AnnotationEditorViewModel.Tool) -> some View {
        Button(action: { viewModel.selectedTool = tool }) {
            Text(title)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
        }
        .buttonStyle(.bordered)
        .controlSize(.regular)
        .tint(viewModel.selectedTool == tool ? .blue : .gray)
    }

    private var colorButtons: some View {
        HStack(spacing: 8) {
            ForEach(colors.indices, id: \.self) { index in
                let color = colors[index]
                Button(action: { viewModel.selectedColor = color }) {
                    Circle()
                        .fill(Color(nsColor: color))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Circle()
                                .stroke(viewModel.selectedColor == color ? Color.accentColor : Color.clear, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var widthButtons: some View {
        HStack(spacing: 8) {
            ForEach(lineWidths.indices, id: \.self) { index in
                let width = lineWidths[index]
                Button(action: { viewModel.selectedLineWidth = width }) {
                    Circle()
                        .fill(viewModel.selectedLineWidth == width ? Color.accentColor : Color.gray.opacity(0.4))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                                .padding(3)
                        )
                        .overlay(
                            Circle()
                                .fill(Color.white)
                                .frame(width: width, height: width)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var undoRedoButtons: some View {
        HStack(spacing: 8) {
            Button(action: viewModel.undo) {
                Text("Undo")
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .disabled(viewModel.annotations.isEmpty)

            Button(action: viewModel.redo) {
                Text("Redo")
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .disabled(viewModel.undoneAnnotations.isEmpty)
        }
    }

    private var actionButtons: some View {
        HStack {
            Spacer()
            Button("Cancel", action: onCancel)
            Button("Copy", action: onCopy)
            Button("Save", action: onSave)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.regular)
    }
}
