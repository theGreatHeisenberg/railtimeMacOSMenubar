# SwiftUI Menu Bar & Widget Research

## Menu Bar App Implementation

### MenuBarExtra (macOS 13+)
SwiftUI's `MenuBarExtra` provides native menu bar integration:

```swift
@main
struct CaltrainApp: App {
    var body: some Scene {
        MenuBarExtra("Caltrain", systemImage: "tram.fill") {
            ContentView()
                .frame(width: 300, height: 400)
        }
        .menuBarExtraStyle(.window)
    }
}
```

**Key features:**
- `.menuBarExtraStyle(.window)` - Allows custom SwiftUI views (not just menus)
- Can show icon + text in menu bar
- Set `LSUIElement = YES` in Info.plist to hide from Dock

### NSStatusItem (macOS 12 Monterey Compatibility)
For macOS 12 support, must use AppKit's `NSStatusItem`:

```swift
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "🚂 12m"
        
        let popover = NSPopover()
        popover.contentViewController = NSHostingController(rootView: ContentView())
        // Show popover on click
    }
}
```

### Recommended Approach for macOS 12+
Use `@available` checks to use MenuBarExtra on macOS 13+ and fall back to NSStatusItem on macOS 12:

```swift
@main
struct CaltrainApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        if #available(macOS 13.0, *) {
            MenuBarExtra {
                ContentView()
            } label: {
                Label("🚂 12m", systemImage: "tram.fill")
            }
            .menuBarExtraStyle(.window)
        }
        Settings {
            SettingsView()
        }
    }
}
```

## WidgetKit for macOS

### Widget Extension Setup
1. File → New → Target → Widget Extension
2. Supports macOS 11+ (Big Sur)
3. Widgets are read-only, refresh on timeline

### Widget Sizes (macOS)
- `.systemSmall` - Small square
- `.systemMedium` - Wide rectangle
- `.systemLarge` - Large square

### Widget Implementation
```swift
struct CaltrainWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "CaltrainWidget", provider: Provider()) { entry in
            CaltrainWidgetView(entry: entry)
        }
        .configurationDisplayName("Caltrain")
        .description("Next train departures")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Provider: TimelineProvider {
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        // Fetch data and create timeline entries
        // Widgets refresh based on timeline, not real-time
    }
}
```

### Widget Limitations
- No real-time updates (timeline-based refresh)
- Read-only (no interactive elements pre-iOS 17)
- Limited to specific sizes
- Cannot make network calls directly in widget view

### Widget Data Sharing
Use App Groups to share data between main app and widget:
1. Enable App Groups capability
2. Use `UserDefaults(suiteName: "group.com.yourapp")` for shared data

## Key Decisions

### Menu Bar: Hybrid Approach
- Use `MenuBarExtra` for macOS 13+ (cleaner SwiftUI code)
- Fall back to `NSStatusItem` + `NSPopover` for macOS 12
- Both can display icon + countdown text

### Widget: Timeline-Based
- Widget will show cached/scheduled data
- Main app handles real-time updates
- Widget refreshes every 15-30 minutes (configurable)
- Use App Groups to share route preferences and cached predictions

## References
- [MenuBarExtra Documentation](https://developer.apple.com/documentation/swiftui/menubarextra)
- [Build a macOS menu bar utility](https://nilcoalescing.com/blog/BuildAMacOSMenuBarUtilityInSwiftUI)
- [WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
