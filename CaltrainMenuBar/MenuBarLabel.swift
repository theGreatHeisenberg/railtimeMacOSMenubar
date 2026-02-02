import SwiftUI

struct MenuBarLabel: View {
    @ObservedObject private var appState = AppState.shared
    
    var body: some View {
        HStack(spacing: 4) {
            Text("🚂")
            Text(appState.countdown)
                .font(.system(.body, design: .monospaced))
            if appState.isStale {
                Text("⚠️")
            }
        }
    }
}
