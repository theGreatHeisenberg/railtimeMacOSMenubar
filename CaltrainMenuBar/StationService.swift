import Foundation

class StationService {
    static let shared = StationService()
    private(set) var stations: [Station] = []
    
    private init() {
        loadStations()
    }
    
    private func loadStations() {
        guard let url = Bundle.main.url(forResource: "stations", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Station].self, from: data) else {
            print("Failed to load stations.json")
            return
        }
        stations = decoded
        print("Loaded \(stations.count) stations")
    }
    
    func station(byUrlname urlname: String) -> Station? {
        stations.first { $0.urlname == urlname }
    }
}
