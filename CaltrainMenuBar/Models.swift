import Foundation

struct Station: Codable, Identifiable, Hashable {
    let stopname: String
    let urlname: String
    let stop1: String
    let stop2: String
    let lat: Double
    let lon: Double
    
    var id: String { urlname }
}

struct Route: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var sourceStation: String  // urlname
    var destinationStation: String  // urlname
    
    init(name: String, sourceStation: String, destinationStation: String) {
        self.id = UUID()
        self.name = name
        self.sourceStation = sourceStation
        self.destinationStation = destinationStation
    }
}

enum TrainType: String, Codable {
    case local = "Local"
    case limited = "Limited"
    case bullet = "Bullet"
}

enum DelayStatus: String, Codable {
    case onTime = "on-time"
    case early = "early"
    case delayed = "delayed"
}

enum Direction: String, Codable {
    case northbound = "NB"
    case southbound = "SB"
}

struct TrainPrediction: Codable, Identifiable {
    let trainNumber: String
    let trainType: TrainType
    let eta: String
    let departure: String
    let direction: Direction
    let delayMinutes: Int?
    let delayStatus: DelayStatus?
    let scheduledTime: String?
    
    var id: String { trainNumber }
    
    enum CodingKeys: String, CodingKey {
        case trainNumber = "TrainNumber"
        case trainType = "TrainType"
        case eta = "ETA"
        case departure = "Departure"
        case direction = "Direction"
        case delayMinutes
        case delayStatus
        case scheduledTime = "ScheduledTime"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        trainNumber = try container.decode(String.self, forKey: .trainNumber)
        let typeString = try container.decode(String.self, forKey: .trainType)
        trainType = TrainType(rawValue: typeString) ?? .local
        eta = try container.decode(String.self, forKey: .eta)
        departure = try container.decode(String.self, forKey: .departure)
        let dirString = try container.decode(String.self, forKey: .direction)
        direction = Direction(rawValue: dirString) ?? .northbound
        delayMinutes = try container.decodeIfPresent(Int.self, forKey: .delayMinutes)
        let statusString = try container.decodeIfPresent(String.self, forKey: .delayStatus)
        delayStatus = statusString.flatMap { DelayStatus(rawValue: $0) }
        scheduledTime = try container.decodeIfPresent(String.self, forKey: .scheduledTime)
    }
}
