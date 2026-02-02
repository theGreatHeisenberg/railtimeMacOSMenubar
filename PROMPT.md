# PROMPT.md - Caltrain Menu Bar App

## Objective

Build a native macOS menu bar app + widget for viewing Caltrain schedules using Swift/SwiftUI.

## Key Requirements

- Menu bar app with icon + countdown display (🚂 12m)
- Click to show dropdown with next 3 trains
- Display: departure time, arrival time, ETA, train type, delay status
- Multiple configurable source→destination route pairs
- Manual route toggle via menu
- Auto-refresh (default 1 min, configurable)
- Train approaching notifications
- Notification Center widget
- Offline support with cached data + stale indicator
- macOS 12 Monterey+ compatibility

## API

Use existing railtime API:
```
GET https://railtime.pages.dev/api/predictions?station={urlName}&stop1={stopId1}&stop2={stopId2}
```

## Acceptance Criteria

- [ ] Menu bar shows train icon + countdown to next train
- [ ] Clicking reveals list of next 3 trains with all info
- [ ] Can add/edit/delete route pairs in Settings
- [ ] Can switch between routes
- [ ] Data auto-refreshes at configured interval
- [ ] Notifications fire X minutes before departure
- [ ] Widget shows trains in Notification Center
- [ ] Works on macOS 12+ (NSStatusItem fallback for macOS 12)
- [ ] Shows cached data when offline

## Reference

Detailed design: `.sop/planning/design/detailed-design.md`
Implementation plan: `.sop/planning/implementation/plan.md`

## Instructions for Ralph

Use Claude Opus 4.5 model via kiro-cli:
```bash
kiro-cli chat --model opus
```

Follow the 12-step implementation plan in `.sop/planning/implementation/plan.md`, checking off each step as completed.
