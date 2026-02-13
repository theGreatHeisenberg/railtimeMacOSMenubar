# Railtime macOS Menu Bar App

## Overview
A native macOS menu bar app for real-time Caltrain schedules, part of the Railtime ecosystem.

## Tech Stack
- Swift/SwiftUI
- Swift Package Manager (not Xcode project)
- macOS 12+ (Monterey)
- MenuBarExtra (macOS 13+) with NSStatusItem fallback (macOS 12)

## Project Structure
```
CaltrainMenuBar/
├── CaltrainMenuBarApp.swift    # App entry point with MenuBarExtra
├── AppDelegate.swift           # NSStatusItem fallback, settings window, notification permissions
├── AppState.swift              # Main state: predictions, countdown, refresh logic
├── MenuBarContentView.swift    # Main popup UI
├── TrainRowView.swift          # Individual train row with bell button
├── SettingsView.swift          # Settings tabs: Routes, General, About
├── TrainNotificationManager.swift # Per-train notification subscriptions
├── RouteManager.swift          # Route CRUD, persisted to UserDefaults
├── StationService.swift        # Station data from stations.json
├── APIService.swift            # Fetches from railtime.pages.dev/api/predictions
├── CacheService.swift          # Offline cache support
├── NotificationService.swift   # Global notification service
├── Models.swift                # TrainPrediction, Station, Route, etc.
├── MenuBarLabel.swift          # Menu bar icon/text
├── stations.json               # Caltrain station data
└── Info.plist                  # App bundle config (LSUIElement=true for menu bar only)
```

## Key Features
- Real-time train predictions via railtime API
- Multiple configurable routes (e.g., Home→Work)
- Train type indicators (Bullet/Limited/Local)
- Departure & arrival times with station abbreviations
- Delay status with color coding
- Per-train notification subscriptions (bell icon)
- Configurable notification timing (3/5/10/15 min before)
- Show More/Less for train list
- Offline cache support
- Click train row to open railtime website

## Data Flow
1. User selects route (source → destination station)
2. App fetches predictions for source station filtered by direction
3. App fetches destination predictions to get arrival times
4. Predictions displayed with countdown timer

## Direction Logic
- Stop IDs increase going south (SF=70011 → Gilroy=70321)
- `station.stop1 < destStation.stop1` = southbound, else northbound

## Notifications
- Requires code signing for permissions to work
- Permission requested on app launch
- Per-train subscriptions persisted to UserDefaults
- Fires X minutes before departure (configurable)

## Building & Running
```bash
# Build
swift build -c release

# Copy to app bundle
cp .build/release/CaltrainMenuBar CaltrainMenuBar.app/Contents/MacOS/

# Sign (required for notifications)
codesign --force --deep --sign - CaltrainMenuBar.app

# Run
open CaltrainMenuBar.app
```

## GitHub Actions Release
- Workflow: `.github/workflows/release.yml`
- Triggers on tag push (`v*`)
- Builds universal binary, creates DMG, uploads to GitHub Releases
- Includes ad-hoc code signing

## Key Learnings
- `swift run` keeps terminal focus, capturing keyboard input - must use app bundle
- SwiftUI's `Settings` scene doesn't work reliably with MenuBarExtra - use NSWindow
- Info.plist with Xcode variables (`$(EXECUTABLE_NAME)`) causes "damaged app" error
- `LSUIElement=true` apps need code signing for notification permissions
- Menu bar apps need `applicationShouldTerminateAfterLastWindowClosed` returning `false`

## Settings (persisted via @AppStorage)
- `refreshInterval`: 60/120/300 seconds
- `notificationsEnabled`: bool
- `notificationMinutes`: 3/5/10/15
- `defaultTrainCount`: 3/5/10
- `routes`: JSON array of Route objects
- `activeRouteId`: UUID string
- `subscribedTrains`: array of "trainNumber-departure" keys

## API
- Predictions: `https://railtime.pages.dev/api/predictions?station={urlname}`
- Train details: `https://railtime.pages.dev/trains/{trainNumber}`

## Station Abbreviations
30 Caltrain stations with 3-letter codes (SFO, PAL, MTV, SJD, etc.) defined in Models.swift
