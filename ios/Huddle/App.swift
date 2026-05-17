import SwiftUI

@main
struct HuddleApp: App {
    @State private var store = HuddleStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .tint(Theme.accent)
                .preferredColorScheme(.light)
        }
    }
}
