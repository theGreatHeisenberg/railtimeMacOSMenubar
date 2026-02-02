import SwiftUI

struct MenuBarContentView: View {
    var body: some View {
        VStack {
            Text("Caltrain Menu Bar")
                .font(.headline)
                .padding()
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .padding()
        }
        .frame(width: 300)
    }
}
