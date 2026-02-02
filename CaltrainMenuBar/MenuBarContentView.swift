import SwiftUI

struct MenuBarContentView: View {
    @StateObject private var appState = AppState.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            Divider()
            trainListView
            Divider()
            footerView
        }
        .frame(width: 280)
        .task {
            if appState.predictions.isEmpty {
                // Default to Palo Alto northbound for now
                if let station = StationService.shared.station(byUrlname: "palo-alto") {
                    appState.configure(station: station, direction: .northbound)
                    await appState.refresh()
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("🚂 Caltrain")
                .font(.headline)
            Spacer()
            if appState.isLoading {
                ProgressView()
                    .scaleEffect(0.7)
            } else {
                Button(action: { Task { await appState.refresh() } }) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var trainListView: some View {
        if let error = appState.error {
            Text(error)
                .foregroundColor(.red)
                .font(.caption)
                .padding()
        } else if appState.predictions.isEmpty && !appState.isLoading {
            Text("No trains available")
                .foregroundColor(.secondary)
                .padding()
        } else {
            VStack(spacing: 0) {
                ForEach(appState.predictions) { prediction in
                    TrainRowView(prediction: prediction)
                        .padding(.horizontal, 12)
                    if prediction.id != appState.predictions.last?.id {
                        Divider().padding(.horizontal, 12)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private var footerView: some View {
        HStack {
            Button("Settings...") {
                if #available(macOS 13.0, *) {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                } else {
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                }
            }
            .buttonStyle(.plain)
            Spacer()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
