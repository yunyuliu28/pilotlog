import UIKit

struct ExportService {

    // MARK: - CSV

    static func generateCSV(from entries: [FlightEntry]) -> String {
        var csv = "Date,Aircraft Type,Ident,From,To,SEL,MEL,PIC,Dual,Day,Night,XC,Actual Inst,Sim Inst,Approaches,Day Ldg,Night Ldg,Total,Remarks\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        for e in entries {
            let fields: [String] = [
                dateFormatter.string(from: e.date),
                e.aircraftType,
                e.aircraftIdent,
                e.departure,
                e.arrival,
                fmt(e.selTime),
                fmt(e.melTime),
                fmt(e.picTime),
                fmt(e.dualTime),
                fmt(e.dayTime),
                fmt(e.nightTime),
                fmt(e.xcTime),
                fmt(e.actualInstrument),
                fmt(e.simInstrument),
                e.approaches > 0 ? "\(e.approaches)" : "",
                e.dayLandings > 0 ? "\(e.dayLandings)" : "",
                e.nightLandings > 0 ? "\(e.nightLandings)" : "",
                fmt(e.totalTime),
                escapeCSV(e.remarks),
            ]
            csv += fields.joined(separator: ",") + "\n"
        }

        return csv
    }

    static func csvFileURL(from entries: [FlightEntry]) -> URL? {
        let csv = generateCSV(from: entries)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("PilotLog_Export.csv")
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    // MARK: - PDF

    static func generatePDF(from entries: [FlightEntry]) -> Data {
        let pageWidth: CGFloat = 792  // landscape letter
        let pageHeight: CGFloat = 612
        let margin: CGFloat = 30
        let rowHeight: CGFloat = 18
        let headerHeight: CGFloat = 22

        let columns: [(title: String, width: CGFloat, keyPath: (FlightEntry) -> String)] = [
            ("Date",   55, { dateStr($0.date) }),
            ("Type",   35, { $0.aircraftType }),
            ("Ident",  45, { $0.aircraftIdent }),
            ("From",   35, { $0.departure }),
            ("To",     35, { $0.arrival }),
            ("SEL",    28, { fmt($0.selTime) }),
            ("MEL",    28, { fmt($0.melTime) }),
            ("PIC",    28, { fmt($0.picTime) }),
            ("Dual",   28, { fmt($0.dualTime) }),
            ("Day",    28, { fmt($0.dayTime) }),
            ("Night",  30, { fmt($0.nightTime) }),
            ("XC",     28, { fmt($0.xcTime) }),
            ("ActI",   28, { fmt($0.actualInstrument) }),
            ("SimI",   28, { fmt($0.simInstrument) }),
            ("App",    25, { $0.approaches > 0 ? "\($0.approaches)" : "" }),
            ("DLdg",   28, { $0.dayLandings > 0 ? "\($0.dayLandings)" : "" }),
            ("NLdg",   28, { $0.nightLandings > 0 ? "\($0.nightLandings)" : "" }),
            ("Total",  30, { fmt($0.totalTime) }),
            ("Remarks",110, { $0.remarks }),
        ]

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let data = renderer.pdfData { context in
            let bodyFont = UIFont.systemFont(ofSize: 8)
            let headerFont = UIFont.boldSystemFont(ofSize: 8)
            let titleFont = UIFont.boldSystemFont(ofSize: 14)

            let rowsPerPage = Int((pageHeight - margin * 2 - 40 - headerHeight) / rowHeight)
            let chunks = stride(from: 0, to: entries.count, by: rowsPerPage).map {
                Array(entries[$0..<min($0 + rowsPerPage, entries.count)])
            }

            for (pageIndex, chunk) in chunks.enumerated() {
                context.beginPage()

                // Title
                let title = "Pilot Logbook — Page \(pageIndex + 1)"
                title.draw(at: CGPoint(x: margin, y: margin),
                           withAttributes: [.font: titleFont, .foregroundColor: UIColor.black])

                var y = margin + 30

                // Column headers
                var x = margin
                for col in columns {
                    col.title.draw(
                        in: CGRect(x: x, y: y, width: col.width, height: headerHeight),
                        withAttributes: [.font: headerFont, .foregroundColor: UIColor.black]
                    )
                    x += col.width
                }

                // Header underline
                y += headerHeight
                let linePath = UIBezierPath()
                linePath.move(to: CGPoint(x: margin, y: y))
                linePath.addLine(to: CGPoint(x: pageWidth - margin, y: y))
                UIColor.gray.setStroke()
                linePath.lineWidth = 0.5
                linePath.stroke()
                y += 2

                // Data rows
                for entry in chunk {
                    x = margin
                    for col in columns {
                        let value = col.keyPath(entry)
                        value.draw(
                            in: CGRect(x: x, y: y, width: col.width, height: rowHeight),
                            withAttributes: [.font: bodyFont, .foregroundColor: UIColor.darkGray]
                        )
                        x += col.width
                    }
                    y += rowHeight
                }
            }
        }

        return data
    }

    static func pdfFileURL(from entries: [FlightEntry]) -> URL? {
        let data = generatePDF(from: entries)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("PilotLog_Export.pdf")
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    // MARK: - Helpers

    private static func fmt(_ value: Double) -> String {
        value > 0 ? String(format: "%.1f", value) : ""
    }

    private static let sharedDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MM/dd/yy"
        return f
    }()

    private static func dateStr(_ date: Date) -> String {
        sharedDateFormatter.string(from: date)
    }

    private static func escapeCSV(_ text: String) -> String {
        if text.contains(",") || text.contains("\"") || text.contains("\n") {
            return "\"" + text.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return text
    }
}
