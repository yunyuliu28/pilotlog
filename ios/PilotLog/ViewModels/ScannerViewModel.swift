import SwiftUI
import SwiftData

enum ScanState: Equatable {
    case idle
    case scanning
    case processing
    case review
    case saved
    case error(String)

    static func == (lhs: ScanState, rhs: ScanState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.scanning, .scanning), (.processing, .processing),
             (.review, .review), (.saved, .saved):
            return true
        case (.error(let a), .error(let b)):
            return a == b
        default:
            return false
        }
    }
}

@Observable
final class ScannerViewModel {
    var state: ScanState = .idle
    var scannedImages: [UIImage] = []
    var parsedFlights: [ParsedFlight] = []
    var currentPageIndex: Int = 0
    var totalPages: Int = 0

    private let ocrService = OCRService()

    func startScan() {
        state = .scanning
    }

    func didFinishScanning(images: [UIImage]) {
        scannedImages = images
        totalPages = images.count
        Task { await processImages() }
    }

    func didCancelScanning() {
        state = .idle
    }

    @MainActor
    private func processImages() async {
        state = .processing
        currentPageIndex = 1
        totalPages = scannedImages.count

        // Use Claude Vision if API key is set, otherwise fall back to local OCR
        let apiKey = UserDefaults.standard.string(forKey: "anthropicAPIKey") ?? ""

        if !apiKey.isEmpty {
            await processWithClaude(apiKey: apiKey)
        } else {
            await processWithLocalOCR()
        }
    }

    @MainActor
    private func processWithClaude(apiKey: String) async {
        let service = ClaudeOCRService(apiKey: apiKey)

        do {
            // Send all images to Claude in one request — it handles left/right halves natively
            let flights = try await service.extractFlights(from: scannedImages)
            parsedFlights = flights

            if flights.isEmpty {
                state = .error("No flight entries found. Try a clearer image.")
            } else {
                state = .review
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    @MainActor
    private func processWithLocalOCR() async {
        var allFlights: [ParsedFlight] = []

        for (index, image) in scannedImages.enumerated() {
            currentPageIndex = index + 1
            do {
                let flights = try await ocrService.extractFlights(from: image)
                allFlights.append(contentsOf: flights)
            } catch {
                print("OCR failed for page \(index + 1): \(error)")
            }
        }

        parsedFlights = allFlights

        if allFlights.isEmpty {
            state = .error("No flight entries found. Try scanning a clearer image of your logbook page.")
        } else {
            state = .review
        }
    }

    func saveFlights(to modelContext: ModelContext) {
        for parsed in parsedFlights {
            let entry = parsed.toFlightEntry()
            // Attach source image if only one page was scanned
            if scannedImages.count == 1 {
                entry.sourceImageData = scannedImages[0].jpegData(compressionQuality: 0.5)
            }
            modelContext.insert(entry)
        }
        state = .saved
    }

    func reset() {
        state = .idle
        scannedImages = []
        parsedFlights = []
        currentPageIndex = 0
        totalPages = 0
    }

    func removeFlight(at index: Int) {
        guard parsedFlights.indices.contains(index) else { return }
        parsedFlights.remove(at: index)
        if parsedFlights.isEmpty {
            state = .idle
        }
    }
}
