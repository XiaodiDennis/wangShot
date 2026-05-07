import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("wangShot Settings")
                .font(.title)
                .bold()

            Text("This is the placeholder settings window for wangShot.")
                .foregroundColor(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                Text("General")
                    .font(.headline)

                Text("Configure global shortcuts, export preferences, OCR defaults, and recording options here.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .frame(minWidth: 480, minHeight: 320)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
