import Foundation

enum HuddleSeed {

    struct Result {
        let users: [HuddleUser]
        let spots: [Spot]
        let games: [Game]
        let currentUserId: UUID
    }

    static func build() -> Result {
        let cal = Calendar.current
        let now = Date()
        func at(_ hour: Int, _ minute: Int = 0, dayOffset: Int = 0) -> Date {
            let base = cal.startOfDay(for: now).addingTimeInterval(TimeInterval(dayOffset * 86400))
            return cal.date(byAdding: .init(hour: hour, minute: minute), to: base) ?? base
        }

        // MARK: Users
        let me = HuddleUser(
            id: UUID(), name: "You", handle: "@you",
            avatarColorHex: 0x2563EB,
            sports: [.basketball, .pickleball, .run],
            skill: .casual, attendedGameIds: [], hostedGameIds: []
        )
        let maya = HuddleUser(id: UUID(), name: "Maya Chen", handle: "@mayac",
            avatarColorHex: 0xF59E0B, sports: [.basketball, .run], skill: .competitive, attendedGameIds: [], hostedGameIds: [])
        let dev = HuddleUser(id: UUID(), name: "Devonte Hill", handle: "@dhill",
            avatarColorHex: 0x16A34A, sports: [.basketball, .soccer], skill: .competitive, attendedGameIds: [], hostedGameIds: [])
        let sara = HuddleUser(id: UUID(), name: "Sara Okonkwo", handle: "@sarao",
            avatarColorHex: 0xDB2777, sports: [.soccer, .volleyball], skill: .casual, attendedGameIds: [], hostedGameIds: [])
        let leo = HuddleUser(id: UUID(), name: "Leo Park", handle: "@leop",
            avatarColorHex: 0x7C3AED, sports: [.pickleball, .tennis], skill: .casual, attendedGameIds: [], hostedGameIds: [])
        let ana = HuddleUser(id: UUID(), name: "Ana Vargas", handle: "@anav",
            avatarColorHex: 0x0EA5E9, sports: [.volleyball, .run], skill: .chill, attendedGameIds: [], hostedGameIds: [])
        let kenji = HuddleUser(id: UUID(), name: "Kenji Watts", handle: "@kenji",
            avatarColorHex: 0xEA580C, sports: [.basketball], skill: .competitive, attendedGameIds: [], hostedGameIds: [])
        let priya = HuddleUser(id: UUID(), name: "Priya Shah", handle: "@priyas",
            avatarColorHex: 0x0891B2, sports: [.pickleball, .tennis, .run], skill: .casual, attendedGameIds: [], hostedGameIds: [])
        let jordan = HuddleUser(id: UUID(), name: "Jordan Reeve", handle: "@jord",
            avatarColorHex: 0x9333EA, sports: [.soccer, .basketball], skill: .casual, attendedGameIds: [], hostedGameIds: [])
        let nia = HuddleUser(id: UUID(), name: "Nia Brooks", handle: "@niab",
            avatarColorHex: 0xE11D48, sports: [.run, .volleyball], skill: .chill, attendedGameIds: [], hostedGameIds: [])

        let users = [me, maya, dev, sara, leo, ana, kenji, priya, jordan, nia]

        // MARK: Spots (NYC anchor)
        let mccarren = Spot(id: UUID(), name: "McCarren Park", neighborhood: "Williamsburg",
            latitude: 40.7206, longitude: -73.9522,
            sports: [.basketball, .soccer, .run],
            regularUserIds: [maya.id, dev.id, kenji.id])
        let westSide = Spot(id: UUID(), name: "West 4th Cage", neighborhood: "Greenwich Village",
            latitude: 40.7314, longitude: -74.0001,
            sports: [.basketball],
            regularUserIds: [dev.id, kenji.id, jordan.id])
        let pier6 = Spot(id: UUID(), name: "Pier 6 Courts", neighborhood: "Brooklyn Bridge Park",
            latitude: 40.6996, longitude: -73.9990,
            sports: [.volleyball, .pickleball],
            regularUserIds: [ana.id, leo.id, priya.id])
        let prospect = Spot(id: UUID(), name: "Prospect Park Long Meadow", neighborhood: "Park Slope",
            latitude: 40.6622, longitude: -73.9692,
            sports: [.soccer, .run],
            regularUserIds: [sara.id, jordan.id, nia.id])
        let central = Spot(id: UUID(), name: "Central Park Reservoir", neighborhood: "Upper East Side",
            latitude: 40.7857, longitude: -73.9637,
            sports: [.run],
            regularUserIds: [maya.id, nia.id, priya.id])
        let astoria = Spot(id: UUID(), name: "Astoria Park Pickle", neighborhood: "Astoria",
            latitude: 40.7795, longitude: -73.9220,
            sports: [.pickleball, .tennis],
            regularUserIds: [leo.id, priya.id])

        let spots = [mccarren, westSide, pier6, prospect, central, astoria]

        // MARK: Games
        var games: [Game] = []

        games.append(Game(id: UUID(), sport: .basketball, spotId: westSide.id,
            startTime: at(18, 30), durationMinutes: 90, maxPlayers: 10, skill: .competitive,
            hostId: dev.id, notes: "5v5 full court. Winners stay. Bring a light + dark shirt.",
            attendeeIds: [dev.id, kenji.id, jordan.id, maya.id, leo.id, sara.id, ana.id]))

        games.append(Game(id: UUID(), sport: .pickleball, spotId: pier6.id,
            startTime: at(17, 0), durationMinutes: 120, maxPlayers: 8, skill: .casual,
            hostId: leo.id, notes: "Open play. Rotate every 11 points. All levels welcome.",
            attendeeIds: [leo.id, priya.id, ana.id]))

        games.append(Game(id: UUID(), sport: .soccer, spotId: prospect.id,
            startTime: at(19, 15), durationMinutes: 90, maxPlayers: 14, skill: .casual,
            hostId: sara.id, notes: "7v7 on the long meadow. Cleats optional.",
            attendeeIds: [sara.id, jordan.id, dev.id, nia.id, maya.id]))

        games.append(Game(id: UUID(), sport: .run, spotId: central.id,
            startTime: at(7, 30, dayOffset: 1), durationMinutes: 60, maxPlayers: 20, skill: .chill,
            hostId: maya.id, notes: "Easy 4 miles around the reservoir. Coffee after at Joe's.",
            attendeeIds: [maya.id, nia.id, priya.id, ana.id, jordan.id, sara.id]))

        games.append(Game(id: UUID(), sport: .basketball, spotId: mccarren.id,
            startTime: at(11, 0, dayOffset: 1), durationMinutes: 120, maxPlayers: 12, skill: .casual,
            hostId: kenji.id, notes: "Saturday runs. 3s and 4s depending on turnout.",
            attendeeIds: [kenji.id, dev.id, maya.id, jordan.id]))

        games.append(Game(id: UUID(), sport: .volleyball, spotId: pier6.id,
            startTime: at(15, 30, dayOffset: 1), durationMinutes: 120, maxPlayers: 12, skill: .casual,
            hostId: ana.id, notes: "4s under the bridge. Sand court closest to the water.",
            attendeeIds: [ana.id, nia.id, sara.id, leo.id]))

        games.append(Game(id: UUID(), sport: .pickleball, spotId: astoria.id,
            startTime: at(9, 30, dayOffset: 2), durationMinutes: 90, maxPlayers: 8, skill: .competitive,
            hostId: priya.id, notes: "3.5+ play. We'll run a small ladder.",
            attendeeIds: [priya.id, leo.id]))

        games.append(Game(id: UUID(), sport: .tennis, spotId: astoria.id,
            startTime: at(8, 0, dayOffset: 3), durationMinutes: 90, maxPlayers: 4, skill: .casual,
            hostId: leo.id, notes: "Doubles, rotating partners.",
            attendeeIds: [leo.id, priya.id]))

        games.append(Game(id: UUID(), sport: .soccer, spotId: mccarren.id,
            startTime: at(19, 0, dayOffset: 2), durationMinutes: 90, maxPlayers: 14, skill: .competitive,
            hostId: jordan.id, notes: "Faster pace, scrimmage style.",
            attendeeIds: [jordan.id, dev.id, sara.id]))

        // A recently-past game so My Games > Past has content
        games.append(Game(id: UUID(), sport: .basketball, spotId: westSide.id,
            startTime: at(18, 0, dayOffset: -3), durationMinutes: 90, maxPlayers: 10, skill: .competitive,
            hostId: dev.id, notes: "Tuesday run.",
            attendeeIds: [dev.id, kenji.id, me.id, jordan.id, maya.id]))

        return Result(users: users, spots: spots, games: games, currentUserId: me.id)
    }
}
