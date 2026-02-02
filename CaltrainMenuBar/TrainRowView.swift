import SwiftUI

struct TrainRowView: View {
    let prediction: TrainPrediction
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(prediction.departure)
                        .font(.system(.body, design: .monospaced))
                    Text("→")
                        .foregroundColor(.secondary)
                    Text(prediction.eta)
                        .font(.system(.body, design: .monospaced))
                }
                HStack(spacing: 6) {
                    trainTypeBadge
                    Text("#\(prediction.trainNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            delayIndicator
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private var trainTypeBadge: some View {
        Text(prediction.trainType.rawValue)
            .font(.caption)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(trainTypeColor.opacity(0.2))
            .foregroundColor(trainTypeColor)
            .cornerRadius(4)
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
            HStack(spacing: 2) {
                Circle()
                    .fill(delayColor(status))
                    .frame(width: 8, height: 8)
                if let mins = prediction.delayMinutes, mins > 0 {
                    Text("+\(mins)m")
                        .font(.caption)
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
