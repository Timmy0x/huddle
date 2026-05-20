import Foundation
import SwiftUI
import Observation

@Observable
final class HuddleStore {
    var users: [HuddleUser] = []
    var spots: [Spot] = []
    var games: [Game] = []

    var currentUserId: UUID
    var hasSeenLocationPriming: Bool = false

    // Filters
    var selectedSports: Set<Sport> = []
    var maxDistanceMiles: Double = 5
    var timeWindow: TimeWindowFilter = .anytime

    enum TimeWindowFilter: String, CaseIterable, Identifiable {
        case now      = "Now"
        case today    = "Today"
        case tonight  = "Tonight"
        case weekend  = "Weekend"
        case anytime  = "Anytime"
        var id: String { rawValue }
    }

    init() {
        let seed = HuddleSeed.build()
        self.users = seed.users
        self.spots = seed.spots
        self.games = seed.games
        self.currentUserId = seed.currentUserId
    }

    // MARK: - Lookups

    var currentUser: HuddleUser {
        users.first(where: { $0.id == currentUserId }) ?? users[0]
    }

    func user(_ id: UUID) -> HuddleUser? { users.first(where: { $0.id == id }) }
    func spot(_ id: UUID) -> Spot?       { spots.first(where: { $0.id == id }) }
    func game(_ id: UUID) -> Game?       { games.first(where: { $0.id == id }) }

    func host(of game: Game) -> HuddleUser? { user(game.hostId) }
    func spot(of game: Game) -> Spot?       { spot(game.spotId) }

    func attendees(of game: Game) -> [HuddleUser] {
        game.attendeeIds.compactMap { id in users.first(where: { $0.id == id }) }
    }

    func regulars(of spot: Spot) -> [HuddleUser] {
        spot.regularUserIds.compactMap { id in users.first(where: { $0.id == id }) }
    }

    func games(at spot: Spot) -> [Game] {
        games.filter { $0.spotId == spot.id }.sorted(by: { $0.startTime < $1.startTime })
    }

    // MARK: - Discover filtering

    var filteredGames: [Game] {
        let now = Date()
        return games
            .filter { $0.endTime >= now }
            .filter { game in
                selectedSports.isEmpty || selectedSports.contains(game.sport)
            }
            .filter { game in
                switch timeWindow {
                case .anytime: return true
                case .now:
                    return game.startTime.timeIntervalSinceNow < 60 * 60 * 2
                case .today:
                    return Calendar.current.isDateInToday(game.startTime)
                case .tonight:
                    let cal = Calendar.current
                    guard cal.isDateInToday(game.startTime) else { return false }
                    return cal.component(.hour, from: game.startTime) >= 17
                case .weekend:
                    let wk = Calendar.current.component(.weekday, from: game.startTime)
                    return wk == 7 || wk == 1 // Sat / Sun
                }
            }
            .sorted(by: { $0.startTime < $1.startTime })
    }

    // MARK: - RSVP

    func isAttending(_ game: Game) -> Bool {
        game.attendeeIds.contains(currentUserId)
    }

    func toggleRSVP(_ gameId: UUID) {
        guard let idx = games.firstIndex(where: { $0.id == gameId }) else { return }
        var g = games[idx]
        if let i = g.attendeeIds.firstIndex(of: currentUserId) {
            g.attendeeIds.remove(at: i)
        } else if !g.isFull {
            g.attendeeIds.append(currentUserId)
        }
        games[idx] = g
    }

    // MARK: - Hosting

    func hostGame(sport: Sport, spotId: UUID, startTime: Date,
                  durationMinutes: Int, maxPlayers: Int,
                  skill: SkillLevel, notes: String) -> Game {
        let game = Game(
            id: UUID(),
            sport: sport,
            spotId: spotId,
            startTime: startTime,
            durationMinutes: durationMinutes,
            maxPlayers: maxPlayers,
            skill: skill,
            hostId: currentUserId,
            notes: notes,
            attendeeIds: [currentUserId]
        )
        games.append(game)
        return game
    }

    // MARK: - My Games groupings

    var myUpcomingGames: [Game] {
        let now = Date()
        return games
            .filter { $0.attendeeIds.contains(currentUserId) && $0.endTime >= now }
            .sorted(by: { $0.startTime < $1.startTime })
    }

    var myPastGames: [Game] {
        let now = Date()
        return games
            .filter { $0.attendeeIds.contains(currentUserId) && $0.endTime < now }
            .sorted(by: { $0.startTime > $1.startTime })
    }

    func regularSpots(for user: HuddleUser) -> [Spot] {
        spots.filter { $0.regularUserIds.contains(user.id) }
    }
}
