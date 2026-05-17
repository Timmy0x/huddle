import SwiftUI

struct MyGamesView: View {
    @Environment(HuddleStore.self) private var store
    @State private var navGameId: UUID? = nil

    private var todayGames: [Game] {
        store.myUpcomingGames.filter { Calendar.current.isDateInToday($0.startTime) }
    }
    private var thisWeekGames: [Game] {
        store.myUpcomingGames.filter {
            !Calendar.current.isDateInToday($0.startTime) &&
            ($0.startTime.timeIntervalSinceNow < 7 * 86400)
        }
    }
    private var laterGames: [Game] {
        store.myUpcomingGames.filter { $0.startTime.timeIntervalSinceNow >= 7 * 86400 }
    }

    var body: some View {
        Group {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
                        headerStats
            
                        if store.myUpcomingGames.isEmpty && store.myPastGames.isEmpty {
                            emptyState
                                .padding(.top, 30)
                        } else {
                            section("Today", games: todayGames)
                            section("This week", games: thisWeekGames)
                            section("Later", games: laterGames)
                            section("Past", games: store.myPastGames, faded: true)
                        }
            
                        Color.clear.frame(height: 30)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                }
                .background(Theme.surface.ignoresSafeArea())
                .navigationTitle("My Games")
                .navigationDestination(item: $navGameId) { id in
                    if let game = store.game(id) {
                        GameDetailView(game: game)
                    }
                }
            }
        }
        .trackView("MyGamesView")
    }

    private var headerStats: some View {
        let upcoming = store.myUpcomingGames.count
        let played = store.myPastGames.count
        let regulars = store.regularSpots(for: store.currentUser).count
        return HStack(spacing: 10) {
            stat(value: "\(upcoming)", label: "Upcoming")
            stat(value: "\(played)", label: "Played")
            stat(value: "\(regulars)", label: "Spots")
        }
    }

    private func stat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.primary)
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.subtle)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Theme.hairline, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func section(_ title: String, games: [Game], faded: Bool = false) -> some View {
        if !games.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Theme.primary)
                    Spacer()
                    Text("\(games.count)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.subtle)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Capsule().fill(Theme.surfaceAlt))
                }
                ForEach(games) { game in
                    if let spot = store.spot(of: game), let host = store.host(of: game) {
                        Button { navGameId = game.id } label: {
                            GameCard(game: game, spot: spot, host: host,
                                     attendees: store.attendees(of: game),
                                     compact: true)
                                .opacity(faded ? 0.7 : 1)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Theme.accent)
                .padding(22)
                .background(Circle().fill(Theme.accentSoft))
            Text("Your week is open")
                .font(.title3.weight(.semibold))
            Text("Find a game on Discover or post one — your RSVPs land here.")
                .font(.subheadline)
                .foregroundStyle(Theme.subtle)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.top, 20)
    }
}

#Preview {
    MyGamesView().environment(HuddleStore())
}
