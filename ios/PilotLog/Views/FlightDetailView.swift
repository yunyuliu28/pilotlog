import SwiftUI
import SwiftData

struct FlightDetailView: View {
    @Bindable var flight: FlightEntry
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    @State private var isEditing = false

    private static let dateFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        return f
    }()

    var body: some View {
        List {
            if isEditing {
                editView
            } else {
                readView
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation { isEditing.toggle() }
                }
            }
        }
        .confirmationDialog("Delete this flight?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                modelContext.delete(flight)
                dismiss()
            }
        }
    }

    // MARK: - Read View

    @ViewBuilder
    private var readView: some View {
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

        // Time
        Section("Time") {
            ReadRow(label: "Total", value: flight.totalTime)
            ReadRow(label: "PIC", value: flight.picTime)
            ReadRow(label: "Dual Received", value: flight.dualTime)
            ReadRow(label: "SEL", value: flight.selTime)
            ReadRow(label: "MEL", value: flight.melTime)
            ReadRow(label: "Day", value: flight.dayTime)
            ReadRow(label: "Night", value: flight.nightTime)
            ReadRow(label: "Cross-Country", value: flight.xcTime)
        }

        // Instrument
        Section("Instrument") {
            ReadRow(label: "Actual", value: flight.actualInstrument)
            ReadRow(label: "Simulated", value: flight.simInstrument)
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
    }

    // MARK: - Edit View

    @ViewBuilder
    private var editView: some View {
        Section("Flight Info") {
            DatePicker("Date", selection: $flight.date, displayedComponents: .date)
            EditRow(label: "Aircraft Type", text: $flight.aircraftType)
            EditRow(label: "Ident", text: $flight.aircraftIdent)
            EditRow(label: "From", text: $flight.departure)
            EditRow(label: "To", text: $flight.arrival)
        }

        Section("Time") {
            NumericRow(label: "Total", value: $flight.totalTime)
            NumericRow(label: "PIC", value: $flight.picTime)
            NumericRow(label: "Dual Received", value: $flight.dualTime)
            NumericRow(label: "SEL", value: $flight.selTime)
            NumericRow(label: "MEL", value: $flight.melTime)
            NumericRow(label: "Day", value: $flight.dayTime)
            NumericRow(label: "Night", value: $flight.nightTime)
            NumericRow(label: "Cross-Country", value: $flight.xcTime)
        }

        Section("Instrument") {
            NumericRow(label: "Actual", value: $flight.actualInstrument)
            NumericRow(label: "Simulated", value: $flight.simInstrument)
            IntRow(label: "Approaches", value: $flight.approaches)
        }

        Section("Landings") {
            IntRow(label: "Day", value: $flight.dayLandings)
            IntRow(label: "Night", value: $flight.nightLandings)
        }

        Section("Remarks") {
            TextField("Remarks", text: $flight.remarks, axis: .vertical)
                .lineLimit(3...6)
        }
    }
}

// MARK: - Subviews

private struct ReadRow: View {
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

private struct EditRow: View {
    let label: String
    @Binding var text: String

    var body: some View {
        HStack {
            Text(label)
                .frame(width: 100, alignment: .leading)
            TextField(label, text: $text)
                .multilineTextAlignment(.trailing)
        }
    }
}

private struct NumericRow: View {
    let label: String
    @Binding var value: Double
    @State private var text: String = ""

    var body: some View {
        HStack {
            Text(label)
                .frame(width: 100, alignment: .leading)
            TextField("0.0", text: $text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .onChange(of: text) { _, newValue in
                    value = Double(newValue) ?? 0
                }
        }
        .onAppear {
            text = value > 0 ? String(format: "%.1f", value) : ""
        }
    }
}

private struct IntRow: View {
    let label: String
    @Binding var value: Int
    @State private var text: String = ""

    var body: some View {
        HStack {
            Text(label)
                .frame(width: 100, alignment: .leading)
            TextField("0", text: $text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .onChange(of: text) { _, newValue in
                    value = Int(newValue) ?? 0
                }
        }
        .onAppear {
            text = value > 0 ? "\(value)" : ""
        }
    }
}
