import SwiftUI
import MapKit

struct GameDetailView: View {
    @Environment(HuddleStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    let game: Game

    private var liveGame: Game { store.game(game.id) ?? game }

    var body: some View {
        Group {
            ScrollView {
                VStack(spacing: 0) {
                    hero
                    content
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 140) // room for sticky CTA
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .ignoresSafeArea(edges: .top)
            .overlay(alignment: .top) { topBar }
            .overlay(alignment: .bottom) { stickyCTA }
            .toolbar(.hidden, for: .navigationBar)
        }
        .trackView("GameDetailView")
    }

    // MARK: - Hero

    private var hero: some View {
        let g = liveGame
        return ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Theme.primary, Theme.accent],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

            // Decorative giant emoji
            Text(g.sport.emoji)
                .font(.system(size: 260))
                .opacity(0.18)
                .rotationEffect(.degrees(-8))
                .offset(x: 90, y: -10)
                .clipped()

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Text(g.sport.emoji).font(.title3)
                    Text(g.sport.title.uppercased())
                        .font(.caption.weight(.heavy))
                        .tracking(1.5)
                }
                .padding(.horizontal, 12).padding(.vertical, 7)
                .background(Capsule().fill(.white.opacity(0.18)))
                .foregroundStyle(.white)

                if let spot = store.spot(of: g) {
                    Text(spot.name)
                        .font(.system(size: 34, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text(spot.neighborhood)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .padding(20)
            .padding(.top, 80)
        }
        .frame(height: 280)
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(.black.opacity(0.25)))
            }
            Spacer()
            ShareLink(item: shareText) {
                Image(systemName: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(.black.opacity(0.25)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var shareText: String {
        let g = liveGame
        let spot = store.spot(of: g)?.name ?? "the spot"
        return "\(g.sport.emoji) \(g.sport.title) at \(spot) — \(HuddleFormat.relativeDay(g.startTime)) \(HuddleFormat.timeOnly.string(from: g.startTime)). Come thru on Huddle."
    }

    // MARK: - Content

    private var content: some View {
        let g = liveGame
        return VStack(alignment: .leading, spacing: 24) {
            // When + skill row
            HStack(spacing: 12) {
                infoTile(icon: "calendar",
                         title: HuddleFormat.relativeDay(g.startTime),
                         subtitle: HuddleFormat.timeWindow(g))
                infoTile(icon: "flame.fill",
                         title: g.skill.title,
                         subtitle: g.skill.blurb)
            }

            // Going block
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Who's in")
                        .font(.title3.weight(.bold))
                    Spacer()
                    StatusBadge(game: g)
                }
                attendeeGrid
            }

            // Host
            if let host = store.host(of: g) {
                hostBlock(host: host)
            }

            // Notes
            if !g.notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Heads up")
                        .font(.title3.weight(.bold))
                    Text(g.notes)
                        .font(.body)
                        .foregroundStyle(Theme.text.opacity(0.85))
                }
            }

            // Map preview
            if let spot = store.spot(of: g) {
                spotMap(spot: spot)
            }
        }
    }

    private func infoTile(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(Theme.accent)
                .frame(width: 38, height: 38)
                .background(Circle().fill(Theme.accentSoft))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.bold))
                Text(subtitle).font(.caption).foregroundStyle(Theme.subtle)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.surface)
        )
    }

    private var attendeeGrid: some View {
        let g = liveGame
        let attendees = store.attendees(of: g)
        let cols = [GridItem(.adaptive(minimum: 70, maximum: 90), spacing: 10)]
        return LazyVGrid(columns: cols, spacing: 14) {
            ForEach(attendees) { u in
                VStack(spacing: 6) {
                    Avatar(user: u, size: 54)
                    Text(u.name.split(separator: " ").first.map(String.init) ?? u.name)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.primary)
                        .lineLimit(1)
                }
            }
            // Empty seats
            ForEach(0..<g.spotsLeft, id: \.self) { _ in
                VStack(spacing: 6) {
                    Circle()
                        .strokeBorder(Theme.hairline, style: StrokeStyle(lineWidth: 1.5, dash: [4,4]))
                        .frame(width: 54, height: 54)
                        .overlay(
                            Image(systemName: "plus")
                                .foregroundStyle(Theme.subtle)
                        )
                    Text("Open")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.subtle)
                }
            }
        }
    }

    private func hostBlock(host: HuddleUser) -> some View {
        HStack(spacing: 12) {
            Avatar(user: host, size: 48)
            VStack(alignment: .leading, spacing: 2) {
                Text("Hosted by \(host.name)")
                    .font(.subheadline.weight(.bold))
                Text("\(host.handle) • \(host.skill.title)")
                    .font(.caption)
                    .foregroundStyle(Theme.subtle)
            }
            Spacer()
            Button {
                // future: open profile
            } label: {
                Text("Message").font(.caption.weight(.bold))
            }
            .buttonStyle(SoftButtonStyle())
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.surface)
        )
    }

    private func spotMap(spot: Spot) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("The spot")
                .font(.title3.weight(.bold))
            Map(initialPosition: .region(MKCoordinateRegion(
                center: spot.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
            ))) {
                Annotation(spot.name, coordinate: spot.coordinate) {
                    ZStack {
                        Circle().fill(Theme.accent).frame(width: 36, height: 36)
                            .shadow(color: Theme.primary.opacity(0.25), radius: 6, y: 3)
                        Text(liveGame.sport.emoji).font(.system(size: 18))
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .allowsHitTesting(false)
        }
    }

    // MARK: - Sticky CTA

    private var stickyCTA: some View {
        let g = liveGame
        let attending = store.isAttending(g)
        return VStack(spacing: 0) {
            Divider().opacity(0.4)
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(HuddleFormat.relativeDay(g.startTime))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.subtle)
                    Text(HuddleFormat.timeOnly.string(from: g.startTime))
                        .font(.title3.weight(.heavy))
                }
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        store.toggleRSVP(g.id)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: attending ? "checkmark.circle.fill" : "hand.raised.fill")
                        Text(ctaTitle(attending: attending, full: g.isFull))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(RSVPButtonStyle(state: attending ? .joined : (g.isFull ? .full : .open)))
                .disabled(g.isFull && !attending)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 22)
            .background(.regularMaterial)
        }
    }

    private func ctaTitle(attending: Bool, full: Bool) -> String {
        if attending { return "You're in" }
        if full      { return "Game full" }
        return "I'm in"
    }
}

private struct RSVPButtonStyle: ButtonStyle {
    enum State { case open, joined, full }
    let state: State
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(foreground)
            .padding(.vertical, 16)
            .padding(.horizontal, 22)
            .background(Capsule().fill(background))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
    private var background: Color {
        switch state {
        case .open:   return Theme.accent
        case .joined: return Theme.success
        case .full:   return Theme.surfaceAlt
        }
    }
    private var foreground: Color {
        state == .full ? Theme.subtle : .white
    }
}

#Preview {
    NavigationStack {
        let store = HuddleStore()
        GameDetailView(game: store.games[0])
            .environment(store)
    }
}
