import SwiftUI

struct ProfileView: View {
    @Environment(HuddleStore.self) private var store
    @State private var editing = false

    private var me: HuddleUser { store.currentUser }

    var body: some View {
        Group {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
                        header
            
                        statRow
            
                        sports
            
                        regularSpots
            
                        settings
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 30)
                }
                .background(Theme.surface.ignoresSafeArea())
                .navigationTitle("Profile")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            editing = true
                        } label: {
                            Image(systemName: "pencil")
                        }
                    }
                }
                .sheet(isPresented: $editing) { EditProfileSheet() }
            }
        }
        .trackView("ProfileView")
    }

    private var header: some View {
        VStack(spacing: 14) {
            ZStack(alignment: .bottomTrailing) {
                Avatar(user: me, size: 96)
                Image(systemName: "camera.fill")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Theme.accent))
                    .overlay(Circle().stroke(.white, lineWidth: 2))
            }
            VStack(spacing: 2) {
                Text(me.name)
                    .font(.title2.weight(.bold))
                Text(me.handle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.subtle)
            }
            HStack(spacing: 8) {
                Text(me.skill.title)
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Capsule().fill(Theme.accentSoft))
                    .foregroundStyle(Theme.accent)
                Text("• \(store.myPastGames.count) games played")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.subtle)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
    }

    private var statRow: some View {
        HStack(spacing: 10) {
            statTile(icon: "figure.basketball",
                     value: "\(store.myUpcomingGames.count)", label: "Upcoming")
            statTile(icon: "checkmark.seal.fill",
                     value: "\(store.myPastGames.count)", label: "Played")
            statTile(icon: "mappin.and.ellipse",
                     value: "\(store.regularSpots(for: me).count)", label: "Regular at")
        }
    }

    private func statTile(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(Theme.accent)
            Text(value)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Theme.subtle)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Theme.hairline, lineWidth: 1)
        )
    }

    private var sports: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sports I play")
                .font(.title3.weight(.bold))
            FlowRow(spacing: 8) {
                ForEach(me.sports) { s in
                    SportPill(sport: s, selected: true)
                }
            }
        }
    }

    private var regularSpots: some View {
        let spots = store.regularSpots(for: me)
        return VStack(alignment: .leading, spacing: 10) {
            Text("Regular spots")
                .font(.title3.weight(.bold))
            if spots.isEmpty {
                Text("Play a few games at the same court and you'll show up here as a regular.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.subtle)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Theme.hairline, lineWidth: 1)
                    )
            } else {
                VStack(spacing: 10) {
                    ForEach(spots) { spot in
                        spotRow(spot)
                    }
                }
            }
        }
    }

    private func spotRow(_ spot: Spot) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Theme.accentSoft).frame(width: 44, height: 44)
                Image(systemName: "mappin").foregroundStyle(Theme.accent)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(spot.name).font(.subheadline.weight(.bold))
                Text(spot.neighborhood).font(.caption).foregroundStyle(Theme.subtle)
            }
            Spacer()
            HStack(spacing: -6) {
                ForEach(spot.sports.prefix(3), id: \.self) { s in
                    Text(s.emoji).font(.system(size: 14))
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(Theme.surface))
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Theme.hairline, lineWidth: 1)
        )
    }

    private var settings: some View {
        VStack(spacing: 0) {
            settingsRow(icon: "bell.fill", title: "Notifications")
            Divider().padding(.leading, 58)
            settingsRow(icon: "location.fill", title: "Location")
            Divider().padding(.leading, 58)
            settingsRow(icon: "questionmark.circle.fill", title: "Help & feedback")
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Theme.hairline, lineWidth: 1)
        )
    }

    private func settingsRow(icon: String, title: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(Theme.accent)
                .frame(width: 32, height: 32)
                .background(Circle().fill(Theme.accentSoft))
            Text(title).font(.subheadline.weight(.semibold))
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(Theme.subtle)
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - Edit profile sheet (simple)

private struct EditProfileSheet: View {
    @Environment(HuddleStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var sports: Set<Sport> = []
    @State private var skill: SkillLevel = .casual

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name").font(.subheadline.weight(.bold))
                        TextField("Your name", text: $name)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, 14).padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Theme.surface))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sports").font(.subheadline.weight(.bold))
                        FlowRow(spacing: 8) {
                            ForEach(Sport.allCases) { s in
                                Button {
                                    if sports.contains(s) { sports.remove(s) } else { sports.insert(s) }
                                } label: {
                                    SportPill(sport: s, selected: sports.contains(s))
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default skill").font(.subheadline.weight(.bold))
                        HStack(spacing: 8) {
                            ForEach(SkillLevel.allCases) { lvl in
                                Button { skill = lvl } label: {
                                    Text(lvl.title)
                                        .font(.subheadline.weight(.bold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .foregroundStyle(skill == lvl ? .white : Theme.primary)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .fill(skill == lvl ? Theme.accent : Theme.surface)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Edit profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        if let idx = store.users.firstIndex(where: { $0.id == store.currentUserId }) {
                            store.users[idx].name = name.isEmpty ? store.users[idx].name : name
                            store.users[idx].sports = Sport.allCases.filter { sports.contains($0) }
                            store.users[idx].skill = skill
                        }
                        dismiss()
                    }
                    .font(.headline)
                }
            }
            .onAppear {
                name = store.currentUser.name
                sports = Set(store.currentUser.sports)
                skill = store.currentUser.skill
            }
        }
    }
}

// MARK: - FlowRow

struct FlowRow<Content: View>: View {
    var spacing: CGFloat = 8
    @ViewBuilder var content: Content
    var body: some View {
        FlowLayout(spacing: spacing) { content }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var rows: [[CGSize]] = [[]]
        var rowWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

        for sv in subviews {
            let s = sv.sizeThatFits(.unspecified)
            if rowWidth + s.width > width, !rows[rows.count - 1].isEmpty {
                totalHeight += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
                rows.append([])
            }
            rows[rows.count - 1].append(s)
            rowWidth += s.width + spacing
            rowHeight = max(rowHeight, s.height)
        }
        totalHeight += rowHeight
        return CGSize(width: width == .infinity ? rowWidth : width, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for sv in subviews {
            let s = sv.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            sv.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(s))
            x += s.width + spacing
            rowHeight = max(rowHeight, s.height)
        }
    }
}

#Preview {
    ProfileView().environment(HuddleStore())
}
