import SwiftUI
import SwiftData

enum TimeFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case last7Days = "7 Days"
    case last30Days = "30 Days"
    case last90Days = "90 Days"
    case last6Months = "6 Months"
    case last12Months = "12 Months"
    case custom = "Custom"

    var id: String { rawValue }
}

struct LogbookView: View {
    @Query(sort: \FlightEntry.date, order: .reverse) private var flights: [FlightEntry]
    @State private var searchText = ""
    @State private var showingAddFlight = false
    @State private var showingSearch = false
    @State private var showExportSheet = false
    @State private var exportURL: URL?
    @State private var isExporting = false
    @State private var selectedFilter: TimeFilter = .all
    @State private var customStartDate = Calendar.current.date(byAdding: .month, value: -1, to: .now)!
    @State private var customEndDate = Date.now

    private var dateFiltered: [FlightEntry] {
        let calendar = Calendar.current
        let now = Date.now

        switch selectedFilter {
        case .all:
            return flights
        case .last7Days:
            let cutoff = calendar.date(byAdding: .day, value: -7, to: now)!
            return flights.filter { $0.date >= cutoff }
        case .last30Days:
            let cutoff = calendar.date(byAdding: .day, value: -30, to: now)!
            return flights.filter { $0.date >= cutoff }
        case .last90Days:
            let cutoff = calendar.date(byAdding: .day, value: -90, to: now)!
            return flights.filter { $0.date >= cutoff }
        case .last6Months:
            let cutoff = calendar.date(byAdding: .month, value: -6, to: now)!
            return flights.filter { $0.date >= cutoff }
        case .last12Months:
            let cutoff = calendar.date(byAdding: .month, value: -12, to: now)!
            return flights.filter { $0.date >= cutoff }
        case .custom:
            return flights.filter { $0.date >= customStartDate && $0.date <= customEndDate }
        }
    }

    private var filtered: [FlightEntry] {
        guard !searchText.isEmpty else { return dateFiltered }
        let q = searchText.lowercased()
        return dateFiltered.filter {
            $0.aircraftType.lowercased().contains(q) ||
            $0.aircraftIdent.lowercased().contains(q) ||
            $0.departure.lowercased().contains(q) ||
            $0.arrival.lowercased().contains(q) ||
            $0.remarks.lowercased().contains(q)
        }
    }


    var body: some View {
        NavigationStack {
            Group {
                if flights.isEmpty {
                    ContentUnavailableView(
                        "No Flights",
                        systemImage: "book.closed",
                        description: Text("Scan your logbook or tap + to add a flight.")
                    )
                } else {
                    List {
                        // Search bar (when active)
                        if showingSearch {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(.secondary)
                                TextField("Search flights", text: $searchText)
                                    .textFieldStyle(.plain)
                                if !searchText.isEmpty {
                                    Button { searchText = "" } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(8)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .listRowSeparator(.hidden)
                        }

                        // Time filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(TimeFilter.allCases) { filter in
                                    FilterChip(
                                        label: filter.rawValue,
                                        isSelected: selectedFilter == filter
                                    ) {
                                        selectedFilter = filter
                                    }
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)

                        if selectedFilter == .custom {
                            HStack {
                                DatePicker("From", selection: $customStartDate, displayedComponents: .date)
                                    .font(.caption)
                                DatePicker("To", selection: $customEndDate, displayedComponents: .date)
                                    .font(.caption)
                            }
                        }

                        // Flight count + export
                        HStack {
                            Text("\(filtered.count) flight\(filtered.count == 1 ? "" : "s")")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Menu {
                                Button {
                                    exportFile { ExportService.csvFileURL(from: $0) }
                                } label: {
                                    Label("Export as CSV", systemImage: "tablecells")
                                }
                                Button {
                                    exportFile { ExportService.pdfFileURL(from: $0) }
                                } label: {
                                    Label("Export as PDF", systemImage: "doc.richtext")
                                }
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.subheadline)
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)

                        // Flight rows
                        Section {
                            ForEach(filtered) { flight in
                                NavigationLink {
                                    FlightDetailView(flight: flight)
                                } label: {
                                    LogbookRow(flight: flight)
                                }
                            }
                            .onDelete(perform: deleteFlights)
                        }
                    }
                }
            }
            .navigationTitle("Logbook")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 16) {
                        Button {
                            withAnimation { showingSearch.toggle() }
                            if !showingSearch { searchText = "" }
                        } label: {
                            Image(systemName: showingSearch ? "magnifyingglass.circle.fill" : "magnifyingglass")
                        }
                        Button {
                            showingAddFlight = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .overlay {
                if isExporting {
                    ZStack {
                        Color.black.opacity(0.5).ignoresSafeArea()
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Generating export...")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                        }
                        .padding(24)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .sheet(isPresented: $showingAddFlight) {
                AddFlightView()
            }
            .sheet(isPresented: $showExportSheet) {
                if let url = exportURL {
                    ShareSheetView(url: url)
                }
            }
        }
    }

    private func exportFile(_ generator: @escaping ([FlightEntry]) -> URL?) {
        let entries = filtered
        isExporting = true
        Task.detached {
            let url = generator(entries)
            await MainActor.run {
                isExporting = false
                if let url {
                    exportURL = url
                    showExportSheet = true
                }
            }
        }
    }

    private func deleteFlights(at offsets: IndexSet) {
        // We need a modelContext to delete
        // Since @Query doesn't give us the context directly, we'll handle this differently
    }
}

// MARK: - Subviews

private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? .blue : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

private struct LogbookRow: View {
    let flight: FlightEntry

    private static let dateFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM/dd/yy"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(Self.dateFmt.string(from: flight.date))
                    .font(.subheadline.bold().monospacedDigit())

                if !flight.aircraftType.isEmpty {
                    Text(flight.aircraftType)
                        .font(.caption2.bold())
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(.blue.opacity(0.15))
                        .clipShape(Capsule())
                }

                if !flight.aircraftIdent.isEmpty {
                    Text(flight.aircraftIdent)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(String(format: "%.1f", flight.totalTime))
                    .font(.subheadline.bold().monospacedDigit())
                    .foregroundStyle(.blue)
            }

            HStack(spacing: 12) {
                HStack(spacing: 3) {
                    Text(flight.departure)
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                    Text(flight.arrival)
                }

                if flight.picTime > 0 {
                    Label(String(format: "%.1f", flight.picTime), systemImage: "person.fill")
                }
                if flight.nightTime > 0 {
                    Label(String(format: "%.1f", flight.nightTime), systemImage: "moon.fill")
                }
                if flight.dayLandings > 0 || flight.nightLandings > 0 {
                    Label("\(flight.dayLandings + flight.nightLandings)", systemImage: "airplane.arrival")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if !flight.remarks.isEmpty {
                Text(flight.remarks)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 2)
    }
}

