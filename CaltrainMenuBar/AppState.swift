import SwiftUI
import Combine

struct PredictionWithArrival: Identifiable {
    let prediction: TrainPrediction
    let arrivalTime: String?
    var id: String { prediction.id }
}

@MainActor
class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var predictions: [PredictionWithArrival] = []
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
            NotificationService.shared.scheduleNotification(for: first.prediction, minutesBefore: notificationMinutes)
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
        
        guard let departureDate = formatter.date(from: nextTrain.prediction.departure) else {
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
        
        let direction: Direction = station.stop1 < destStation.stop1 ? .southbound : .northbound
        
        isLoading = true
        error = nil
        
        do {
            let fetched = try await APIService.shared.fetchPredictions(
                station: station,
                direction: direction,
                limit: 3
            )
            
            // Fetch destination predictions to get arrival times
            let destPredictions = try? await APIService.shared.fetchPredictions(station: destStation)
            let arrivalMap = Dictionary(uniqueKeysWithValues: (destPredictions ?? []).map { ($0.trainNumber, $0.departure) })
            
            predictions = fetched.map { PredictionWithArrival(prediction: $0, arrivalTime: arrivalMap[$0.trainNumber]) }
            isStale = false
            await CacheService.shared.save(predictions: fetched, routeId: route.id, routeName: route.name)
            scheduleNotifications()
        } catch {
            if let cached = await CacheService.shared.load(routeId: route.id) {
                predictions = cached.map { PredictionWithArrival(prediction: $0, arrivalTime: nil) }
                isStale = await CacheService.shared.isStale()
            }
            self.error = error.localizedDescription
        }
        
        updateCountdown()
        isLoading = false
    }
}
