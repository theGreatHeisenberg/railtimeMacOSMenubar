import SwiftUI

struct MenuBarContentView: View {
    @StateObject private var appState = AppState.shared
    @StateObject private var routeManager = RouteManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            if !routeManager.routes.isEmpty {
                Divider()
                routePickerView
            }
            Divider()
            trainListView
            Divider()
            footerView
        }
        .frame(width: 280)
        .task {
            await appState.refresh()
        }
        .onChange(of: routeManager.activeRouteId) { _ in
            Task { await appState.refresh() }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("🚂 Caltrain")
                .font(.headline)
            if appState.isStale {
                Text("⚠️")
                    .help("Showing cached data")
            }
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
    
    private var routePickerView: some View {
        HStack {
            Picker("Route", selection: Binding(
                get: { routeManager.activeRouteId ?? UUID() },
                set: { id in
                    if let route = routeManager.routes.first(where: { $0.id == id }) {
                        routeManager.setActiveRoute(route)
                    }
                }
            )) {
                ForEach(routeManager.routes) { route in
                    Text(route.name).tag(route.id)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
    
    @ViewBuilder
    private var trainListView: some View {
        if routeManager.routes.isEmpty {
            Text("No routes configured.\nOpen Settings to add a route.")
                .foregroundColor(.secondary)
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding()
        } else if let error = appState.error {
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
