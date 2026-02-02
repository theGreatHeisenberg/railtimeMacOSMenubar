# Railtime API Research

## Overview
The existing railtime webapp (https://railtime.pages.dev/) provides real-time Caltrain tracking with APIs that can be consumed by the macOS app.

## Available API Endpoints

### 1. Predictions API
**Endpoint:** `https://railtime.pages.dev/api/predictions`

**Parameters:**
- `station` - Station URL name (e.g., "san-francisco", "palo-alto")
- `stop1` - First stop ID for the station
- `stop2` - Second stop ID for the station (stations have 2 platforms)

**Response:** Array of `TrainPrediction` objects:
```typescript
interface TrainPrediction {
  TrainNumber: string;      // e.g., "101", "702"
  TrainType: string;        // "Local" | "Limited" | "Bullet"
  ETA: string;              // "10 min" or "Now"
  Departure: string;        // Predicted time "12:30 PM"
  RouteID: string;
  StopID: string;
  Direction: "NB" | "SB";   // Northbound or Southbound
  timestamp: number;        // Unix timestamp
  stopIds: string[];        // All stops for this trip
  ScheduledTime?: string;   // Static schedule time "8:00 AM"
  delayMinutes?: number;    // Positive = late, negative = early
  delayStatus?: "on-time" | "early" | "delayed";
}
```

### 2. Vehicle Positions API
**Endpoint:** `https://railtime.pages.dev/api/vehicle-positions`

**Response:** Real-time GPS positions of trains (updated every 10 seconds)

## Station Data
Stations are defined in `lib/stations.json` with:
- `stop1`, `stop2` - Platform stop IDs
- `stopname` - Display name
- `urlname` - URL-friendly name for API calls
- `lat`, `lon` - Coordinates

## Key Observations
1. API is publicly accessible (no authentication required)
2. Predictions refresh every 30-60 seconds
3. Delay calculation compares real-time vs GTFS static schedule
4. Train types: Local, Limited, Bullet (determined by train number prefix)

## Data for macOS App
The macOS app needs to:
1. Fetch station list (can be bundled or fetched from API)
2. Call predictions API with selected source station
3. Filter results by direction (based on destination)
4. Display next 3 trains with all required info

## References
- GitHub: https://github.com/theGreatHeisenberg/railtime
- Live app: https://railtime.pages.dev/
