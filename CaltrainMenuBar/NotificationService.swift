import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private var isBundled: Bool {
        Bundle.main.bundleIdentifier != nil
    }
    
    func requestPermission() {
        guard isBundled else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    
    func scheduleNotification(for prediction: TrainPrediction, minutesBefore: Int) {
        guard isBundled else { return }
        guard let departureDate = parseTime(prediction.departure) else { return }
        let triggerDate = departureDate.addingTimeInterval(-Double(minutesBefore * 60))
        guard triggerDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Train Departing Soon"
        content.body = "\(prediction.trainType.rawValue) departs in \(minutesBefore) min at \(prediction.departure)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerDate.timeIntervalSinceNow, repeats: false)
        let request = UNNotificationRequest(identifier: "train-\(prediction.id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelAll() {
        guard isBundled else { return }
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func parseTime(_ time: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        guard let parsed = formatter.date(from: time) else { return nil }
        let cal = Calendar.current
        var comps = cal.dateComponents([.hour, .minute], from: parsed)
        comps.year = cal.component(.year, from: Date())
        comps.month = cal.component(.month, from: Date())
        comps.day = cal.component(.day, from: Date())
        return cal.date(from: comps)
    }
}
