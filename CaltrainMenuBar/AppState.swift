import SwiftUI

@MainActor
class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var predictions: [TrainPrediction] = []
    @Published var isLoading = false
    @Published var error: String?
    
    func refresh() async {
        guard let route = RouteManager.shared.activeRoute,
              let station = StationService.shared.station(byUrlname: route.sourceStation),
              let destStation = StationService.shared.station(byUrlname: route.destinationStation) else {
            return
        }
        
        // Determine direction based on station order (north stations have lower stop IDs)
        let direction: Direction = station.stop1 < destStation.stop1 ? .northbound : .southbound
        
        isLoading = true
        error = nil
        
        do {
            predictions = try await APIService.shared.fetchPredictions(
                station: station,
                direction: direction,
                limit: 3
            )
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}
