//
//  wangShotApp.swift
//  wangShot
//
//  Created by Dennis Hsiao Ti WANG on 5/8/26.
//

import SwiftUI

@main
struct wangShotApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}
