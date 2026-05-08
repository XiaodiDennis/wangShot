//
//  wangShotApp.swift
//  wangShot
//
//  Created by Dennis Hsiao Ti WANG on 5/8/26.
//

import SwiftUI

@main
struct wangShotApp: App {
    var body: some Scene {
        MenuBarExtra("wangShot", systemImage: "camera.fill") {
            MenuBarContent()
        }

        Settings {
            SettingsView()
        }
    }
}

private struct MenuBarContent: View {
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button("Capture Screenshot") {
                print("Capture Screenshot clicked")
            }
            Button("OCR") {
                print("OCR clicked")
            }
            Button("Translate Screenshot") {
                print("Translate Screenshot clicked")
            }
            Button("Start Recording") {
                print("Start Recording clicked")
            }
            Divider()
            Button("Settings") {
                openSettings()
            }
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
        .padding(8)
    }
}
