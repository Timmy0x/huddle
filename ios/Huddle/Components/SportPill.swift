import SwiftUI

/// Small pill showing a sport's emoji + short label.
struct SportPill: View {
    let sport: Sport
    var selected: Bool = false
    var compact: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            Text(sport.emoji).font(.system(size: compact ? 13 : 15))
            if !compact {
                Text(sport.shortLabel)
                    .font(.subheadline.weight(.semibold))
            }
        }
        .padding(.horizontal, compact ? 10 : 14)
        .padding(.vertical, compact ? 6 : 9)
        .foregroundStyle(selected ? .white : Theme.primary)
        .background(
            Capsule().fill(selected ? Theme.accent : Theme.surface)
        )
        .overlay(
            Capsule().stroke(selected ? .clear : Theme.hairline, lineWidth: 1)
        )
    }
}

/// Big sport "chip" with emoji circle + name, used in Host picker and Profile.
struct SportChip: View {
    let sport: Sport
    var selected: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            Text(sport.emoji)
                .font(.system(size: 26))
                .frame(width: 52, height: 52)
                .background(
                    Circle().fill(selected ? Theme.accent : Theme.surface)
                )
                .overlay(
                    Circle().stroke(selected ? .clear : Theme.hairline, lineWidth: 1)
                )
                .foregroundStyle(selected ? .white : Theme.primary)
            Text(sport.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(selected ? Theme.accent : Theme.subtle)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatusBadge: View {
    let game: Game
    var body: some View {
        Group {
            if game.isFull {
                label("Full", color: Theme.subtle, bg: Theme.surfaceAlt)
            } else if game.isAlmostFull {
                label("\(game.spotsLeft) left", color: .white, bg: Theme.warning)
            } else {
                label("\(game.spotsLeft) spots", color: Theme.accent, bg: Theme.accentSoft)
            }
        }
    }

    private func label(_ text: String, color: Color, bg: Color) -> some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(bg))
    }
}
