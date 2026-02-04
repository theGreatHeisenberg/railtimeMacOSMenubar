import Foundation

actor APIService {
    static let shared = APIService()
    private let baseURL = "https://railtime.pages.dev/api/predictions"
    
    func fetchPredictions(station: Station) async throws -> [TrainPrediction] {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "station", value: station.urlname),
            URLQueryItem(name: "stop1", value: station.stop1),
            URLQueryItem(name: "stop2", value: station.stop2)
        ]
        
        let (data, response) = try await URLSession.shared.data(from: components.url!)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let predictions = try JSONDecoder().decode([TrainPrediction].self, from: data)
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return predictions.sorted {
            let date0 = formatter.date(from: $0.departure) ?? Date.distantFuture
            let date1 = formatter.date(from: $1.departure) ?? Date.distantFuture
            return date0 < date1
        }
    }
    
    func fetchPredictions(station: Station, direction: Direction, limit: Int = 3) async throws -> [TrainPrediction] {
        let all = try await fetchPredictions(station: station)
        return Array(all.filter { $0.direction == direction }.prefix(limit))
    }
}

enum APIError: Error {
    case invalidResponse
    case networkError
}
