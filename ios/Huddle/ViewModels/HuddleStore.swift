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
    var hasCompletedOnboarding: Bool = false

    // Onboarding capture
    var onboardingSports: Set<Sport> = []
    var onboardingSkill: SkillLevel = .casual
    var onboardingFrequency: PlayFrequency = .weekly
    var onboardingNeighborhood: String = ""
    var notificationsPrimed: Bool = false
    var locationPrimed: Bool = false

    enum PlayFrequency: String, CaseIterable, Identifiable {
        case rarely = "A few times a year"
        case monthly = "Once a month"
        case weekly  = "Every week"
        case daily   = "Almost every day"
        var id: String { rawValue }
        var emoji: String {
            switch self {
            case .rarely:  "🌱"
            case .monthly: "🗓️"
            case .weekly:  "🔥"
            case .daily:   "🏆"
            }
        }
    }

    func completeOnboarding(name: String, handle: String) {
        if var me = users.first(where: { $0.id == currentUserId }) {
            let trimmed = name.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty { me.name = trimmed }
            let h = handle.trimmingCharacters(in: .whitespaces)
            if !h.isEmpty { me.handle = h.hasPrefix("@") ? h : "@\(h)" }
            if !onboardingSports.isEmpty { me.sports = Sport.allCases.filter { onboardingSports.contains($0) } }
            me.skill = onboardingSkill
            if let idx = users.firstIndex(where: { $0.id == currentUserId }) {
                users[idx] = me
            }
        }
        if !onboardingSports.isEmpty {
            selectedSports = onboardingSports
        }
        hasCompletedOnboarding = true
        hasSeenLocationPriming = true
    }

    // Personalized count for reveal screen
    var personalizedGameCount: Int {
        let sports = onboardingSports.isEmpty ? Set(Sport.allCases) : onboardingSports
        return games.filter {
            sports.contains($0.sport) && $0.endTime >= Date() &&
            $0.startTime.timeIntervalSinceNow < 7 * 86400
        }.count
    }

    var personalizedSampleGames: [Game] {
        let sports = onboardingSports.isEmpty ? Set(Sport.allCases) : onboardingSports
        return games
            .filter { sports.contains($0.sport) && $0.endTime >= Date() }
            .sorted(by: { $0.startTime < $1.startTime })
            .prefix(3)
            .map { $0 }
    }

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
