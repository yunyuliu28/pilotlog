import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            LogbookView()
                .tabItem {
                    Label("Logbook", systemImage: "book.fill")
                }
                .tag(0)

            ScanFlowView()
                .tabItem {
                    Label("Scan", systemImage: "doc.viewfinder")
                }
                .tag(1)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .tint(.blue)
    }
}
