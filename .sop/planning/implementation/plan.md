# Implementation Plan: Caltrain Menu Bar App

## Checklist

- [ ] Step 1: Project setup and basic menu bar app
- [ ] Step 2: Data models and station data
- [ ] Step 3: API service with predictions fetching
- [ ] Step 4: Menu bar content view with train list
- [ ] Step 5: Route management and persistence
- [ ] Step 6: Settings view and preferences
- [ ] Step 7: Auto-refresh and countdown timer
- [ ] Step 8: Cache layer and offline support
- [ ] Step 9: Train approaching notifications
- [ ] Step 10: Widget extension
- [ ] Step 11: macOS 12 compatibility fallback
- [ ] Step 12: Polish and final testing

---

## Step 1: Project Setup and Basic Menu Bar App

**Objective:** Create Xcode project with menu bar app displaying static icon + text.

**Implementation guidance:**
- Create new macOS App project in Xcode (SwiftUI, Swift)
- Set deployment target to macOS 12.0
- Replace `WindowGroup` with `MenuBarExtra` scene
- Set `LSUIElement = YES` in Info.plist to hide from Dock
- Display static "🚂 --" in menu bar

**Test requirements:**
- App launches and shows icon in menu bar
- App does not appear in Dock
- Clicking icon shows empty popover

**Demo:** Menu bar shows train icon, clicking reveals empty dropdown window.

---

## Step 2: Data Models and Station Data

**Objective:** Define core data models and bundle station list.

**Implementation guidance:**
- Create `Station`, `Route`, `TrainPrediction`, `TrainType`, `DelayStatus` models
- Copy station data from railtime repo (`stations.json`)
- Create `StationService` to load and query stations
- Models should be `Codable` for persistence

**Test requirements:**
- Station list loads correctly from bundled JSON
- Models encode/decode properly

**Demo:** Print station count to console on app launch, confirming data loads.

---

## Step 3: API Service with Predictions Fetching

**Objective:** Fetch real-time predictions from railtime API.

**Implementation guidance:**
- Create `APIService` with async `fetchPredictions(station:)` method
- Parse JSON response into `[TrainPrediction]`
- Handle network errors gracefully
- Filter to next 3 trains, sorted by departure time

**Test requirements:**
- API returns valid predictions for known station
- Error handling works for network failures

**Demo:** Fetch predictions for "Palo Alto" and print to console.

---

## Step 4: Menu Bar Content View with Train List

**Objective:** Display fetched trains in the menu bar dropdown.

**Implementation guidance:**
- Create `MenuBarContentView` with list of trains
- Create `TrainRowView` showing: departure time, ETA, train type, delay status
- Use color coding for delay status (green/yellow/red)
- Add "Quit" button at bottom

**Test requirements:**
- Train list displays correctly with all required info
- Colors match delay status

**Demo:** Click menu bar icon, see list of next 3 trains with departure times and delay indicators.

---

## Step 5: Route Management and Persistence

**Objective:** Allow users to configure and switch between routes.

**Implementation guidance:**
- Create `RouteManager` (ObservableObject) to manage routes
- Store routes in `UserDefaults`
- Create `RoutePickerView` for selecting active route
- Add route selector to top of `MenuBarContentView`
- Filter predictions by direction based on destination

**Test requirements:**
- Routes persist across app restarts
- Switching routes updates displayed predictions

**Demo:** Add two routes (Home→Work, Work→Home), switch between them, see different train directions.

---

## Step 6: Settings View and Preferences

**Objective:** Provide settings window for configuration.

**Implementation guidance:**
- Create `SettingsView` with:
  - Route management (add/edit/delete routes)
  - Refresh interval picker (1, 2, 5 minutes)
  - Notification settings (enable/disable, minutes before)
- Use SwiftUI `Settings` scene
- Store preferences in `UserDefaults`

**Test requirements:**
- Settings window opens from menu bar
- Preferences persist correctly

**Demo:** Open Settings, add a new route, change refresh interval, verify changes apply.

---

## Step 7: Auto-Refresh and Countdown Timer

**Objective:** Automatically refresh data and update countdown display.

**Implementation guidance:**
- Add `Timer` to refresh predictions at configured interval
- Update `MenuBarLabel` to show countdown to next train (e.g., "🚂 12m")
- Countdown updates every minute
- Show "--" when no trains available

**Test requirements:**
- Data refreshes automatically
- Menu bar countdown updates in real-time

**Demo:** Watch menu bar countdown decrease each minute, see it reset after refresh fetches new data.

---

## Step 8: Cache Layer and Offline Support

**Objective:** Cache predictions and handle offline gracefully.

**Implementation guidance:**
- Create `CacheService` to store last successful predictions
- Show cached data when network unavailable
- Add "stale" indicator (⚠️) when showing cached data
- Cache expires after 5 minutes

**Test requirements:**
- Cached data displays when offline
- Stale indicator appears appropriately

**Demo:** Disconnect network, app shows cached trains with stale indicator.

---

## Step 9: Train Approaching Notifications

**Objective:** Alert user when train departure is approaching.

**Implementation guidance:**
- Create `NotificationService` using `UserNotifications` framework
- Request notification permission on first launch
- Schedule notification X minutes before departure (configurable)
- Cancel outdated notifications on refresh

**Test requirements:**
- Notification appears at correct time
- Notifications respect user preferences

**Demo:** Set notification for 5 minutes before, wait for notification to appear.

---

## Step 10: Widget Extension

**Objective:** Add Notification Center widget showing next trains.

**Implementation guidance:**
- Add Widget Extension target to project
- Enable App Groups for data sharing
- Create `CaltrainWidget` with small/medium sizes
- Widget reads cached data from shared `UserDefaults`
- Configure timeline to refresh every 15 minutes

**Test requirements:**
- Widget displays in Notification Center
- Widget shows current route's trains
- Widget updates when main app refreshes

**Demo:** Add widget to Notification Center, see next trains displayed, verify it updates.

---

## Step 11: macOS 12 Compatibility Fallback

**Objective:** Support macOS 12 Monterey using AppKit fallback.

**Implementation guidance:**
- Create `AppDelegate` with `NSStatusItem` setup
- Use `@available` checks to conditionally use MenuBarExtra (macOS 13+) or NSStatusItem (macOS 12)
- `NSPopover` hosts same SwiftUI `MenuBarContentView`
- Ensure feature parity between both approaches

**Test requirements:**
- App works correctly on macOS 12
- App works correctly on macOS 13+

**Demo:** Run on macOS 12 (or simulator), verify menu bar app functions identically.

---

## Step 12: Polish and Final Testing

**Objective:** Final polish, edge cases, and release preparation.

**Implementation guidance:**
- Add app icon
- Handle edge cases (no routes configured, API down, empty predictions)
- Add "About" section in Settings
- Test on multiple macOS versions
- Create README with build instructions
- Prepare for potential Homebrew distribution (proper signing, DMG creation)

**Test requirements:**
- All edge cases handled gracefully
- No crashes or hangs
- Clean build with no warnings

**Demo:** Complete walkthrough: launch app, configure routes, see trains, receive notification, use widget.
