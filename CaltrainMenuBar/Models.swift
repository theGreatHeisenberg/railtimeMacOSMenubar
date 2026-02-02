import Foundation

struct Station: Codable, Identifiable, Hashable {
    let stopname: String
    let urlname: String
    let stop1: String
    let stop2: String
    let lat: Double
    let lon: Double
    
    var id: String { urlname }
    
    var abbrev: String {
        switch urlname {
        case "san_francisco": return "SFO"
        case "22nd_street": return "22S"
        case "bayshore": return "BAY"
        case "south_sf": return "SSF"
        case "san_bruno": return "SBR"
        case "place_MLBR": return "MIL"
        case "broadway": return "BWY"
        case "burlingame": return "BUR"
        case "san_mateo": return "SMT"
        case "hayward_park": return "HWP"
        case "hillsdale": return "HSD"
        case "belmont": return "BEL"
        case "san_carlos": return "SCA"
        case "redwood_city": return "RWC"
        case "menlo_park": return "MNP"
        case "palo_alto": return "PAL"
        case "california_ave": return "CAL"
        case "san_antonio": return "SAN"
        case "mountain_view": return "MTV"
        case "sunnyvale": return "SNV"
        case "lawrence": return "LAW"
        case "santa_clara": return "SCL"
        case "college_park": return "CPK"
        case "sj_diridon": return "SJD"
        case "tamien": return "TAM"
        case "capitol": return "CAP"
        case "blossom_hill": return "BHL"
        case "morgan_hill": return "MRH"
        case "san_martin": return "SMR"
        case "gilroy": return "GIL"
        default: return String(stopname.prefix(3)).uppercased()
        }
    }
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
