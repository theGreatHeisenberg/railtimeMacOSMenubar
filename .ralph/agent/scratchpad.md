# Objective: Fix Settings button not opening anything

## Status: COMPLETE

## Solution
Added `NSApp.activate(ignoringOtherApps: true)` before sending the `showSettingsWindow:` action.

MenuBarExtra apps run as accessory apps and need to explicitly activate themselves for the Settings window to appear.

## Commit
9317d70 - Fix Settings button not opening settings window
