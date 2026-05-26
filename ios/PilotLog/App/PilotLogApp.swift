import SwiftUI
import SwiftData

@main
struct PilotLogApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: FlightEntry.self)
    }
}
