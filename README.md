# Caltrain Menu Bar

A native macOS menu bar app for viewing Caltrain schedules.

## Features

- 🚂 Menu bar icon with countdown to next train
- Real-time train predictions via railtime API
- Multiple configurable routes (e.g., Home→Work, Work→Home)
- Train type indicators (Local, Limited, Bullet)
- Delay status with color coding
- Notification Center widget
- Offline support with cached data
- macOS 12+ compatibility

## Requirements

- macOS 12.0 (Monterey) or later
- Xcode 14+ (for building)

## Building

### With Xcode

1. Open `CaltrainMenuBar.xcodeproj`
2. Select the CaltrainMenuBar scheme
3. Build and run (⌘R)

### With Swift Package Manager

```bash
swift build
```

## Usage

1. Launch the app - a train icon appears in the menu bar
2. Click the icon to see upcoming trains
3. Open Settings (⌘,) to:
   - Add/edit routes
   - Configure refresh interval
   - Enable departure notifications

## API

Uses the [railtime API](https://railtime.pages.dev) for real-time predictions:

```
GET https://railtime.pages.dev/api/predictions?station={urlName}&stop1={stopId1}&stop2={stopId2}
```

## License

MIT
