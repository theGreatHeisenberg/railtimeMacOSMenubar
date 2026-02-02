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
        .frame(width: 450, height: 350)
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("🚂").font(.system(size: 64))
            Text("Caltrain Menu Bar").font(.title2.bold())
            Text("Version 1.0")
                .foregroundColor(.secondary)
            Text("Real-time Caltrain schedules in your menu bar")
                .multilineTextAlignment(.center)
            Link("railtime API", destination: URL(string: "https://railtime.pages.dev")!)
                .font(.caption)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct RoutesSettingsView: View {
    @ObservedObject private var routeManager = RouteManager.shared
    @State private var showingAddRoute = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            List {
                ForEach(routeManager.routes) { route in
                    RouteRow(route: route)
                }
                .onDelete { indexSet in
                    indexSet.forEach { routeManager.deleteRoute(routeManager.routes[$0]) }
                }
            }
            .listStyle(.inset)
            
            HStack {
                Button(action: { showingAddRoute = true }) {
                    Label("Add Route", systemImage: "plus")
                }
                Spacer()
            }
        }
        .padding()
        .sheet(isPresented: $showingAddRoute) {
            AddRouteView(isPresented: $showingAddRoute)
        }
    }
}

struct RouteRow: View {
    let route: Route
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(route.name).font(.headline)
                Text("\(stationName(route.sourceStation)) → \(stationName(route.destinationStation))")
                    .font(.caption).foregroundColor(.secondary)
            }
            Spacer()
        }
    }
    
    private func stationName(_ urlname: String) -> String {
        StationService.shared.station(byUrlname: urlname)?.stopname ?? urlname
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
        VStack(spacing: 16) {
            Text("Add Route").font(.headline)
            
            Form {
                TextField("Route Name", text: $name)
                Picker("From", selection: $sourceStation) {
                    Text("Select...").tag(nil as Station?)
                    ForEach(stations) { Text($0.stopname).tag($0 as Station?) }
                }
                Picker("To", selection: $destStation) {
                    Text("Select...").tag(nil as Station?)
                    ForEach(stations) { Text($0.stopname).tag($0 as Station?) }
                }
            }
            
            HStack {
                Button("Cancel") { isPresented = false }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("Add") {
                    if let src = sourceStation, let dst = destStation {
                        routeManager.addRoute(Route(name: name, sourceStation: src.urlname, destinationStation: dst.urlname))
                        isPresented = false
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!canSave)
            }
        }
        .padding()
        .frame(width: 350, height: 220)
    }
}

struct GeneralSettingsView: View {
    @AppStorage("refreshInterval") private var refreshInterval = 60
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("notificationMinutes") private var notificationMinutes = 5
    
    var body: some View {
        Form {
            Section("Refresh") {
                Picker("Refresh interval", selection: $refreshInterval) {
                    Text("1 minute").tag(60)
                    Text("2 minutes").tag(120)
                    Text("5 minutes").tag(300)
                }
            }
            
            Section("Notifications") {
                Toggle("Enable notifications", isOn: $notificationsEnabled)
                if notificationsEnabled {
                    Picker("Notify before departure", selection: $notificationMinutes) {
                        Text("3 minutes").tag(3)
                        Text("5 minutes").tag(5)
                        Text("10 minutes").tag(10)
                        Text("15 minutes").tag(15)
                    }
                }
            }
        }
        .padding()
    }
}
