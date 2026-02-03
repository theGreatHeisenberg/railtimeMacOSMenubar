# Caltrain Menu Bar

A native macOS menu bar app for viewing real-time Caltrain schedules.

![Menu Bar](https://img.shields.io/badge/macOS-12%2B-blue) ![License](https://img.shields.io/badge/license-MIT-green)

## Installation

### Download (Recommended)

1. Download the latest [CaltrainMenuBar.dmg](https://github.com/theGreatHeisenberg/railtimeMacOSMenubar/releases/latest/download/CaltrainMenuBar.dmg)
2. Open the DMG and drag `CaltrainMenuBar.app` to your Applications folder
3. Open Terminal and run: `xattr -cr /Applications/CaltrainMenuBar.app`
4. Launch from Applications
5. Look for the 🚂 icon in your menu bar

### Build from Source

```bash
git clone https://github.com/theGreatHeisenberg/railtimeMacOSMenubar.git
cd railtimeMacOSMenubar
swift build -c release
```

## Features

- 🚂 Menu bar icon with countdown to next train
- Real-time train predictions via [railtime API](https://railtime.pages.dev)
- Multiple configurable routes (e.g., Home→Work, Work→Home)
- Train type indicators (Local, Limited, Bullet)
- Departure and arrival times with station abbreviations
- Delay status with color coding
- Click any train to view details on railtime
- Departure notifications
- Offline support with cached data

## Usage

1. Click the 🚂 icon in your menu bar
2. Open Settings to add a route (e.g., Palo Alto → San Francisco)
3. View upcoming trains with real-time predictions
4. Click any train row to see full details on railtime.pages.dev

## Requirements

- macOS 12.0 (Monterey) or later

## License

MIT
