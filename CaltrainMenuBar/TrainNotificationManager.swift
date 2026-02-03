import Foundation
import SwiftUI
import UserNotifications

@MainActor
class TrainNotificationManager: ObservableObject {
    static let shared = TrainNotificationManager()
    
    @Published private(set) var subscribedTrains: Set<String> = [] {
        didSet { saveSubscriptions() }
    }
    @AppStorage("notificationMinutes") private var notificationMinutes = 5
    
    private let subscriptionsKey = "subscribedTrains"
    
    init() {
        loadSubscriptions()
    }
    
    private func loadSubscriptions() {
        if let data = UserDefaults.standard.stringArray(forKey: subscriptionsKey) {
            subscribedTrains = Set(data)
        }
    }
    
    private func saveSubscriptions() {
        UserDefaults.standard.set(Array(subscribedTrains), forKey: subscriptionsKey)
    }
    
    private func trainKey(_ trainNumber: String, _ departure: String) -> String {
        "\(trainNumber)-\(departure)"
    }
    
    func isSubscribed(trainNumber: String, departure: String) -> Bool {
        subscribedTrains.contains(trainKey(trainNumber, departure))
    }
    
    func toggle(prediction: TrainPrediction) {
        let key = trainKey(prediction.trainNumber, prediction.departure)
        if subscribedTrains.contains(key) {
            unsubscribe(prediction: prediction)
        } else {
            subscribe(prediction: prediction)
        }
    }
    
    private func subscribe(prediction: TrainPrediction) {
        let key = trainKey(prediction.trainNumber, prediction.departure)
        subscribedTrains.insert(key)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        guard let departureDate = formatter.date(from: prediction.departure) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.hour, .minute], from: departureDate)
        components.year = calendar.component(.year, from: now)
        components.month = calendar.component(.month, from: now)
        components.day = calendar.component(.day, from: now)
        
        guard let todayDeparture = calendar.date(from: components),
              let notifyTime = calendar.date(byAdding: .minute, value: -notificationMinutes, to: todayDeparture) else { return }
        
        let interval = max(notifyTime.timeIntervalSince(now), 1) // At least 1 second
        
        // Only schedule if train hasn't departed yet
        guard todayDeparture.timeIntervalSince(now) > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🚂 Train #\(prediction.trainNumber) departing soon"
        content.body = "\(prediction.trainType.rawValue) departs at \(prediction.departure) (\(notificationMinutes) min)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: key, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                try? "Scheduled: \(key) in \(Int(interval))s\n".write(toFile: "/tmp/railtime_notif.log", atomically: false, encoding: .utf8)
            }
        }
    }
    
    private func unsubscribe(prediction: TrainPrediction) {
        let key = trainKey(prediction.trainNumber, prediction.departure)
        subscribedTrains.remove(key)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [key])
    }
}
