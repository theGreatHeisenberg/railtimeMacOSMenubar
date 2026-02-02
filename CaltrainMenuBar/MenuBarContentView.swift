import SwiftUI

struct MenuBarContentView: View {
    @StateObject private var appState = AppState.shared
    @StateObject private var routeManager = RouteManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            if !routeManager.routes.isEmpty {
                routePickerView
            }
            Divider().padding(.horizontal, 12)
            trainListView
            Divider().padding(.horizontal, 12)
            footerView
        }
        .frame(width: 300)
        .task {
            await appState.refresh()
        }
        .onChange(of: routeManager.activeRouteId) { _ in
            Task { await appState.refresh() }
        }
    }
    
    private var headerView: some View {
        HStack {
            HStack(spacing: 6) {
                Text("🚂")
                    .font(.title2)
                Text("Caltrain")
                    .font(.headline)
            }
            if appState.isStale {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                    .help("Showing cached data")
            }
            Spacer()
            if appState.isLoading {
                ProgressView()
                    .scaleEffect(0.6)
            } else {
                Button(action: { Task { await appState.refresh() } }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.primary.opacity(0.03))
    }
    
    private var routePickerView: some View {
        HStack {
            Image(systemName: "arrow.triangle.swap")
                .font(.caption)
                .foregroundColor(.secondary)
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
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    private var trainListView: some View {
        if routeManager.routes.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "tram.fill")
                    .font(.largeTitle)
                    .foregroundColor(.secondary.opacity(0.5))
                Text("No routes configured")
                    .font(.subheadline.weight(.medium))
                Text("Open Settings to add a route")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        } else if let error = appState.error {
            HStack {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.red)
                Text(error)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        } else if appState.predictions.isEmpty && !appState.isLoading {
            VStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.title2)
                    .foregroundColor(.secondary.opacity(0.5))
                Text("No trains available")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        } else {
            VStack(spacing: 0) {
                ForEach(appState.predictions) { item in
                    TrainRowView(prediction: item.prediction, arrivalTime: item.arrivalTime)
                        .padding(.horizontal, 14)
                    if item.id != appState.predictions.last?.id {
                        Divider().padding(.horizontal, 14).padding(.vertical, 2)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var footerView: some View {
        HStack {
            Button(action: { AppDelegate.shared?.openSettings() }) {
                Label("Settings", systemImage: "gear")
            }
            .buttonStyle(.plain)
            Spacer()
            Button(action: { NSApplication.shared.terminate(nil) }) {
                Label("Quit", systemImage: "power")
            }
            .buttonStyle(.plain)
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}
