import Foundation
import SwiftData

@Model
final class FlightEntry {
    var date: Date
    var aircraftType: String
    var aircraftIdent: String
    var departure: String
    var arrival: String

    // Time categories (hours, decimal)
    var selTime: Double
    var melTime: Double
    var picTime: Double
    var dualTime: Double
    var dayTime: Double
    var nightTime: Double
    var xcTime: Double
    var actualInstrument: Double
    var simInstrument: Double

    // Counts
    var approaches: Int
    var dayLandings: Int
    var nightLandings: Int

    var totalTime: Double
    var remarks: String

    // Metadata
    var createdAt: Date
    var sourceImageData: Data?

    init(
        date: Date = .now,
        aircraftType: String = "",
        aircraftIdent: String = "",
        departure: String = "",
        arrival: String = "",
        selTime: Double = 0,
        melTime: Double = 0,
        picTime: Double = 0,
        dualTime: Double = 0,
        dayTime: Double = 0,
        nightTime: Double = 0,
        xcTime: Double = 0,
        actualInstrument: Double = 0,
        simInstrument: Double = 0,
        approaches: Int = 0,
        dayLandings: Int = 0,
        nightLandings: Int = 0,
        totalTime: Double = 0,
        remarks: String = "",
        createdAt: Date = .now,
        sourceImageData: Data? = nil
    ) {
        self.date = date
        self.aircraftType = aircraftType
        self.aircraftIdent = aircraftIdent
        self.departure = departure
        self.arrival = arrival
        self.selTime = selTime
        self.melTime = melTime
        self.picTime = picTime
        self.dualTime = dualTime
        self.dayTime = dayTime
        self.nightTime = nightTime
        self.xcTime = xcTime
        self.actualInstrument = actualInstrument
        self.simInstrument = simInstrument
        self.approaches = approaches
        self.dayLandings = dayLandings
        self.nightLandings = nightLandings
        self.totalTime = totalTime
        self.remarks = remarks
        self.createdAt = createdAt
        self.sourceImageData = sourceImageData
    }
}

// Parsed flight from OCR — not yet saved, all strings for easy editing
struct ParsedFlight: Identifiable, Decodable {
    let id = UUID()

    private enum CodingKeys: String, CodingKey {
        case date, aircraftType, aircraftIdent, departure, arrival
        case selTime, melTime, picTime, dualTime, dayTime, nightTime
        case xcTime, actualInstrument, simInstrument, approaches
        case dayLandings, nightLandings, totalTime, remarks
    }
    var date: String
    var aircraftType: String
    var aircraftIdent: String
    var departure: String
    var arrival: String
    var selTime: String
    var melTime: String
    var picTime: String
    var dualTime: String
    var dayTime: String
    var nightTime: String
    var xcTime: String
    var actualInstrument: String
    var simInstrument: String
    var approaches: String
    var dayLandings: String
    var nightLandings: String
    var totalTime: String
    var remarks: String

    func toFlightEntry() -> FlightEntry {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        let parsedDate = dateFormatter.date(from: date)
            ?? DateFormatter().date(from: date)
            ?? .now

        return FlightEntry(
            date: parsedDate,
            aircraftType: aircraftType,
            aircraftIdent: aircraftIdent,
            departure: departure,
            arrival: arrival,
            selTime: Double(selTime) ?? 0,
            melTime: Double(melTime) ?? 0,
            picTime: Double(picTime) ?? 0,
            dualTime: Double(dualTime) ?? 0,
            dayTime: Double(dayTime) ?? 0,
            nightTime: Double(nightTime) ?? 0,
            xcTime: Double(xcTime) ?? 0,
            actualInstrument: Double(actualInstrument) ?? 0,
            simInstrument: Double(simInstrument) ?? 0,
            approaches: Int(approaches) ?? 0,
            dayLandings: Int(dayLandings) ?? 0,
            nightLandings: Int(nightLandings) ?? 0,
            totalTime: Double(totalTime) ?? 0,
            remarks: remarks
        )
    }
}
