import SwiftUI

struct ContentView: View {
    @Environment(HuddleStore.self) private var store
    @State private var selectedTab: Tab = .discover
    @State private var showHost = false

    enum Tab: Hashable { case discover, myGames, profile }

    var body: some View {
        Group {
            Group {
                if store.hasCompletedOnboarding {
                    mainShell
                } else {
                    OnboardingFlow()
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .animation(.easeInOut(duration: 0.35), value: store.hasCompletedOnboarding)
        }
        .trackView("ContentView")
    }

    private var mainShell: some View {
        TabView(selection: $selectedTab) {
            DiscoverView(showHost: $showHost)
                .tabItem { Label("Discover", systemImage: "sportscourt.fill") }
                .tag(Tab.discover)

            MyGamesView()
                .tabItem { Label("My Games", systemImage: "calendar") }
                .tag(Tab.myGames)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                .tag(Tab.profile)
        }
        .sheet(isPresented: $showHost) {
            HostGameView()
        }
    }
}

#Preview {
    ContentView().environment(HuddleStore())
}
