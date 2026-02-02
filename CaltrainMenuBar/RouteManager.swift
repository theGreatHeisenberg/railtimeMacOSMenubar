import SwiftUI

@MainActor
class RouteManager: ObservableObject {
    static let shared = RouteManager()
    
    @Published var routes: [Route] = []
    @Published var activeRouteId: UUID?
    
    private let routesKey = "savedRoutes"
    private let activeRouteKey = "activeRouteId"
    
    var activeRoute: Route? {
        routes.first { $0.id == activeRouteId }
    }
    
    init() {
        loadRoutes()
    }
    
    func loadRoutes() {
        if let data = UserDefaults.standard.data(forKey: routesKey),
           let decoded = try? JSONDecoder().decode([Route].self, from: data) {
            routes = decoded
        }
        if let idString = UserDefaults.standard.string(forKey: activeRouteKey),
           let id = UUID(uuidString: idString) {
            activeRouteId = id
        }
        // Set first route as active if none selected
        if activeRouteId == nil, let first = routes.first {
            activeRouteId = first.id
        }
    }
    
    func saveRoutes() {
        if let data = try? JSONEncoder().encode(routes) {
            UserDefaults.standard.set(data, forKey: routesKey)
        }
        if let id = activeRouteId {
            UserDefaults.standard.set(id.uuidString, forKey: activeRouteKey)
        }
    }
    
    func addRoute(_ route: Route) {
        routes.append(route)
        if activeRouteId == nil {
            activeRouteId = route.id
        }
        saveRoutes()
    }
    
    func deleteRoute(_ route: Route) {
        routes.removeAll { $0.id == route.id }
        if activeRouteId == route.id {
            activeRouteId = routes.first?.id
        }
        saveRoutes()
    }
    
    func setActiveRoute(_ route: Route) {
        activeRouteId = route.id
        saveRoutes()
    }
}
