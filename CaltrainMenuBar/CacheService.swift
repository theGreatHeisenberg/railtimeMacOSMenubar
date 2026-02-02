import Foundation
import WidgetKit

actor CacheService {
    static let shared = CacheService()
    
    private let cacheKey = "cachedPredictions"
    private let timestampKey = "cacheTimestamp"
    private let cacheExpiry: TimeInterval = 300 // 5 minutes
    private let sharedDefaults = UserDefaults(suiteName: "group.com.railtime.CaltrainMenuBar")
    
    struct CachedData: Codable {
        let predictions: [TrainPrediction]
        let routeId: UUID
    }
    
    struct WidgetTrain: Codable {
        let departure: String
        let eta: String
        let trainType: String
        let delayMinutes: Int
    }
    
    func save(predictions: [TrainPrediction], routeId: UUID, routeName: String) {
        let cached = CachedData(predictions: predictions, routeId: routeId)
        if let data = try? JSONEncoder().encode(cached) {
            UserDefaults.standard.set(data, forKey: cacheKey)
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: timestampKey)
        }
        updateWidget(predictions: predictions, routeName: routeName)
    }
    
    private func updateWidget(predictions: [TrainPrediction], routeName: String) {
        let widgetTrains = predictions.map { WidgetTrain(
            departure: $0.departure,
            eta: $0.eta,
            trainType: $0.trainType.rawValue,
            delayMinutes: $0.delayMinutes ?? 0
        )}
        if let data = try? JSONEncoder().encode(widgetTrains) {
            sharedDefaults?.set(data, forKey: "widgetTrains")
        }
        sharedDefaults?.set(routeName, forKey: "widgetRouteName")
        sharedDefaults?.set(false, forKey: "widgetIsStale")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func load(routeId: UUID) -> [TrainPrediction]? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let cached = try? JSONDecoder().decode(CachedData.self, from: data),
              cached.routeId == routeId else {
            return nil
        }
        return cached.predictions
    }
    
    func isStale() -> Bool {
        let timestamp = UserDefaults.standard.double(forKey: timestampKey)
        guard timestamp > 0 else { return true }
        let stale = Date().timeIntervalSince1970 - timestamp > cacheExpiry
        sharedDefaults?.set(stale, forKey: "widgetIsStale")
        return stale
    }
}
