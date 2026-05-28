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
    var isCompact: Bool = false
    @Query(sort: \FlightEntry.date, order: .reverse) private var flights: [FlightEntry]
    @State private var searchText = ""
    @State private var showingAddFlight = false
    @State private var showingSearch = false
    @State private var showExportSheet = false
    @State private var exportURL: URL?
    @State private var isExporting = false
    @State private var showProfile = false
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
                    VStack(spacing: 0) {
                        if !isCompact {
                            Spacer().frame(height: 8)

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
                                .padding(.horizontal, 16)
                            }

                            if selectedFilter == .custom {
                                HStack {
                                    DatePicker("From", selection: $customStartDate, displayedComponents: .date)
                                        .font(.caption)
                                    DatePicker("To", selection: $customEndDate, displayedComponents: .date)
                                        .font(.caption)
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
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
                                    Label("Export", systemImage: "square.and.arrow.up")
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color(.systemGray))
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        }

                        // Search bar
                        if showingSearch {
                            HStack(spacing: 8) {
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
                            .font(.system(size: 16))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.systemBackground))
                            .clipShape(Capsule())
                            .padding(.horizontal, 8)
                            .padding(.top, 16)
                        }

                        // Flight rows
                        List {
                            ForEach(filtered) { flight in
                                ZStack(alignment: .leading) {
                                    NavigationLink(destination: FlightDetailView(flight: flight)) {
                                        EmptyView()
                                    }
                                    .opacity(0)

                                    LogbookRow(flight: flight)
                                }
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            }
                            .onDelete(perform: deleteFlights)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .padding(.top, 16)
                    }
                }
            }
            .background(Color(.systemGray6))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showProfile = true } label: {
                        Image(systemName: "person.circle")
                            .font(.title3)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Logbook")
                        .font(.title3.bold())
                }
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 16) {
                        Button {
                            withAnimation { showingSearch.toggle() }
                            if !showingSearch { searchText = "" }
                        } label: {
                            Image(systemName: "magnifyingglass")
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
            .sheet(isPresented: $showProfile) {
                NavigationStack {
                    ProfileView()
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") { showProfile = false }
                            }
                        }
                }
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
                .font(.system(size: 14))
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

    private var hours: Int { Int(flight.totalTime) }
    private var minutes: Int { Int((flight.totalTime - Double(hours)) * 60) }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Left — total flight time
            VStack(alignment: .leading, spacing: 0) {
                Text("\(hours)h")
                    .font(.system(size: 30, weight: .semibold).monospacedDigit())
                    .foregroundStyle(.primary.opacity(0.8))
                Text(minutes > 0 ? "\(minutes)min" : " ")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .padding(.top, -2)
            }
            .frame(width: 55, alignment: .leading)
            .offset(y: -2)

            // Middle — date + aircraft
            VStack(alignment: .leading, spacing: 6) {
                Text(Self.dateFmt.string(from: flight.date))
                    .font(.system(size: 20).monospacedDigit())

                HStack(spacing: 6) {
                    if !flight.aircraftType.isEmpty {
                        Text(flight.aircraftType)
                            .font(.system(size: 14, weight: .bold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(.blue.opacity(0.15))
                            .clipShape(Capsule())
                    }

                    if !flight.aircraftIdent.isEmpty {
                        Text(flight.aircraftIdent)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Right — departure & destination
            VStack(alignment: .trailing, spacing: 8) {
                HStack(spacing: 4) {
                    Text("from")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    Text(flight.departure)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)
                }
                HStack(spacing: 4) {
                    Text("to")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                    Text(flight.arrival)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

