import SwiftUI
import SwiftData

struct FlightDetailView: View {
    @Bindable var flight: FlightEntry
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false

    private static let dateFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        return f
    }()

    var body: some View {
        List {
            // Header
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(Self.dateFmt.string(from: flight.date))
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.1f hrs", flight.totalTime))
                            .font(.title3.bold())
                            .foregroundStyle(.blue)
                    }
                    HStack(spacing: 8) {
                        if !flight.aircraftType.isEmpty {
                            Label(flight.aircraftType, systemImage: "airplane")
                        }
                        if !flight.aircraftIdent.isEmpty {
                            Text(flight.aircraftIdent)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .font(.subheadline)

                    if !flight.departure.isEmpty || !flight.arrival.isEmpty {
                        HStack(spacing: 6) {
                            Text(flight.departure)
                                .font(.title3.bold())
                            Image(systemName: "arrow.right")
                                .foregroundStyle(.secondary)
                            Text(flight.arrival)
                                .font(.title3.bold())
                        }
                    }
                }
            }

            // Time breakdown
            Section("Time") {
                DetailRow(label: "Total", value: flight.totalTime)
                DetailRow(label: "PIC", value: flight.picTime)
                DetailRow(label: "Dual Received", value: flight.dualTime)
                DetailRow(label: "SEL", value: flight.selTime)
                DetailRow(label: "MEL", value: flight.melTime)
                DetailRow(label: "Day", value: flight.dayTime)
                DetailRow(label: "Night", value: flight.nightTime)
                DetailRow(label: "Cross-Country", value: flight.xcTime)
            }

            // Instrument
            Section("Instrument") {
                DetailRow(label: "Actual", value: flight.actualInstrument)
                DetailRow(label: "Simulated", value: flight.simInstrument)
                if flight.approaches > 0 {
                    HStack {
                        Text("Approaches")
                        Spacer()
                        Text("\(flight.approaches)")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Landings
            if flight.dayLandings > 0 || flight.nightLandings > 0 {
                Section("Landings") {
                    if flight.dayLandings > 0 {
                        HStack {
                            Text("Day")
                            Spacer()
                            Text("\(flight.dayLandings)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    if flight.nightLandings > 0 {
                        HStack {
                            Text("Night")
                            Spacer()
                            Text("\(flight.nightLandings)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            // Remarks
            if !flight.remarks.isEmpty {
                Section("Remarks") {
                    Text(flight.remarks)
                        .font(.subheadline)
                }
            }

            // Scanned source image
            if let imageData = flight.sourceImageData, let uiImage = UIImage(data: imageData) {
                Section("Scanned Source") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            // Delete
            Section {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete Flight", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Flight Details")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Delete this flight?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                modelContext.delete(flight)
                dismiss()
            }
        }
    }
}

private struct DetailRow: View {
    let label: String
    let value: Double

    var body: some View {
        if value > 0 {
            HStack {
                Text(label)
                Spacer()
                Text(String(format: "%.1f", value))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }
}
