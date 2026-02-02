import SwiftUI

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        _ = StationService.shared
        
        // Only use NSStatusItem on macOS 12; macOS 13+ uses MenuBarExtra
        if #unavailable(macOS 13.0) {
            setupStatusItem()
        }
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            updateButton(button)
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 280, height: 300)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: MenuBarContentView())
        
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            Task { @MainActor in
                if let button = self?.statusItem?.button {
                    self?.updateButton(button)
                }
            }
        }
    }
    
    private func updateButton(_ button: NSStatusBarButton) {
        let state = AppState.shared
        let stale = state.isStale ? " ⚠️" : ""
        button.title = "🚂 \(state.countdown)\(stale)"
    }
    
    @objc private func togglePopover() {
        guard let popover = popover, let button = statusItem?.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
