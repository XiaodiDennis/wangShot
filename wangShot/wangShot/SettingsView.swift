import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("wangShot Settings")
                .font(.title)
                .bold()

            Text("Placeholder settings content goes here.")
                .foregroundColor(.secondary)

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
