# Detailed Design: Caltrain Menu Bar App for macOS

## Overview

A native macOS menu bar application and widget for viewing Caltrain schedules. The app displays real-time train predictions with countdown timers, leveraging the existing railtime.pages.dev API.

---

## Detailed Requirements

### Core Features
1. **Menu bar app** with icon + countdown display (e.g., 🚂 12m)
2. **Notification Center widget** for at-a-glance schedule viewing
3. **Multiple route support** - configurable source→destination pairs
4. **Manual route toggle** via menu selection

### Display Information (per train)
- Departure time (predicted)
- Arrival time at destination
- Time until departure (countdown)
- Train type (Local/Limited/Bullet)
- Real-time delay status (on-time/early/delayed)

### Behavior
- Show next 3 upcoming trains
- Auto-refresh every X minutes (default: 1 min, configurable)
- Train approaching notifications (X minutes before departure)
- Cached data with "stale" indicator when offline

### Technical Constraints
- macOS 12 Monterey+ compatibility
- Swift/SwiftUI native implementation
- Personal use initially, Homebrew-ready architecture

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      macOS System                           │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │  Menu Bar    │    │   Widget     │    │  Settings    │  │
│  │  (Primary)   │    │  Extension   │    │   Window     │  │
│  └──────┬───────┘    └──────┬───────┘    └──────┬───────┘  │
│         │                   │                   │          │
│         └───────────────────┼───────────────────┘          │
│                             │                              │
│                    ┌────────▼────────┐                     │
│                    │  Shared Data    │                     │
│                    │  (App Groups)   │                     │
│                    └────────┬────────┘                     │
│                             │                              │
│         ┌───────────────────┼───────────────────┐          │
│         │                   │                   │          │
│  ┌──────▼───────┐   ┌───────▼──────┐   ┌───────▼──────┐   │
│  │ API Service  │   │ Cache Layer  │   │ Preferences  │   │
│  └──────┬───────┘   └──────────────┘   └──────────────┘   │
└─────────┼───────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────┐
│ railtime.pages.dev  │
│   /api/predictions  │
└─────────────────────┘
```

---

## Components and Interfaces

### 1. App Entry Point

```swift
@main
struct CaltrainMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
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
```

For macOS 12 compatibility, `AppDelegate` handles `NSStatusItem` fallback.

### 2. Core Views

| View | Purpose |
|------|---------|
| `MenuBarLabel` | Icon + countdown in menu bar |
| `MenuBarContentView` | Dropdown with train list |
| `TrainRowView` | Single train display |
| `RoutePickerView` | Route selection UI |
| `SettingsView` | Preferences window |
| `WidgetView` | Widget extension UI |

### 3. Services

#### APIService
```swift
protocol APIServiceProtocol {
    func fetchPredictions(station: Station, direction: Direction) async throws -> [TrainPrediction]
}
```

#### CacheService
```swift
protocol CacheServiceProtocol {
    func save(predictions: [TrainPrediction], for route: Route)
    func load(for route: Route) -> CachedPredictions?
    var isStale: Bool { get }
}
```

#### NotificationService
```swift
protocol NotificationServiceProtocol {
    func scheduleApproachingAlert(for train: TrainPrediction, minutesBefore: Int)
    func cancelAll()
}
```

### 4. Shared Data Layer (App Groups)

```swift
// Shared via UserDefaults(suiteName: "group.com.railtime.caltrain")
struct SharedData: Codable {
    var routes: [Route]
    var activeRouteIndex: Int
    var cachedPredictions: [String: CachedPredictions]
    var lastUpdate: Date
}
```

---

## Data Models

```swift
struct Route: Codable, Identifiable {
    let id: UUID
    var name: String           // "Home → Work"
    var source: Station
    var destination: Station
}

struct Station: Codable {
    let stopId1: String
    let stopId2: String
    let name: String
    let urlName: String
}

struct TrainPrediction: Codable, Identifiable {
    var id: String { trainNumber }
    let trainNumber: String
    let trainType: TrainType   // .local, .limited, .bullet
    let departureTime: Date
    let arrivalTime: Date?
    let etaMinutes: Int
    let delayMinutes: Int?
    let delayStatus: DelayStatus?
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

struct CachedPredictions: Codable {
    let predictions: [TrainPrediction]
    let fetchedAt: Date
    var isStale: Bool { Date().timeIntervalSince(fetchedAt) > 300 }
}
```

---

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Network unavailable | Show cached data with "Offline" indicator |
| API error | Show cached data with "Error" indicator, retry on next interval |
| No cached data | Show "No data available" message |
| Invalid route config | Prompt user to configure routes in Settings |

---

## Testing Strategy

### Unit Tests
- API response parsing
- Cache expiration logic
- ETA calculation
- Delay status determination

### Integration Tests
- API service with mock responses
- Cache read/write operations
- App Groups data sharing

### Manual Testing
- Menu bar appearance across macOS versions
- Widget refresh behavior
- Notification delivery
- Offline mode transitions

---

## Appendices

### A. Technology Choices

| Choice | Rationale |
|--------|-----------|
| Swift/SwiftUI | Native performance, best macOS integration |
| MenuBarExtra + NSStatusItem | MenuBarExtra for macOS 13+, NSStatusItem fallback for macOS 12 |
| WidgetKit | Native widget support, timeline-based refresh |
| App Groups | Required for main app ↔ widget data sharing |
| UserDefaults | Simple persistence for preferences and cache |

### B. API Integration

**Endpoint:** `https://railtime.pages.dev/api/predictions`

**Request:**
```
GET /api/predictions?station={urlName}&stop1={stopId1}&stop2={stopId2}
```

**Response:** Array of predictions (see Data Models)

### C. Alternative Approaches Considered

1. **Electron app** - Rejected for performance; Swift is lighter and more native
2. **Real-time widget updates** - Not possible; WidgetKit uses timeline-based refresh
3. **Local GTFS parsing** - Unnecessary; API already handles this

### D. File Structure

```
CaltrainMenuBar/
├── CaltrainMenuBarApp.swift      # App entry point
├── AppDelegate.swift             # macOS 12 fallback
├── Views/
│   ├── MenuBarLabel.swift
│   ├── MenuBarContentView.swift
│   ├── TrainRowView.swift
│   ├── RoutePickerView.swift
│   └── SettingsView.swift
├── Services/
│   ├── APIService.swift
│   ├── CacheService.swift
│   └── NotificationService.swift
├── Models/
│   ├── Route.swift
│   ├── Station.swift
│   └── TrainPrediction.swift
├── Shared/
│   └── SharedData.swift
├── Resources/
│   └── stations.json
└── CaltrainWidget/               # Widget extension target
    ├── CaltrainWidget.swift
    └── WidgetViews.swift
```
