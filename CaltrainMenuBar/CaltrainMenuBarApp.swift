import SwiftUI

@main
struct CaltrainMenuBarApp: App {
    init() {
        _ = StationService.shared
        testAPI()
    }
    
    private func testAPI() {
        Task {
            guard let station = StationService.shared.station(byUrlname: "palo-alto") else {
                print("Station not found")
                return
            }
            do {
                let predictions = try await APIService.shared.fetchPredictions(station: station)
                print("Fetched \(predictions.count) predictions for Palo Alto:")
                for p in predictions.prefix(3) {
                    print("  \(p.trainNumber) \(p.trainType.rawValue) - \(p.departure) (\(p.eta)) \(p.direction.rawValue)")
                }
            } catch {
                print("API Error: \(error)")
            }
        }
    }
    
    var body: some Scene {
        if #available(macOS 13.0, *) {
            MenuBarExtra {
                MenuBarContentView()
            } label: {
                MenuBarLabel()
            }
            .menuBarExtraStyle(.window)
            
            Settings {
                SettingsView()
            }
        }
    }
}
