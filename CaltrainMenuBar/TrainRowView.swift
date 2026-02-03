import SwiftUI

struct TrainRowView: View {
    let prediction: TrainPrediction
    var arrivalTime: String?
    var isSubscribed: Bool = false
    var onBellTap: (() -> Void)?
    @State private var isHovered = false
    
    private var sourceAbbrev: String {
        guard let route = RouteManager.shared.activeRoute,
              let station = StationService.shared.station(byUrlname: route.sourceStation) else { return "" }
        return station.abbrev
    }
    
    private var destAbbrev: String {
        guard let route = RouteManager.shared.activeRoute,
              let station = StationService.shared.station(byUrlname: route.destinationStation) else { return "" }
        return station.abbrev
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Main clickable area
            Button(action: {
                if let url = URL(string: "https://railtime.pages.dev/trains/\(prediction.trainNumber)") {
                    NSWorkspace.shared.open(url)
                }
            }) {
                HStack(spacing: 10) {
                    trainTypeBadge
                    
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            HStack(spacing: 3) {
                                Text(sourceAbbrev)
                                    .font(.caption2.weight(.semibold))
                                    .foregroundColor(.secondary)
                                Text(prediction.departure)
                                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                            }
                            
                            if let arrival = arrivalTime {
                                Image(systemName: "arrow.right")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                HStack(spacing: 3) {
                                    Text(destAbbrev)
                                        .font(.caption2.weight(.semibold))
                                        .foregroundColor(.secondary)
                                    Text(arrival)
                                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                                }
                            }
                        }
                        
                        HStack(spacing: 8) {
                            Text("#\(prediction.trainNumber)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text("departing in \(prediction.eta)")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Spacer()
                    
                    delayIndicator
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // Bell button
            Button(action: { onBellTap?() }) {
                Image(systemName: isSubscribed ? "bell.fill" : "bell")
                    .font(.caption)
                    .foregroundColor(isSubscribed ? .orange : .secondary)
            }
            .buttonStyle(.plain)
            .help(isSubscribed ? "Cancel notification" : "Notify before departure")
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background(isHovered ? Color.primary.opacity(0.05) : Color.clear)
        .cornerRadius(6)
        .onHover { isHovered = $0 }
    }
    
    @ViewBuilder
    private var trainTypeBadge: some View {
        Text(trainTypeShort)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .frame(width: 28, height: 28)
            .background(trainTypeColor)
            .cornerRadius(6)
    }
    
    private var trainTypeShort: String {
        switch prediction.trainType {
        case .bullet: return "BLT"
        case .limited: return "LTD"
        case .local: return "LCL"
        }
    }
    
    private var trainTypeColor: Color {
        switch prediction.trainType {
        case .bullet: return .red
        case .limited: return .orange
        case .local: return .blue
        }
    }
    
    @ViewBuilder
    private var delayIndicator: some View {
        if let status = prediction.delayStatus {
            HStack(spacing: 4) {
                Circle()
                    .fill(delayColor(status))
                    .frame(width: 6, height: 6)
                if let mins = prediction.delayMinutes, mins > 0 {
                    Text("+\(mins)m")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(delayColor(status))
                } else if status == .onTime {
                    Text("On time")
                        .font(.caption2)
                        .foregroundColor(delayColor(status))
                }
            }
        }
    }
    
    private func delayColor(_ status: DelayStatus) -> Color {
        switch status {
        case .onTime: return .green
        case .early: return .green
        case .delayed: return .red
        }
    }
}
