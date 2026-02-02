import SwiftUI

@main
struct CaltrainMenuBarApp: App {
    var body: some Scene {
        if #available(macOS 13.0, *) {
            MenuBarExtra {
                MenuBarContentView()
            } label: {
                MenuBarLabel()
            }
            .menuBarExtraStyle(.window)
            
            Settings {
                SettingsView()
            }
        }
    }
}
