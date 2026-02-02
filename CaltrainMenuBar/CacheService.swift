import Foundation

actor CacheService {
    static let shared = CacheService()
    
    private let cacheKey = "cachedPredictions"
    private let timestampKey = "cacheTimestamp"
    private let cacheExpiry: TimeInterval = 300 // 5 minutes
    
    struct CachedData: Codable {
        let predictions: [TrainPrediction]
        let routeId: UUID
    }
    
    func save(predictions: [TrainPrediction], routeId: UUID) {
        let cached = CachedData(predictions: predictions, routeId: routeId)
        if let data = try? JSONEncoder().encode(cached) {
            UserDefaults.standard.set(data, forKey: cacheKey)
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: timestampKey)
        }
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
        return Date().timeIntervalSince1970 - timestamp > cacheExpiry
    }
}
