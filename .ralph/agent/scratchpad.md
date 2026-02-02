# Scratchpad: Caltrain Menu Bar App

## Objective
Build a native macOS menu bar app + widget for viewing Caltrain schedules using Swift/SwiftUI.

## Current Status
Fresh start - no existing code. Need to follow 12-step implementation plan.

## Understanding
- This is a macOS menu bar app (lives in status bar)
- Shows train icon + countdown (🚂 12m)
- Clicking shows dropdown with next 3 trains
- Uses existing railtime API for predictions
- Supports multiple routes, notifications, widget, offline mode
- Must work on macOS 12+

## Implementation Plan (from .sop/planning/implementation/plan.md)
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

## Next Steps
1. Create tasks for each implementation step
2. Start with Step 1: Project setup and basic menu bar app

## Notes
- Using Swift/SwiftUI for native macOS
- MenuBarExtra for macOS 13+, NSStatusItem fallback for macOS 12
- API: https://railtime.pages.dev/api/predictions
