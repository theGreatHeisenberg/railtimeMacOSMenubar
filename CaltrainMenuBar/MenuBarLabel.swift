import SwiftUI

struct MenuBarLabel: View {
    var body: some View {
        HStack(spacing: 4) {
            Text("🚂")
            Text("--")
                .font(.system(.body, design: .monospaced))
        }
    }
}
