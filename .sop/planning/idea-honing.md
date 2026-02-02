# Requirements Clarification

This document captures the Q&A process to refine the Caltrain scheduler requirements.

---

## Q1: Menu Bar App vs Widget

What type of MacOS interface do you prefer?

- **Menu bar app** - Lives in the top menu bar, click to see a dropdown with schedules
- **Widget** - Lives in the Notification Center/Widget area, always visible when you swipe
- **Both** - Menu bar with optional widget support

**Answer:** Both - Menu bar app with optional widget support

---

## Q2: Default Stations

Should the app have pre-configured default stations (e.g., your home and work stations), or should it show all stations and let you pick each time?

**Answer:** Pre-configured stations with the ability to add multiple source→destination pairs (e.g., Home→Work, Work→Home, Home→City, etc.)

---

## Q3: Information Display

What information do you want to see for each upcoming train?

Options might include:
- Departure time
- Arrival time
- Time until departure (e.g., "in 12 min")
- Train number/type (Local vs Limited vs Baby Bullet)
- Platform number
- Real-time delay status

Which of these are essential vs nice-to-have?

**Answer:** All essential except platform number:
- Departure time ✓
- Arrival time ✓
- Time until departure ✓
- Train number/type ✓
- Real-time delay status ✓

---

## Q4: Number of Trains

How many upcoming trains should be displayed at once in the menu bar dropdown? (e.g., next 3 trains, next 5 trains, or configurable?)

**Answer:** Next 3 trains

---

## Q5: Menu Bar Icon Display

What should the menu bar icon show at a glance (without clicking)?

- **Just an icon** (e.g., train icon)
- **Icon + countdown** to next train (e.g., 🚂 12m)
- **Icon + departure time** (e.g., 🚂 10:45)

**Answer:** Icon + countdown to next train (e.g., 🚂 12m)

---

## Q6: Refresh Frequency

How often should the app refresh train data?

- **Manual only** - Click to refresh
- **Automatic** - Every X minutes (e.g., every 1 min, 5 min)
- **Smart** - More frequent when a train is approaching, less frequent otherwise

**Answer:** Automatic - Every X minutes (default 1 min, configurable in settings)

---

## Q7: Notifications

Would you like notifications for any events?

- **No notifications**
- **Train approaching** - Alert X minutes before departure
- **Delays** - Alert when a saved train is delayed
- **Both**

**Answer:** Train approaching - Alert X minutes before departure

---

## Q8: Technology Preference

Do you have a preference for how the MacOS app is built?

- **Swift/SwiftUI** - Native MacOS, best performance and integration
- **Electron** - JavaScript-based, could share code with your existing webapp
- **No preference** - Let me recommend based on research

**Answer:** Swift/SwiftUI - Native MacOS for best performance

---

## Q9: Distribution

How do you plan to distribute/install the app?

- **Mac App Store** - Requires Apple Developer account, review process
- **Direct download** - Distribute .app or .dmg yourself (e.g., GitHub releases)
- **Homebrew** - Install via `brew install`
- **Personal use only** - Just build and run locally

**Answer:** Personal use only initially (build and run locally), but keep architecture open for potential Homebrew distribution later

---

## Q10: Minimum MacOS Version

What's the oldest MacOS version you need to support?

- **Latest only** (macOS 14 Sonoma+) - Newest SwiftUI features
- **Recent** (macOS 13 Ventura+) - Good balance
- **Broader support** (macOS 12 Monterey+) - Wider compatibility

**Answer:** Broader support (macOS 12 Monterey+) for wider compatibility

---

## Q11: Active Route Selection

When you have multiple source→destination pairs configured, how should the app determine which one to show?

- **Manual toggle** - Switch between routes via menu
- **Time-based** - Automatically switch based on time of day (e.g., morning = Home→Work, evening = Work→Home)
- **Show all** - Display all configured routes in the dropdown

**Answer:** Manual toggle - Switch between routes via menu

---

## Q12: Offline Behavior

What should happen when there's no internet connection or the API is unavailable?

- **Show cached data** - Display last known schedule with a "stale" indicator
- **Show error** - Display an error message
- **Both** - Show cached data if available, otherwise show error

**Answer:** Show cached data - Display last known schedule with a "stale" indicator

---

