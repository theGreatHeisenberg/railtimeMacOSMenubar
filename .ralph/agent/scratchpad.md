# Objective: Fix swift run crash

## Status: COMPLETE

## Problem
`swift run` crashed with `bundleProxyForCurrentProcess is nil` because `UNUserNotificationCenter.current()` requires a proper app bundle.

## Solution Applied
Added `isBundled` check to `NotificationService` that guards all `UNUserNotificationCenter` calls. When running via `swift run` (no bundle), notifications are silently skipped.

## Verification
- `swift run` now starts successfully without crash
- Committed: 0b31f21
