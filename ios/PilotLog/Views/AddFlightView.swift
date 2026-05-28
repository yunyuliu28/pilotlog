import SwiftUI
import SwiftData

struct AddFlightView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date.now
    @State private var aircraftType = ""
    @State private var aircraftIdent = ""
    @State private var departure = ""
    @State private var arrival = ""

    // Time fields
    @State private var selTime = ""
    @State private var melTime = ""
    @State private var picTime = ""
    @State private var dualTime = ""
    @State private var dayTime = ""
    @State private var nightTime = ""
    @State private var xcTime = ""
    @State private var actualInstrument = ""
    @State private var simInstrument = ""

    // Counts
    @State private var approaches = 0
    @State private var dayLandings = 0
    @State private var nightLandings = 0

    @State private var totalTime = ""
    @State private var remarks = ""

    // Category
    @State private var engineCategory = 0 // 0 = SEL, 1 = MEL

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Aircraft category
                Picker("", selection: $engineCategory) {
                    Text("Single-Engine Land").tag(0)
                    Text("Multi-Engine Land").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(Color(.systemGroupedBackground))

                Form {
                // Flight info
                Section("Flight Info") {
                    HStack {
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .labelsHidden()
                        Spacer()
                    }
                    HStack {
                        TextField("Aircraft Type", text: $aircraftType)
                            .textInputAutocapitalization(.characters)
                        TextField("Tail Number", text: $aircraftIdent)
                            .textInputAutocapitalization(.characters)
                    }
                    HStack {
                        TextField("Departure", text: $departure)
                            .textInputAutocapitalization(.characters)
                        TextField("Destination", text: $arrival)
                            .textInputAutocapitalization(.characters)
                    }
                }

                // Time
                Section("Flight Time") {
                    TimeRow(label: "Total Time", value: $totalTime)
                    TimeRow(label: "PIC", value: $picTime)
                    TimeRow(label: "Dual Received", value: $dualTime)
                    TimeRow(label: "Day", value: $dayTime)
                    TimeRow(label: "Night", value: $nightTime)
                    TimeRow(label: "Cross-Country", value: $xcTime)
                }

                // Instrument
                Section("Instrument") {
                    TimeRow(label: "Actual Instrument", value: $actualInstrument)
                    TimeRow(label: "Simulated Instrument", value: $simInstrument)
                    Stepper("Approaches: \(approaches)", value: $approaches, in: 0...20)
                }

                // Landings
                Section("Landings") {
                    Stepper("Day Landings: \(dayLandings)", value: $dayLandings, in: 0...50)
                    Stepper("Night Landings: \(nightLandings)", value: $nightLandings, in: 0...50)
                }

                // Remarks
                Section("Remarks") {
                    TextField("Maneuvers, notes, endorsements...", text: $remarks, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            }
            .navigationTitle("Add Flight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveFlight()
                        dismiss()
                    }
                    .bold()
                    .disabled(totalTime.isEmpty)
                }
            }
        }
    }

    private func saveFlight() {
        let total = Double(totalTime) ?? 0
        let entry = FlightEntry(
            date: date,
            aircraftType: aircraftType.uppercased(),
            aircraftIdent: aircraftIdent.uppercased(),
            departure: departure.uppercased(),
            arrival: arrival.uppercased(),
            selTime: engineCategory == 0 ? total : 0,
            melTime: engineCategory == 1 ? total : 0,
            picTime: Double(picTime) ?? 0,
            dualTime: Double(dualTime) ?? 0,
            dayTime: Double(dayTime) ?? 0,
            nightTime: Double(nightTime) ?? 0,
            xcTime: Double(xcTime) ?? 0,
            actualInstrument: Double(actualInstrument) ?? 0,
            simInstrument: Double(simInstrument) ?? 0,
            approaches: approaches,
            dayLandings: dayLandings,
            nightLandings: nightLandings,
            totalTime: total,
            remarks: remarks
        )
        modelContext.insert(entry)
    }
}

private struct TimeRow: View {
    let label: String
    @Binding var value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0.0", text: $value)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 60)
        }
    }
}
