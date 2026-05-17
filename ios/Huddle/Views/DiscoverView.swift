import SwiftUI
import MapKit

struct DiscoverView: View {
    @Environment(HuddleStore.self) private var store
    @Binding var showHost: Bool

    @State private var viewMode: ViewMode = .list
    @State private var selectedGameId: UUID? = nil
    @State private var navGameId: UUID? = nil

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.7295, longitude: -73.9700),
            span: MKCoordinateSpan(latitudeDelta: 0.10, longitudeDelta: 0.10)
        )
    )

    enum ViewMode: String, CaseIterable { case list, map }

    var body: some View {
        Group {
            @Bindable var store = store
            NavigationStack {
                ZStack(alignment: .top) {
                    Theme.surface.ignoresSafeArea()
            
                    if viewMode == .list {
                        listLayout
                    } else {
                        mapLayout
                    }
                }
                .navigationTitle("Tonight")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showHost = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.headline)
                        }
                        .accessibilityLabel("Host a game")
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                viewMode = (viewMode == .list) ? .map : .list
                            }
                        } label: {
                            Image(systemName: viewMode == .list ? "map" : "list.bullet")
                                .font(.headline)
                        }
                        .accessibilityLabel(viewMode == .list ? "Switch to map" : "Switch to list")
                    }
                }
                .navigationDestination(item: $navGameId) { id in
                    if let game = store.game(id) {
                        GameDetailView(game: game)
                    }
                }
            }
        }
        .trackView("DiscoverView")
    }

    // MARK: - List layout

    private var listLayout: some View {
        @Bindable var store = store
        return ScrollView {
            VStack(spacing: 18) {
                // Time window scroller
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(HuddleStore.TimeWindowFilter.allCases) { tw in
                            Button {
                                withAnimation(.snappy) { store.timeWindow = tw }
                            } label: {
                                Text(tw.rawValue)
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .foregroundStyle(store.timeWindow == tw ? .white : Theme.primary)
                                    .background(
                                        Capsule().fill(store.timeWindow == tw ? Theme.primary : .white)
                                    )
                                    .overlay(Capsule().stroke(Theme.hairline, lineWidth: store.timeWindow == tw ? 0 : 1))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Sport filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Sport.allCases) { sport in
                            Button {
                                withAnimation(.snappy) {
                                    if store.selectedSports.contains(sport) {
                                        store.selectedSports.remove(sport)
                                    } else {
                                        store.selectedSports.insert(sport)
                                    }
                                }
                            } label: {
                                SportPill(sport: sport, selected: store.selectedSports.contains(sport))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Hero strip — first game gets bigger treatment
                let games = store.filteredGames
                if games.isEmpty {
                    emptyState
                        .padding(.top, 60)
                } else {
                    LazyVStack(spacing: 14) {
                        ForEach(games) { game in
                            if let spot = store.spot(of: game),
                               let host = store.host(of: game) {
                                Button {
                                    navGameId = game.id
                                } label: {
                                    GameCard(
                                        game: game,
                                        spot: spot,
                                        host: host,
                                        attendees: store.attendees(of: game)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                Color.clear.frame(height: 30)
            }
            .padding(.top, 4)
        }
    }

    // MARK: - Map layout

    private var mapLayout: some View {
        let games = store.filteredGames
        return ZStack(alignment: .bottom) {
            Map(position: $cameraPosition) {
                ForEach(games) { game in
                    if let spot = store.spot(of: game) {
                        Annotation(spot.name, coordinate: spot.coordinate) {
                            Button {
                                selectedGameId = game.id
                            } label: {
                                MapSportPin(sport: game.sport,
                                            selected: selectedGameId == game.id)
                            }
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
            .ignoresSafeArea(edges: .bottom)

            // Bottom sheet of games
            MapBottomSheet(games: games, selectedGameId: $selectedGameId) { id in
                navGameId = id
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "sportscourt")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Theme.accent)
                .padding(22)
                .background(Circle().fill(Theme.accentSoft))
            Text("Nothing nearby in that window")
                .font(.title3.weight(.semibold))
            Text("Try a different sport or time — or be the one who starts something.")
                .font(.subheadline)
                .foregroundStyle(Theme.subtle)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Host a game") { showHost = true }
                .buttonStyle(PrimaryButtonStyle(fullWidth: false))
                .padding(.top, 4)
        }
    }
}

// MARK: - Map pin

private struct MapSportPin: View {
    let sport: Sport
    let selected: Bool
    var body: some View {
        ZStack {
            Circle()
                .fill(selected ? Theme.accent : .white)
                .frame(width: selected ? 48 : 42, height: selected ? 48 : 42)
                .shadow(color: Theme.primary.opacity(0.25), radius: 8, x: 0, y: 3)
            Text(sport.emoji).font(.system(size: selected ? 24 : 20))
        }
        .overlay(alignment: .bottom) {
            Triangle()
                .fill(selected ? Theme.accent : .white)
                .frame(width: 12, height: 8)
                .offset(y: 6)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selected)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Bottom sheet

private struct MapBottomSheet: View {
    @Environment(HuddleStore.self) private var store
    let games: [Game]
    @Binding var selectedGameId: UUID?
    var onOpen: (UUID) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Theme.hairline)
                .frame(width: 40, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 10)

            HStack {
                Text("\(games.count) games nearby")
                    .font(.headline)
                Spacer()
                Text("Tap a pin")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.subtle)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(games) { g in
                        if let spot = store.spot(of: g), let host = store.host(of: g) {
                            Button {
                                onOpen(g.id)
                            } label: {
                                GameCard(game: g, spot: spot, host: host,
                                         attendees: store.attendees(of: g),
                                         compact: true)
                                    .frame(width: 320)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                                            .stroke(selectedGameId == g.id ? Theme.accent : .clear,
                                                    lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                            .id(g.id)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 18)
            }
        }
        .background(
            UnevenRoundedRectangle(
                cornerRadii: .init(topLeading: 28, topTrailing: 28),
                style: .continuous
            )
            .fill(Color.white)
            .shadow(color: Theme.primary.opacity(0.10), radius: 20, x: 0, y: -6)
        )
    }
}

#Preview {
    DiscoverView(showHost: .constant(false)).environment(HuddleStore())
}
