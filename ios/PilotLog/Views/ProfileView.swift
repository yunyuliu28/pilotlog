import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query(sort: \FlightEntry.date, order: .reverse) private var flights: [FlightEntry]
    @AppStorage("anthropicAPIKey") private var apiKey = ""

    // Computed stats
    private var totalTime: Double { flights.reduce(0) { $0 + $1.totalTime } }
    private var totalPIC: Double { flights.reduce(0) { $0 + $1.picTime } }
    private var totalXC: Double { flights.reduce(0) { $0 + $1.xcTime } }
    private var totalNight: Double { flights.reduce(0) { $0 + $1.nightTime } }
    private var totalDual: Double { flights.reduce(0) { $0 + $1.dualTime } }
    private var totalInstrument: Double { flights.reduce(0) { $0 + $1.actualInstrument + $1.simInstrument } }
    private var totalLandings: Int { flights.reduce(0) { $0 + $1.dayLandings + $1.nightLandings } }

    private var uniqueAircraft: Int {
        Set(flights.map { $0.aircraftIdent }).subtracting([""]).count
    }

    var body: some View {
        NavigationStack {
            List {
                // Career stats
                Section {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ], spacing: 0) {
                        ProfileStat(value: String(format: "%.1f", totalTime), label: "Total Hours")
                        ProfileStat(value: String(format: "%.1f", totalPIC), label: "PIC")
                        ProfileStat(value: String(format: "%.1f", totalXC), label: "Cross-Country")
                        ProfileStat(value: String(format: "%.1f", totalNight), label: "Night")
                        ProfileStat(value: String(format: "%.1f", totalInstrument), label: "Instrument")
                        ProfileStat(value: "\(totalLandings)", label: "Landings")
                        ProfileStat(value: "\(flights.count)", label: "Flights")
                        ProfileStat(value: "\(uniqueAircraft)", label: "Aircraft")
                        ProfileStat(value: String(format: "%.1f", totalDual), label: "Dual")
                    }
                } header: {
                    Text("Career Stats")
                }

                // AI Scanning
                Section {
                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundStyle(.blue)
                        SecureField("Anthropic API Key", text: $apiKey)
                            .textContentType(.password)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                } header: {
                    Text("AI Scanning")
                } footer: {
                    Text(apiKey.isEmpty
                         ? "Add your Anthropic API key to enable Claude-powered scanning for better accuracy with handwritten logbooks."
                         : "Claude Vision is active. Scans will use AI for extraction.")
                }

                // Info
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Flights Logged")
                        Spacer()
                        Text("\(flights.count)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.title3.bold())
                }
            }
        }
    }
}

// MARK: - Subviews

private struct ProfileStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 24, weight: .semibold).monospacedDigit())
                .foregroundStyle(.primary.opacity(0.8))
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

// Simple share sheet wrapper
struct ShareSheetView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
