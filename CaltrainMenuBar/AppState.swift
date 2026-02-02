import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var predictions: [TrainPrediction] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var countdown: String = "--"
    @Published var isStale = false
    
    @AppStorage("refreshInterval") private var refreshInterval: Int = 60
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("notificationMinutes") private var notificationMinutes: Int = 5
    
    private var refreshTimer: Timer?
    private var countdownTimer: Timer?
    
    init() {
        NotificationService.shared.requestPermission()
        startTimers()
    }
    
    private func scheduleNotifications() {
        guard notificationsEnabled else { return }
        NotificationService.shared.cancelAll()
        if let first = predictions.first {
            NotificationService.shared.scheduleNotification(for: first, minutesBefore: notificationMinutes)
        }
    }
    
    func startTimers() {
        stopTimers()
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(refreshInterval), repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refresh()
            }
        }
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateCountdown()
                self?.checkStale()
            }
        }
    }
    
    func stopTimers() {
        refreshTimer?.invalidate()
        countdownTimer?.invalidate()
    }
    
    func restartRefreshTimer() {
        startTimers()
    }
    
    private func checkStale() {
        Task {
            isStale = await CacheService.shared.isStale()
        }
    }
    
    private func updateCountdown() {
        guard let nextTrain = predictions.first else {
            countdown = "--"
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        guard let departureDate = formatter.date(from: nextTrain.departure) else {
            countdown = "--"
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.hour, .minute], from: departureDate)
        components.year = calendar.component(.year, from: now)
        components.month = calendar.component(.month, from: now)
        components.day = calendar.component(.day, from: now)
        
        guard let todayDeparture = calendar.date(from: components) else {
            countdown = "--"
            return
        }
        
        let minutes = Int(todayDeparture.timeIntervalSince(now) / 60)
        
        if minutes < 0 {
            countdown = "Now"
        } else if minutes == 0 {
            countdown = "<1m"
        } else if minutes < 60 {
            countdown = "\(minutes)m"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            countdown = "\(hours)h\(mins)m"
        }
    }
    
    func refresh() async {
        guard let route = RouteManager.shared.activeRoute,
              let station = StationService.shared.station(byUrlname: route.sourceStation),
              let destStation = StationService.shared.station(byUrlname: route.destinationStation) else {
            return
        }
        
        let direction: Direction = station.stop1 < destStation.stop1 ? .northbound : .southbound
        
        isLoading = true
        error = nil
        
        do {
            let fetched = try await APIService.shared.fetchPredictions(
                station: station,
                direction: direction,
                limit: 3
            )
            predictions = fetched
            isStale = false
            await CacheService.shared.save(predictions: fetched, routeId: route.id)
            scheduleNotifications()
        } catch {
            // Load from cache on network failure
            if let cached = await CacheService.shared.load(routeId: route.id) {
                predictions = cached
                isStale = await CacheService.shared.isStale()
            }
            self.error = error.localizedDescription
        }
        
        updateCountdown()
        isLoading = false
    }
}
