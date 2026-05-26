import SwiftUI

struct CurrencyRingView: View {
    let title: String
    let daysRemaining: Int
    let totalDays: Int
    let color: Color

    private var progress: Double {
        guard totalDays > 0 else { return 0 }
        return min(1.0, Double(max(0, daysRemaining)) / Double(totalDays))
    }

    private var statusText: String {
        if daysRemaining <= 0 { return "Expired" }
        if daysRemaining > 30 { return "\(daysRemaining / 30)mo" }
        return "\(daysRemaining)d"
    }

    private var statusColor: Color {
        if daysRemaining <= 0 { return .red }
        if daysRemaining <= 14 { return .orange }
        return color
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 4)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(statusColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Text(statusText)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(statusColor)
            }
            .frame(width: 48, height: 48)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}
