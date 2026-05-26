import SwiftUI

struct ScanReviewView: View {
    @Binding var flights: [ParsedFlight]
    var onSave: () -> Void
    var onDiscard: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Review Entries")
                            .font(.title2.bold())
                        Text("Found \(flights.count) flight\(flights.count == 1 ? "" : "s") — edit before saving")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding()

                // Flight cards
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(flights.indices, id: \.self) { index in
                            ParsedFlightCard(flight: $flights[index], index: index + 1)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
                .scrollDismissesKeyboard(.interactively)
            }

            // Action buttons — pinned to screen bottom, don't move with keyboard
            VStack(spacing: 10) {
                Button(action: onSave) {
                    Label("Save \(flights.count) Flight\(flights.count == 1 ? "" : "s")", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .font(.headline)
                }

                Button(action: onDiscard) {
                    Text("Discard")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(.red)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

struct ParsedFlightCard: View {
    @Binding var flight: ParsedFlight
    let index: Int
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Summary row
            HStack {
                Text("#\(index)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(flight.date.isEmpty ? "No date" : flight.date)
                            .font(.subheadline.bold())
                        if !flight.aircraftType.isEmpty {
                            Text(flight.aircraftType)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.blue.opacity(0.2))
                                .clipShape(Capsule())
                        }
                        if !flight.aircraftIdent.isEmpty {
                            Text(flight.aircraftIdent)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    if !flight.departure.isEmpty || !flight.arrival.isEmpty {
                        HStack(spacing: 4) {
                            Text(flight.departure)
                            Image(systemName: "arrow.right")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(flight.arrival)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if !flight.totalTime.isEmpty {
                    Text("\(flight.totalTime) hrs")
                        .font(.subheadline.bold())
                        .foregroundStyle(.blue)
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }

            // Expanded edit fields
            if isExpanded {
                Divider()

                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ], spacing: 8) {
                    DateEditField(value: $flight.date)
                    EditField(label: "Aircraft", value: $flight.aircraftType)
                    EditField(label: "Ident", value: $flight.aircraftIdent)
                    EditField(label: "From", value: $flight.departure)
                    EditField(label: "To", value: $flight.arrival)
                    EditField(label: "Total", value: $flight.totalTime)
                    EditField(label: "PIC", value: $flight.picTime)
                    EditField(label: "Dual", value: $flight.dualTime)
                    EditField(label: "SEL", value: $flight.selTime)
                    EditField(label: "MEL", value: $flight.melTime)
                    EditField(label: "Day", value: $flight.dayTime)
                    EditField(label: "Night", value: $flight.nightTime)
                    EditField(label: "XC", value: $flight.xcTime)
                    EditField(label: "Act Inst", value: $flight.actualInstrument)
                    EditField(label: "Sim Inst", value: $flight.simInstrument)
                    EditField(label: "Appr", value: $flight.approaches)
                    EditField(label: "Day Ldg", value: $flight.dayLandings)
                    EditField(label: "Night Ldg", value: $flight.nightLandings)
                }

                EditField(label: "Remarks", value: $flight.remarks)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Date Picker Field

private struct DateEditField: View {
    @Binding var value: String
    @State private var showPicker = false
    @State private var selectedDate = Date()

    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M/d/yy"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Date")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Button {
                selectedDate = Self.parseDate(from: value) ?? Date()
                showPicker = true
            } label: {
                HStack {
                    Text(value.isEmpty ? "Date" : value)
                        .font(.caption)
                        .foregroundStyle(value.isEmpty ? .tertiary : .primary)
                    Spacer()
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .sheet(isPresented: $showPicker) {
            NavigationStack {
                DatePicker("Flight Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                    .navigationTitle("Flight Date")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                value = Self.displayFormatter.string(from: selectedDate)
                                showPicker = false
                            }
                            .fontWeight(.semibold)
                        }
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") {
                                showPicker = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
    }

    private static func parseDate(from string: String) -> Date? {
        let formats = ["M/d/yy", "M/d/yyyy", "M/d", "MM/dd/yy", "MM/dd/yyyy", "yyyy-MM-dd"]
        for format in formats {
            let f = DateFormatter()
            f.dateFormat = format
            if let date = f.date(from: string) { return date }
        }
        return nil
    }
}

// MARK: - Text Edit Field

private struct EditField: View {
    let label: String
    @Binding var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            TextField(label, text: $value)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}
