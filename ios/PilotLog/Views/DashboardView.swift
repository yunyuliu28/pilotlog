import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \FlightEntry.date, order: .reverse) private var flights: [FlightEntry]

    private var totalTime: Double { flights.reduce(0) { $0 + $1.totalTime } }
    private var totalPIC: Double { flights.reduce(0) { $0 + $1.picTime } }
    private var totalXC: Double { flights.reduce(0) { $0 + $1.xcTime } }
    private var totalNight: Double { flights.reduce(0) { $0 + $1.nightTime } }

    private var recentFlights: [FlightEntry] { Array(flights.prefix(5)) }

    // Currency: days since last flight with landings
    private var daysSinceLastFlight: Int {
        guard let last = flights.first else { return -1 }
        return Calendar.current.dateComponents([.day], from: last.date, to: .now).day ?? 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Stats pills
                    HStack(spacing: 12) {
                        StatPill(title: "Total", value: String(format: "%.1f", totalTime), unit: "hrs")
                        StatPill(title: "PIC", value: String(format: "%.1f", totalPIC), unit: "hrs")
                        StatPill(title: "XC", value: String(format: "%.1f", totalXC), unit: "hrs")
                        StatPill(title: "Night", value: String(format: "%.1f", totalNight), unit: "hrs")
                    }

                    // Currency status
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Currency Status")
                            .font(.headline)

                        HStack(spacing: 16) {
                            CurrencyRingView(
                                title: "Day VFR",
                                daysRemaining: daysRemainingForCurrency(type: .dayVFR),
                                totalDays: 90,
                                color: .green
                            )
                            CurrencyRingView(
                                title: "Night VFR",
                                daysRemaining: daysRemainingForCurrency(type: .nightVFR),
                                totalDays: 90,
                                color: .blue
                            )
                            CurrencyRingView(
                                title: "IFR",
                                daysRemaining: daysRemainingForCurrency(type: .ifr),
                                totalDays: 180,
                                color: .purple
                            )
                            CurrencyRingView(
                                title: "Flt Review",
                                daysRemaining: daysRemainingForCurrency(type: .flightReview),
                                totalDays: 730,
                                color: .orange
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Recent flights
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Recent Flights")
                                .font(.headline)
                            Spacer()
                            if !flights.isEmpty {
                                NavigationLink("See All") {
                                    LogbookView()
                                }
                                .font(.caption)
                            }
                        }

                        if flights.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "airplane")
                                    .font(.title)
                                    .foregroundStyle(.secondary)
                                Text("No flights yet")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("Scan your logbook or add a flight to get started.")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                        } else {
                            ForEach(recentFlights) { flight in
                                NavigationLink {
                                    FlightDetailView(flight: flight)
                                } label: {
                                    FlightRow(flight: flight)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding()
            }
            .navigationTitle("PilotLog")
        }
    }

    // Simplified currency calculation
    private enum CurrencyType { case dayVFR, nightVFR, ifr, flightReview }

    private func daysRemainingForCurrency(type: CurrencyType) -> Int {
        let calendar = Calendar.current
        let now = Date.now

        switch type {
        case .dayVFR:
            // 3 day landings in last 90 days
            let cutoff = calendar.date(byAdding: .day, value: -90, to: now)!
            let recentWithLandings = flights.filter { $0.date >= cutoff && $0.dayLandings >= 1 }
            let totalLandings = recentWithLandings.reduce(0) { $0 + $1.dayLandings }
            if totalLandings < 3 { return 0 }
            // Find the 3rd most recent landing date to calculate expiry
            if let oldestQualifying = recentWithLandings.last {
                let expiry = calendar.date(byAdding: .day, value: 90, to: oldestQualifying.date)!
                return max(0, calendar.dateComponents([.day], from: now, to: expiry).day ?? 0)
            }
            return 0

        case .nightVFR:
            let cutoff = calendar.date(byAdding: .day, value: -90, to: now)!
            let recentWithLandings = flights.filter { $0.date >= cutoff && $0.nightLandings >= 1 }
            let totalLandings = recentWithLandings.reduce(0) { $0 + $1.nightLandings }
            if totalLandings < 3 { return 0 }
            if let oldestQualifying = recentWithLandings.last {
                let expiry = calendar.date(byAdding: .day, value: 90, to: oldestQualifying.date)!
                return max(0, calendar.dateComponents([.day], from: now, to: expiry).day ?? 0)
            }
            return 0

        case .ifr:
            // 6 approaches in last 6 months (simplified)
            let cutoff = calendar.date(byAdding: .month, value: -6, to: now)!
            let recentIFR = flights.filter { $0.date >= cutoff && $0.approaches >= 1 }
            let totalApproaches = recentIFR.reduce(0) { $0 + $1.approaches }
            if totalApproaches < 6 { return 0 }
            if let oldestQualifying = recentIFR.last {
                let expiry = calendar.date(byAdding: .month, value: 6, to: oldestQualifying.date)!
                return max(0, calendar.dateComponents([.day], from: now, to: expiry).day ?? 0)
            }
            return 0

        case .flightReview:
            // Flight review every 24 months — check remarks for "flight review" or "BFR"
            let reviewFlights = flights.filter {
                $0.remarks.localizedCaseInsensitiveContains("flight review") ||
                $0.remarks.localizedCaseInsensitiveContains("BFR")
            }
            if let lastReview = reviewFlights.first {
                let expiry = calendar.date(byAdding: .month, value: 24, to: lastReview.date)!
                return max(0, calendar.dateComponents([.day], from: now, to: expiry).day ?? 0)
            }
            return 0
        }
    }
}

// MARK: - Subviews

struct StatPill: View {
    let title: String
    let value: String
    let unit: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct FlightRow: View {
    let flight: FlightEntry

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }()

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(Self.dateFormatter.string(from: flight.date))
                        .font(.subheadline.bold())
                    if !flight.aircraftType.isEmpty {
                        Text(flight.aircraftType)
                            .font(.caption2)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(.blue.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
                HStack(spacing: 4) {
                    Text(flight.departure)
                    if !flight.arrival.isEmpty {
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        Text(flight.arrival)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(String(format: "%.1f", flight.totalTime))
                .font(.subheadline.bold().monospacedDigit())
                .foregroundStyle(.blue)
        }
        .padding(.vertical, 4)
    }
}
