import WidgetKit
import SwiftUI

struct TrainEntry: TimelineEntry {
    let date: Date
    let trains: [WidgetTrain]
    let routeName: String
    let isStale: Bool
}

struct WidgetTrain: Codable {
    let departure: String
    let eta: String
    let trainType: String
    let delayMinutes: Int
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TrainEntry {
        TrainEntry(date: Date(), trains: [], routeName: "Loading...", isStale: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (TrainEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TrainEntry>) -> Void) {
        let defaults = UserDefaults(suiteName: "group.com.railtime.CaltrainMenuBar")
        let trains: [WidgetTrain] = {
            guard let data = defaults?.data(forKey: "widgetTrains"),
                  let decoded = try? JSONDecoder().decode([WidgetTrain].self, from: data) else { return [] }
            return decoded
        }()
        let routeName = defaults?.string(forKey: "widgetRouteName") ?? "No Route"
        let isStale = defaults?.bool(forKey: "widgetIsStale") ?? true
        
        let entry = TrainEntry(date: Date(), trains: trains, routeName: routeName, isStale: isStale)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct CaltrainWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("🚂 \(entry.routeName)")
                    .font(.caption)
                    .fontWeight(.semibold)
                if entry.isStale {
                    Text("⚠️")
                }
            }
            
            if entry.trains.isEmpty {
                Text("No trains")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(entry.trains.prefix(family == .systemSmall ? 2 : 3), id: \.departure) { train in
                    HStack {
                        Text(train.departure)
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        Text(train.trainType)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        if train.delayMinutes > 0 {
                            Text("+\(train.delayMinutes)m")
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .padding(8)
    }
}

@main
struct CaltrainWidget: Widget {
    let kind: String = "CaltrainWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CaltrainWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Caltrain")
        .description("Next train departures")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
