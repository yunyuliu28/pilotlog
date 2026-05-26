import UIKit

actor ClaudeOCRService {
    private let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func extractFlights(from images: [UIImage]) async throws -> [ParsedFlight] {
        let prompt: String
        if images.count >= 2 {
            prompt = """
                These images show the LEFT and RIGHT halves of the same pilot logbook page spread. \
                Combine the information from both halves to extract complete flight entries. \
                Match rows by their vertical position. \
                Skip any summary or total rows (PAGE TOTAL, AMOUNT FORWARD, TOTAL TO DATE). \
                Skip any certification text or signatures.

                Return a JSON array where each flight is an object with these keys (use empty string "" for missing/empty fields):
                date, aircraftType, aircraftIdent, departure, arrival, selTime, melTime, picTime, dualTime, \
                dayTime, nightTime, xcTime, actualInstrument, simInstrument, approaches, dayLandings, \
                nightLandings, totalTime, remarks

                Return ONLY the JSON array. No markdown code fences, no explanation.
                """
        } else {
            prompt = """
                Extract all individual flight entries from this pilot logbook page. \
                Skip any summary or total rows (PAGE TOTAL, AMOUNT FORWARD, TOTAL TO DATE). \
                Skip any certification text or signatures.

                Return a JSON array where each flight is an object with these keys (use empty string "" for missing/empty fields):
                date, aircraftType, aircraftIdent, departure, arrival, selTime, melTime, picTime, dualTime, \
                dayTime, nightTime, xcTime, actualInstrument, simInstrument, approaches, dayLandings, \
                nightLandings, totalTime, remarks

                Return ONLY the JSON array. No markdown code fences, no explanation.
                """
        }

        // Build multimodal content
        var content: [[String: Any]] = []

        for image in images {
            let scaled = downscale(image, maxDimension: 1500)
            guard let data = scaled.jpegData(compressionQuality: 0.8) else { continue }
            content.append([
                "type": "image",
                "source": [
                    "type": "base64",
                    "media_type": "image/jpeg",
                    "data": data.base64EncodedString()
                ] as [String: String]
            ])
        }

        content.append([
            "type": "text",
            "text": prompt
        ])

        let body: [String: Any] = [
            "model": "claude-sonnet-4-6",
            "max_tokens": 4096,
            "messages": [
                [
                    "role": "user",
                    "content": content
                ] as [String: Any]
            ]
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = jsonData
        request.timeoutInterval = 60

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClaudeError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            if httpResponse.statusCode == 401 {
                throw ClaudeError.invalidAPIKey
            }
            throw ClaudeError.apiError(statusCode: httpResponse.statusCode, message: errorBody)
        }

        // Parse Claude response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let contentArray = json["content"] as? [[String: Any]],
              let textBlock = contentArray.first(where: { $0["type"] as? String == "text" }),
              let text = textBlock["text"] as? String else {
            throw ClaudeError.parseError
        }

        // Strip markdown code fences if present
        let cleaned = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let flightData = cleaned.data(using: .utf8) else {
            throw ClaudeError.parseError
        }

        return try JSONDecoder().decode([ParsedFlight].self, from: flightData)
    }

    private func downscale(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let scale = min(maxDimension / size.width, maxDimension / size.height, 1.0)
        guard scale < 1.0 else { return image }

        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

enum ClaudeError: LocalizedError {
    case invalidResponse
    case invalidAPIKey
    case apiError(statusCode: Int, message: String)
    case parseError

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server."
        case .invalidAPIKey:
            return "Invalid API key. Check your key in the Profile tab."
        case .apiError(let code, _):
            return "API error (\(code)). Please try again."
        case .parseError:
            return "Could not parse the flight data from the response."
        }
    }
}
