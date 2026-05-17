import SwiftUI

struct HostGameView: View {
    @Environment(HuddleStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var sport: Sport = .basketball
    @State private var spotId: UUID? = nil
    @State private var startTime: Date = defaultStart()
    @State private var durationMinutes: Int = 90
    @State private var maxPlayers: Int = 10
    @State private var skill: SkillLevel = .casual
    @State private var notes: String = ""

    static func defaultStart() -> Date {
        let cal = Calendar.current
        let next = cal.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
        // Round to next half hour
        let minute = cal.component(.minute, from: next)
        let add = (30 - (minute % 30)) % 30
        return cal.date(byAdding: .minute, value: add, to: next) ?? next
    }

    private var availableSpots: [Spot] {
        store.spots.filter { $0.sports.contains(sport) }
    }

    private var canSave: Bool { spotId != nil }

    var body: some View {
        Group {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 26) {
                        // Sport picker — the signature host move
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Pick a sport").font(.title3.weight(.bold))
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 72), spacing: 10)], spacing: 14) {
                                ForEach(Sport.allCases) { s in
                                    Button {
                                        withAnimation(.snappy) {
                                            sport = s
                                            if let firstSpot = availableSpots.first {
                                                spotId = firstSpot.id
                                            } else {
                                                spotId = nil
                                            }
                                        }
                                    } label: {
                                        SportChip(sport: s, selected: sport == s)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
            
                        // Spot picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Where").font(.title3.weight(.bold))
                            VStack(spacing: 8) {
                                ForEach(availableSpots) { spot in
                                    Button {
                                        spotId = spot.id
                                    } label: {
                                        spotRow(spot)
                                    }
                                    .buttonStyle(.plain)
                                }
                                if availableSpots.isEmpty {
                                    Text("No saved spots for this sport yet.")
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.subtle)
                                        .padding(.vertical, 12)
                                }
                            }
                        }
            
                        // When
                        VStack(alignment: .leading, spacing: 10) {
                            Text("When").font(.title3.weight(.bold))
                            VStack(spacing: 0) {
                                DatePicker("Start", selection: $startTime,
                                           in: Date()...,
                                           displayedComponents: [.date, .hourAndMinute])
                                    .padding(.horizontal, 14).padding(.vertical, 10)
                                Divider().padding(.leading, 14)
                                HStack {
                                    Text("Duration")
                                    Spacer()
                                    Stepper(value: $durationMinutes, in: 30...240, step: 15) {
                                        Text("\(durationMinutes) min")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(Theme.primary)
                                    }
                                    .labelsHidden()
                                    Text("\(durationMinutes) min")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Theme.primary)
                                        .frame(width: 72, alignment: .trailing)
                                }
                                .padding(.horizontal, 14).padding(.vertical, 12)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.surface)
                            )
                        }
            
                        // Max players
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Crew size").font(.title3.weight(.bold))
                            HStack {
                                Text("\(maxPlayers) players max")
                                    .font(.subheadline.weight(.semibold))
                                Spacer()
                                Stepper("", value: $maxPlayers, in: 2...30)
                                    .labelsHidden()
                            }
                            .padding(.horizontal, 14).padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.surface)
                            )
                        }
            
                        // Skill
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Vibe").font(.title3.weight(.bold))
                            HStack(spacing: 8) {
                                ForEach(SkillLevel.allCases) { lvl in
                                    Button { skill = lvl } label: {
                                        VStack(spacing: 4) {
                                            Text(lvl.title)
                                                .font(.subheadline.weight(.bold))
                                            Text(lvl.blurb)
                                                .font(.caption2)
                                                .multilineTextAlignment(.center)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .foregroundStyle(skill == lvl ? .white : Theme.primary)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(skill == lvl ? Theme.accent : Theme.surface)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(skill == lvl ? .clear : Theme.hairline, lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
            
                        // Notes
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Notes (optional)").font(.title3.weight(.bold))
                            ZStack(alignment: .topLeading) {
                                if notes.isEmpty {
                                    Text("Bring two shirts. Winners stay. Etc.")
                                        .foregroundStyle(Theme.subtle)
                                        .padding(.horizontal, 14).padding(.top, 12)
                                }
                                TextEditor(text: $notes)
                                    .padding(.horizontal, 10).padding(.vertical, 6)
                                    .scrollContentBackground(.hidden)
                                    .frame(minHeight: 90)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.surface)
                            )
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 100)
                }
                .background(Theme.background.ignoresSafeArea())
                .navigationTitle("Host a game")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    Button {
                        guard let spotId else { return }
                        _ = store.hostGame(sport: sport, spotId: spotId,
                                           startTime: startTime, durationMinutes: durationMinutes,
                                           maxPlayers: maxPlayers, skill: skill, notes: notes)
                        dismiss()
                    } label: {
                        Text("Post game")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .opacity(canSave ? 1 : 0.5)
                    .disabled(!canSave)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    .background(.regularMaterial)
                }
                .onAppear {
                    if spotId == nil { spotId = availableSpots.first?.id }
                }
            }
        }
        .trackView("HostGameView")
    }

    private func spotRow(_ spot: Spot) -> some View {
        let selected = spotId == spot.id
        return HStack(spacing: 14) {
            Image(systemName: "mappin.and.ellipse")
                .font(.headline)
                .foregroundStyle(selected ? .white : Theme.accent)
                .frame(width: 40, height: 40)
                .background(Circle().fill(selected ? Theme.accent : Theme.accentSoft))
            VStack(alignment: .leading, spacing: 2) {
                Text(spot.name).font(.subheadline.weight(.bold))
                Text(spot.neighborhood).font(.caption).foregroundStyle(Theme.subtle)
            }
            Spacer()
            if selected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Theme.accent)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Theme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(selected ? Theme.accent : .clear, lineWidth: 2)
        )
    }
}

#Preview {
    HostGameView().environment(HuddleStore())
}
