import SwiftUI

@main
struct CaltrainMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        mainScene
        Settings {
            SettingsView()
        }
    }
    
    @SceneBuilder
    private var mainScene: some Scene {
        if #available(macOS 13.0, *) {
            MenuBarExtra {
                MenuBarContentView()
            } label: {
                MenuBarLabel()
            }
            .menuBarExtraStyle(.window)
        }
    }
}
