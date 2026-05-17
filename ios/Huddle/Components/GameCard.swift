import SwiftUI

/// The signature Huddle card: bold sport tile on the left, content on the right,
/// attendee stack + status badge along the bottom. Partiful-style energy without
/// looking like a generic full-width rounded card.
struct GameCard: View {
    let game: Game
    let spot: Spot
    let host: HuddleUser
    let attendees: [HuddleUser]
    var compact: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Sport tile — the visual anchor.
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Theme.primary, Theme.accent],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                Text(game.sport.emoji)
                    .font(.system(size: 40))
                    .padding(12)
                VStack(alignment: .leading, spacing: 2) {
                    Text(HuddleFormat.relativeDay(game.startTime).uppercased())
                        .font(.system(size: 9, weight: .heavy, design: .rounded))
                        .tracking(0.6)
                        .foregroundStyle(.white.opacity(0.75))
                    Text(HuddleFormat.timeOnly.string(from: game.startTime))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(10)
            }
            .frame(width: compact ? 92 : 108, height: compact ? 92 : 108)

            // Right: content
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    Text(spot.name)
                        .font(.headline)
                        .foregroundStyle(Theme.primary)
                        .lineLimit(1)
                    Spacer(minLength: 6)
                    StatusBadge(game: game)
                }

                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(Theme.subtle)
                        .font(.caption)
                    Text(spot.neighborhood)
                        .font(.subheadline)
                        .foregroundStyle(Theme.subtle)
                        .lineLimit(1)
                    Text("•").foregroundStyle(Theme.subtle)
                    Text(game.skill.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.subtle)
                }

                Spacer(minLength: 0)

                HStack(spacing: 10) {
                    AvatarStack(users: attendees, size: 24, maxShown: 4)
                    Text(attendeeLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.subtle)
                    Spacer()
                    Text("Hosted by \(host.name.split(separator: " ").first.map(String.init) ?? host.name)")
                        .font(.caption2)
                        .foregroundStyle(Theme.subtle)
                        .lineLimit(1)
                }
            }
            .frame(height: compact ? 92 : 108)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Theme.hairline, lineWidth: 1)
        )
        .shadow(color: Theme.primary.opacity(0.05), radius: 14, x: 0, y: 6)
    }

    private var attendeeLabel: String {
        let n = game.attendeeIds.count
        return "\(n)/\(game.maxPlayers) going"
    }
}

#Preview {
    let store = HuddleStore()
    let game = store.games[0]
    let spot = store.spot(of: game)!
    let host = store.host(of: game)!
    return GameCard(game: game, spot: spot, host: host, attendees: store.attendees(of: game))
        .padding()
        .background(Theme.surface)
}
