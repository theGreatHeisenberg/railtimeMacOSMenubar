import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            RoutesSettingsView()
                .tabItem { Label("Routes", systemImage: "arrow.triangle.swap") }
            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gear") }
            AboutView()
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 480, height: 380)
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.red.opacity(0.8), .orange.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                    Text("🚂").font(.system(size: 40))
                }
                Text("Caltrain Menu Bar")
                    .font(.title2.bold())
                Text("Version 1.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text("Real-time Caltrain schedules\nright in your menu bar")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Divider().frame(width: 200)
            
            Link(destination: URL(string: "https://railtime.pages.dev")!) {
                HStack {
                    Image(systemName: "globe")
                    Text("Powered by railtime API")
                }
                .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.primary.opacity(0.02))
    }
}

struct RoutesSettingsView: View {
    @ObservedObject private var routeManager = RouteManager.shared
    @State private var showingAddRoute = false
    @State private var selectedRoute: Route?
    
    var body: some View {
        VStack(spacing: 0) {
            if routeManager.routes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "arrow.triangle.swap")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No Routes")
                        .font(.headline)
                    Text("Add a route to see train schedules")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button(action: { showingAddRoute = true }) {
                        Label("Add Route", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(selection: $selectedRoute) {
                    ForEach(routeManager.routes) { route in
                        RouteRow(route: route, isActive: route.id == routeManager.activeRouteId)
                            .tag(route)
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { routeManager.deleteRoute(routeManager.routes[$0]) }
                    }
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
                
                Divider()
                
                HStack {
                    Button(action: { showingAddRoute = true }) {
                        Label("Add", systemImage: "plus")
                    }
                    Button(action: {
                        if let route = selectedRoute {
                            routeManager.deleteRoute(route)
                            selectedRoute = nil
                        }
                    }) {
                        Label("Remove", systemImage: "minus")
                    }
                    .disabled(selectedRoute == nil)
                    Spacer()
                }
                .padding(12)
            }
        }
        .sheet(isPresented: $showingAddRoute) {
            AddRouteView(isPresented: $showingAddRoute)
        }
    }
}

struct RouteRow: View {
    let route: Route
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isActive ? .accentColor : .secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(route.name)
                    .font(.body.weight(.medium))
                HStack(spacing: 4) {
                    Text(stationAbbrev(route.sourceStation))
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                    Text(stationAbbrev(route.destinationStation))
                        .fontWeight(.semibold)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private func stationAbbrev(_ urlname: String) -> String {
        StationService.shared.station(byUrlname: urlname)?.abbrev ?? urlname
    }
}

struct AddRouteView: View {
    @Binding var isPresented: Bool
    @ObservedObject private var routeManager = RouteManager.shared
    @State private var name = ""
    @State private var sourceStation: Station?
    @State private var destStation: Station?
    
    private var stations: [Station] { StationService.shared.stations }
    private var canSave: Bool { !name.isEmpty && sourceStation != nil && destStation != nil && sourceStation != destStation }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("New Route")
                    .font(.headline)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Route Name")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("e.g., Home → Work", text: $name)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("From")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Picker("", selection: $sourceStation) {
                            Text("Select station").tag(nil as Station?)
                            ForEach(stations) { Text($0.stopname).tag($0 as Station?) }
                        }
                        .labelsHidden()
                    }
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("To")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Picker("", selection: $destStation) {
                            Text("Select station").tag(nil as Station?)
                            ForEach(stations) { Text($0.stopname).tag($0 as Station?) }
                        }
                        .labelsHidden()
                    }
                }
            }
            
            Spacer()
            
            HStack {
                Button("Cancel") { isPresented = false }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button(action: {
                    if let src = sourceStation, let dst = destStation {
                        routeManager.addRoute(Route(name: name, sourceStation: src.urlname, destinationStation: dst.urlname))
                        isPresented = false
                    }
                }) {
                    Text("Add Route")
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .disabled(!canSave)
            }
        }
        .padding(20)
        .frame(width: 400, height: 260)
    }
}

struct GeneralSettingsView: View {
    @AppStorage("refreshInterval") private var refreshInterval = 60
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("notificationMinutes") private var notificationMinutes = 5
    
    var body: some View {
        Form {
            Section {
                Picker("Refresh interval", selection: $refreshInterval) {
                    Text("1 minute").tag(60)
                    Text("2 minutes").tag(120)
                    Text("5 minutes").tag(300)
                }
            } header: {
                Label("Data Refresh", systemImage: "arrow.clockwise")
            }
            
            Section {
                Toggle("Enable departure notifications", isOn: $notificationsEnabled)
                if notificationsEnabled {
                    Picker("Notify before departure", selection: $notificationMinutes) {
                        Text("3 minutes").tag(3)
                        Text("5 minutes").tag(5)
                        Text("10 minutes").tag(10)
                        Text("15 minutes").tag(15)
                    }
                }
            } header: {
                Label("Notifications", systemImage: "bell")
            }
        }
        .padding()
    }
}
