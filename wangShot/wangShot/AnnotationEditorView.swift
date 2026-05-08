import SwiftUI

struct AnnotationEditorView: View {
    let viewModel: AnnotationEditorViewModel
    let onSave: () -> Void
    let onCopy: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                Color.clear
                    .overlay(
                        Image(nsImage: viewModel.nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                    )
            }
            .padding(12)

            Divider()

            HStack {
                Spacer()
                Button("Cancel", action: onCancel)
                Button("Copy", action: onCopy)
                Button("Save", action: onSave)
            }
            .padding(12)
        }
        .frame(minWidth: 640, minHeight: 480)
    }
}
