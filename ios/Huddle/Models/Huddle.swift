import Foundation
import SwiftUI
import CoreLocation

// MARK: - Sport

enum Sport: String, CaseIterable, Identifiable, Codable, Hashable {
    case basketball, soccer, pickleball, volleyball, tennis, run

    var id: String { rawValue }

    var title: String {
        switch self {
        case .basketball: "Basketball"
        case .soccer:     "Soccer"
        case .pickleball: "Pickleball"
        case .volleyball: "Volleyball"
        case .tennis:     "Tennis"
        case .run:        "Run Club"
        }
    }

    var emoji: String {
        switch self {
        case .basketball: "🏀"
        case .soccer:     "⚽️"
        case .pickleball: "🏓"
        case .volleyball: "🏐"
        case .tennis:     "🎾"
        case .run:        "🏃"
        }
    }

    var shortLabel: String {
        switch self {
        case .basketball: "Hoops"
        case .soccer:     "Soccer"
        case .pickleball: "Pickle"
        case .volleyball: "Volley"
        case .tennis:     "Tennis"
        case .run:        "Run"
        }
    }
}

// MARK: - Skill

enum SkillLevel: String, CaseIterable, Identifiable, Codable, Hashable {
    case chill, casual, competitive

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chill:       "Chill"
        case .casual:      "Casual"
        case .competitive: "Competitive"
        }
    }

    var blurb: String {
        switch self {
        case .chill:       "Just here to play"
        case .casual:      "Friendly + a little sweaty"
        case .competitive: "We're keeping score"
        }
    }
}

// MARK: - User

struct HuddleUser: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var handle: String
    var avatarColorHex: UInt32
    var sports: [Sport]
    var skill: SkillLevel
    var attendedGameIds: [UUID]
    var hostedGameIds: [UUID]

    var initials: String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }

    var avatarColor: Color { Color(hex: avatarColorHex) }
}

// MARK: - Spot

struct Spot: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var neighborhood: String
    var latitude: Double
    var longitude: Double
    var sports: [Sport]
    var regularUserIds: [UUID]

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Game

struct Game: Identifiable, Hashable, Codable {
    let id: UUID
    var sport: Sport
    var spotId: UUID
    var startTime: Date
    var durationMinutes: Int
    var maxPlayers: Int
    var skill: SkillLevel
    var hostId: UUID
    var notes: String
    var attendeeIds: [UUID]

    var endTime: Date {
        startTime.addingTimeInterval(TimeInterval(durationMinutes * 60))
    }

    var spotsLeft: Int { max(0, maxPlayers - attendeeIds.count) }
    var isFull: Bool { spotsLeft == 0 }
    var isAlmostFull: Bool { !isFull && spotsLeft <= max(1, maxPlayers / 5) }
}

// MARK: - Formatters

enum HuddleFormat {
    static let timeOnly: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    static let dayShort: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d"
        return f
    }()

    static let weekdayShort: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f
    }()

    static func relativeDay(_ date: Date, now: Date = .now) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date)    { return "Today" }
        if cal.isDateInTomorrow(date) { return "Tomorrow" }
        if let days = cal.dateComponents([.day], from: cal.startOfDay(for: now), to: cal.startOfDay(for: date)).day,
           days >= 0, days < 7 {
            return weekdayShort.string(from: date)
        }
        return dayShort.string(from: date)
    }

    static func timeWindow(_ game: Game) -> String {
        "\(timeOnly.string(from: game.startTime)) – \(timeOnly.string(from: game.endTime))"
    }
}
