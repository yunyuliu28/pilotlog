import Vision
import UIKit

actor OCRService {

    // Known logbook column headers for fuzzy matching
    // Longer keywords win, so compound keywords (e.g. "aircraft ident") must outrank
    // generic ones (e.g. "aircraft") to avoid column collisions.
    private static let columnPatterns: [(field: String, keywords: [String])] = [
        ("date",            ["date"]),
        ("aircraftType",    ["make & model", "make/model", "aircraft make", "aircraft", "make", "model", "type", "a/c type", "a/c"]),
        ("aircraftIdent",   ["aircraft ident", "ident", "tail", "reg", "n-number", "registration"]),
        ("departure",       ["from", "dep", "departure", "origin"]),
        ("arrival",         ["to", "arr", "arrival", "dest", "destination", "route"]),
        ("selTime",         ["airplane sel", "sel", "single", "se"]),
        ("melTime",         ["airplane mel", "mel", "multi", "me"]),
        ("picTime",         ["pilot-in-command", "pilot in command", "pilot-in", "pic"]),
        ("dualTime",        ["dual received", "dual", "instruction", "received"]),
        ("dayTime",         ["day"]),
        ("nightTime",       ["night"]),
        ("xcTime",          ["cross-country", "cross country", "xc", "cross", "x-c"]),
        ("actualInstrument",["actual instr", "actual inst", "actual"]),
        ("simInstrument",   ["simulated instr", "simulated inst", "simulated", "sim", "hood"]),
        ("groundTrainer",   ["ground trainer", "ground", "trainer", "ftd", "atd"]),
        ("approaches",      ["instr. appr", "instr appr", "appr", "approach", "iap"]),
        ("dayLandings",     ["day ldg", "ldg", "land", "dl"]),
        ("nightLandings",   ["night ldg", "nl", "night land"]),
        ("totalTime",       ["total duration", "duration of flight", "duration", "total", "ttl"]),
        ("remarks",         ["remarks", "procedures", "maneuvers", "comments", "notes"]),
    ]

    private static let timeFields: Set<String> = [
        "selTime", "melTime", "picTime", "dualTime", "dayTime", "nightTime",
        "xcTime", "actualInstrument", "simInstrument", "totalTime", "groundTrainer"
    ]

    struct TextObservation {
        let text: String
        let boundingBox: CGRect // normalized coordinates (0-1)
    }

    // MARK: - Public API

    func extractFlights(from image: UIImage) async throws -> [ParsedFlight] {
        let observations = try await recognizeText(in: image)

        guard !observations.isEmpty else { return [] }

        let rows = groupIntoRows(observations)

        guard rows.count >= 2 else { return [] }

        // Find the header row (the one with the most column keyword matches)
        let headerIndex = findHeaderRow(in: rows)
        let headerRow = rows[headerIndex]
        let columnMapping = mapColumns(from: headerRow)
        let dataRows = Array(rows.dropFirst(headerIndex + 1))

        let flights = dataRows.compactMap { row -> ParsedFlight? in
            parseFlight(from: row, columnMapping: columnMapping)
        }

        return flights
    }

    // Find the row with the most column keyword matches — that's the real header
    private func findHeaderRow(in rows: [[TextObservation]]) -> Int {
        var bestIndex = 0
        var bestScore = 0

        let checkCount = min(rows.count, 6)

        for i in 0..<checkCount {
            var score = 0
            for obs in rows[i] {
                let text = obs.text.lowercased()
                for (_, keywords) in Self.columnPatterns {
                    if keywords.contains(where: { text.contains($0) }) {
                        score += 1
                        break
                    }
                }
            }
            if score > bestScore {
                bestScore = score
                bestIndex = i
            }
        }

        return bestIndex
    }

    // MARK: - OCR

    private func recognizeText(in image: UIImage) async throws -> [TextObservation] {
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let results = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }

                let observations = results.compactMap { observation -> TextObservation? in
                    guard let candidate = observation.topCandidates(1).first else { return nil }
                    return TextObservation(
                        text: candidate.string,
                        boundingBox: observation.boundingBox
                    )
                }

                continuation.resume(returning: observations)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Row grouping

    // Group text observations into rows by clustering Y-coordinates
    private func groupIntoRows(_ observations: [TextObservation]) -> [[TextObservation]] {
        guard !observations.isEmpty else { return [] }

        // VisionKit uses bottom-left origin, so higher Y = higher on page
        let sorted = observations.sorted { $0.boundingBox.midY > $1.boundingBox.midY }

        var rows: [[TextObservation]] = []
        var currentRow: [TextObservation] = [sorted[0]]
        var currentY = sorted[0].boundingBox.midY

        let yThreshold: CGFloat = 0.012 // ~1.2% of image height

        for obs in sorted.dropFirst() {
            if abs(obs.boundingBox.midY - currentY) < yThreshold {
                currentRow.append(obs)
            } else {
                // Sort current row left-to-right
                rows.append(currentRow.sorted { $0.boundingBox.midX < $1.boundingBox.midX })
                currentRow = [obs]
                currentY = obs.boundingBox.midY
            }
        }
        if !currentRow.isEmpty {
            rows.append(currentRow.sorted { $0.boundingBox.midX < $1.boundingBox.midX })
        }

        return rows
    }

    // MARK: - Column mapping

    // Map header text to known logbook fields based on X-position
    private func mapColumns(from headerRow: [TextObservation]) -> [(field: String, xRange: ClosedRange<CGFloat>)] {
        var mapping: [(field: String, xRange: ClosedRange<CGFloat>)] = []

        for obs in headerRow {
            let headerText = obs.text.lowercased()
            var bestMatch: String = "unknown"
            var bestScore = 0

            for (field, keywords) in Self.columnPatterns {
                for keyword in keywords {
                    if headerText.contains(keyword) && keyword.count > bestScore {
                        bestMatch = field
                        bestScore = keyword.count
                    }
                }
            }

            // Define column range with some padding
            let padding: CGFloat = 0.02
            let xMin = max(0, obs.boundingBox.minX - padding)
            let xMax = min(1, obs.boundingBox.maxX + padding)
            mapping.append((field: bestMatch, xRange: xMin...xMax))
        }

        return mapping
    }

    // MARK: - Flight parsing

    private func parseFlight(from row: [TextObservation], columnMapping: [(field: String, xRange: ClosedRange<CGFloat>)]) -> ParsedFlight? {
        var values: [String: String] = [:]

        for obs in row {
            let cellX = obs.boundingBox.midX

            // Find the closest column
            var bestColumn = "unknown"
            var bestDistance: CGFloat = .greatestFiniteMagnitude

            for col in columnMapping {
                if col.xRange.contains(cellX) {
                    bestColumn = col.field
                    bestDistance = 0
                    break
                }
                let dist = min(abs(cellX - col.xRange.lowerBound), abs(cellX - col.xRange.upperBound))
                if dist < bestDistance {
                    bestDistance = dist
                    bestColumn = col.field
                }
            }

            if bestColumn != "unknown" {
                if let existing = values[bestColumn] {
                    values[bestColumn] = existing + " " + obs.text
                } else {
                    values[bestColumn] = obs.text
                }
            }
        }

        // Skip summary and noise rows
        let rowText = row.map { $0.text }.joined(separator: " ").lowercased()
        if rowText.contains("page total") || rowText.contains("amount forward") ||
           rowText.contains("total to date") || rowText.contains("totals") ||
           rowText.contains("i certify") || rowText.contains("pilot's signature") ||
           rowText.contains("signature") {
            return nil
        }

        // Require a date or at least one time value
        let hasDate = values["date"] != nil && !values["date"]!.isEmpty
        let hasAnyTime = Self.timeFields.contains { values[$0] != nil && !values[$0]!.isEmpty }
        guard hasDate || hasAnyTime else { return nil }

        // Require at least 2 populated fields to filter out edge-of-photo noise
        let populatedCount = values.values.filter { !$0.isEmpty }.count
        guard populatedCount >= 2 else { return nil }

        return ParsedFlight(
            date: values["date"] ?? "",
            aircraftType: values["aircraftType"] ?? "",
            aircraftIdent: values["aircraftIdent"] ?? "",
            departure: values["departure"] ?? "",
            arrival: values["arrival"] ?? "",
            selTime: values["selTime"] ?? "",
            melTime: values["melTime"] ?? "",
            picTime: values["picTime"] ?? "",
            dualTime: values["dualTime"] ?? "",
            dayTime: values["dayTime"] ?? "",
            nightTime: values["nightTime"] ?? "",
            xcTime: values["xcTime"] ?? "",
            actualInstrument: values["actualInstrument"] ?? "",
            simInstrument: values["simInstrument"] ?? "",
            approaches: values["approaches"] ?? "",
            dayLandings: values["dayLandings"] ?? "",
            nightLandings: values["nightLandings"] ?? "",
            totalTime: values["totalTime"] ?? "",
            remarks: values["remarks"] ?? ""
        )
    }
}

enum OCRError: LocalizedError {
    case invalidImage
    case recognitionFailed

    var errorDescription: String? {
        switch self {
        case .invalidImage: return "Could not process the image."
        case .recognitionFailed: return "Text recognition failed."
        }
    }
}
