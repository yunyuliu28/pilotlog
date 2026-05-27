import SwiftUI
import SwiftData

@main
struct PilotLogApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .preferredColorScheme(.dark)

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
