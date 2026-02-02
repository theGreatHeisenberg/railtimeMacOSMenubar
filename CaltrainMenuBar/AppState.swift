import SwiftUI

@MainActor
class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var predictions: [TrainPrediction] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private var currentStation: Station?
    private var currentDirection: Direction = .northbound
    
    func configure(station: Station, direction: Direction) {
        currentStation = station
        currentDirection = direction
    }
    
    func refresh() async {
        guard let station = currentStation else { return }
        isLoading = true
        error = nil
        
        do {
            predictions = try await APIService.shared.fetchPredictions(
                station: station,
                direction: currentDirection,
                limit: 3
            )
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}
