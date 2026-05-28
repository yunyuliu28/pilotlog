import SwiftUI
import SwiftData

@main
struct PilotLogApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    #if DEBUG
                    .modifier(MockDataInjector())
                    #endif

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                }
            }
            .animation(.easeOut(duration: 0.4), value: showSplash)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showSplash = false
                }
            }
        }
        .modelContainer(for: FlightEntry.self)
    }
}

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0

    var body: some View {
        ZStack {
            Color(red: 0.176, green: 0.176, blue: 0.176).ignoresSafeArea()

            Image("SplashLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
        }
    }
}

// MARK: - Mock Data (Debug only)

#if DEBUG
struct MockDataInjector: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("mockDataInserted") private var inserted = false

    func body(content: Content) -> some View {
        content.onAppear {
            guard !inserted else { return }
            insertMockFlights()
            inserted = true
        }
    }

    private func insertMockFlights() {
        let cal = Calendar.current
        let now = Date.now

        struct MockFlight {
            let daysAgo: Int, type: String, ident: String, dep: String, arr: String
            let sel: Double, mel: Double, pic: Double, dual: Double
            let day: Double, night: Double, xc: Double
            let appr: Int, dayLdg: Int, nightLdg: Int, total: Double, remarks: String
        }

        let flights: [MockFlight] = [
            .init(daysAgo: 1,  type: "C172",      ident: "4100CL", dep: "FAI", arr: "FAI", sel: 4.4, mel: 0,   pic: 1.4, dual: 0,   day: 4.3, night: 0,   xc: 0,   appr: 0, dayLdg: 1, nightLdg: 0, total: 4.4, remarks: "C172 moose spotting Goldpine"),
            .init(daysAgo: 3,  type: "PA-31-350", ident: "234CE",  dep: "FAI", arr: "CXF", sel: 0,   mel: 2.3, pic: 2.3, dual: 0,   day: 2.3, night: 0,   xc: 2.3, appr: 0, dayLdg: 1, nightLdg: 0, total: 2.3, remarks: "Nate tour flight Coldfoot"),
            .init(daysAgo: 5,  type: "PA-31-350", ident: "234CE",  dep: "FAI", arr: "CXF", sel: 0,   mel: 2.4, pic: 2.4, dual: 0,   day: 2.0, night: 0.4, xc: 2.4, appr: 0, dayLdg: 1, nightLdg: 0, total: 2.4, remarks: ""),
            .init(daysAgo: 8,  type: "C172",      ident: "4401L",  dep: "FAI", arr: "FAI", sel: 2.5, mel: 0,   pic: 2.5, dual: 0,   day: 2.5, night: 0,   xc: 0,   appr: 0, dayLdg: 1, nightLdg: 0, total: 2.5, remarks: "C172 maneuvers"),
            .init(daysAgo: 12, type: "C172",      ident: "4401L",  dep: "FAI", arr: "MLY", sel: 3.7, mel: 0,   pic: 3.7, dual: 0,   day: 3.0, night: 0.7, xc: 2.6, appr: 0, dayLdg: 1, nightLdg: 0, total: 3.7, remarks: "C172 maneuvers/XC"),
            .init(daysAgo: 15, type: "PA-31-350", ident: "S4WA",   dep: "FAI", arr: "CXF", sel: 0,   mel: 2.5, pic: 2.5, dual: 0,   day: 2.5, night: 0,   xc: 2.5, appr: 0, dayLdg: 1, nightLdg: 0, total: 2.5, remarks: "JA C172 CXF"),
            .init(daysAgo: 20, type: "C172",      ident: "4100CL", dep: "FAI", arr: "CXF", sel: 4.2, mel: 0,   pic: 4.2, dual: 0,   day: 4.2, night: 0,   xc: 4.2, appr: 0, dayLdg: 1, nightLdg: 0, total: 4.2, remarks: ""),
            .init(daysAgo: 25, type: "C172",      ident: "N733YL", dep: "FAI", arr: "ENA", sel: 3.8, mel: 0,   pic: 3.8, dual: 0,   day: 2.0, night: 1.8, xc: 3.8, appr: 0, dayLdg: 1, nightLdg: 1, total: 3.8, remarks: "Night XC to Kenai"),
            .init(daysAgo: 30, type: "PA-28-181", ident: "N8245T", dep: "FAI", arr: "FAI", sel: 1.5, mel: 0,   pic: 0,   dual: 1.5, day: 1.5, night: 0,   xc: 0,   appr: 2, dayLdg: 1, nightLdg: 0, total: 1.5, remarks: "Dual - steep turns, stalls"),
            .init(daysAgo: 45, type: "C172",      ident: "4401L",  dep: "FAI", arr: "BRW", sel: 5.2, mel: 0,   pic: 5.2, dual: 0,   day: 5.2, night: 0,   xc: 5.2, appr: 0, dayLdg: 1, nightLdg: 0, total: 5.2, remarks: "Long XC to Barrow"),
            .init(daysAgo: 60, type: "PA-31-350", ident: "234CE",  dep: "FAI", arr: "ANC", sel: 0,   mel: 3.1, pic: 3.1, dual: 0,   day: 3.1, night: 0,   xc: 3.1, appr: 0, dayLdg: 1, nightLdg: 0, total: 3.1, remarks: "Charter to Anchorage"),
            .init(daysAgo: 75, type: "C172",      ident: "N733YL", dep: "FAI", arr: "FAI", sel: 1.2, mel: 0,   pic: 0,   dual: 1.2, day: 1.2, night: 0,   xc: 0,   appr: 2, dayLdg: 1, nightLdg: 0, total: 1.2, remarks: "Dual - instrument approaches"),
        ]

        for f in flights {
            let entry = FlightEntry(
                date: cal.date(byAdding: .day, value: -f.daysAgo, to: now)!,
                aircraftType: f.type, aircraftIdent: f.ident,
                departure: f.dep, arrival: f.arr,
                selTime: f.sel, melTime: f.mel, picTime: f.pic, dualTime: f.dual,
                dayTime: f.day, nightTime: f.night, xcTime: f.xc,
                approaches: f.appr, dayLandings: f.dayLdg, nightLandings: f.nightLdg,
                totalTime: f.total, remarks: f.remarks
            )
            modelContext.insert(entry)
        }
    }
}
#endif
