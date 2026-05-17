import SwiftUI

struct OnboardingFlow: View {
    @Environment(HuddleStore.self) private var store

    @State private var step: Int = 0
    @State private var name: String = ""
    @State private var handle: String = ""
    @State private var analyzing: Bool = false
    @State private var analyzeProgress: Double = 0

    private let totalSteps = 9 // progress-bar steps (welcome excluded)

    var body: some View {
        Group {
            ZStack {
                backdrop
                VStack(spacing: 0) {
                    if step > 0 && step < 10 {
                        progressBar
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 6)
                    }
                    content
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .preferredColorScheme(step == 0 ? .dark : .light)
            .animation(.easeInOut(duration: 0.3), value: step)
        }
        .trackView("OnboardingFlow")
    }

    // MARK: - Background

    @ViewBuilder
    private var backdrop: some View {
        if step == 0 {
            LinearGradient(colors: [Theme.accent, Theme.primary],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            Circle().fill(.white.opacity(0.10)).frame(width: 360, height: 360)
                .offset(x: -140, y: -280).blur(radius: 14)
            Circle().fill(.white.opacity(0.08)).frame(width: 280, height: 280)
                .offset(x: 160, y: 300).blur(radius: 12)
        } else {
            Theme.background.ignoresSafeArea()
        }
    }

    // MARK: - Progress bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.surfaceAlt).frame(height: 6)
                Capsule().fill(Theme.accent)
                    .frame(width: max(12, geo.size.width * progressFraction), height: 6)
                    .animation(.spring(response: 0.45, dampingFraction: 0.8), value: step)
            }
        }
        .frame(height: 6)
    }

    private var progressFraction: Double {
        Double(min(step, totalSteps)) / Double(totalSteps)
    }

    // MARK: - Step router

    @ViewBuilder
    private var content: some View {
        switch step {
        case 0: welcomeStep
        case 1: sportsStep
        case 2: skillStep
        case 3: frequencyStep
        case 4: neighborhoodStep
        case 5: socialProofStep
        case 6: notificationsStep
        case 7: locationStep
        case 8: analyzingStep
        case 9: revealStep
        case 10: nameStep
        default: welcomeStep
        }
    }

    // MARK: - Step 0: Welcome (full-bleed)

    private var welcomeStep: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            ZStack {
                pin(emoji: "🏀", angle: -14, offsetX: -90, offsetY: -8, scale: 1.0)
                pin(emoji: "⚽️", angle: 8,  offsetX:  90, offsetY: 18, scale: 0.95)
                pin(emoji: "🏓", angle: -4, offsetX:  -8, offsetY: -78, scale: 0.88)
                pin(emoji: "🏃", angle: 12, offsetX: 110, offsetY: -82, scale: 0.82)
                pin(emoji: "🏐", angle: -10, offsetX: -110, offsetY: 80, scale: 0.82)
            }
            .frame(height: 240)

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 14) {
                Text("Pickup games,\nright around you.")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Find a court, grab a spot, show up. No leagues, no commitment — just play.")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding(.horizontal, 28)

            VStack(spacing: 12) {
                Button { advance() } label: {
                    Text("Get started")
                }
                .buttonStyle(LightCapsuleStyle())
                Text("Takes 30 seconds.")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.horizontal, 28)
            .padding(.top, 28)
            .padding(.bottom, 22)
        }
    }

    private func pin(emoji: String, angle: Double, offsetX: CGFloat, offsetY: CGFloat, scale: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.white)
                .frame(width: 78, height: 78)
                .shadow(color: Theme.primary.opacity(0.25), radius: 14, x: 0, y: 8)
            Text(emoji).font(.system(size: 38))
        }
        .rotationEffect(.degrees(angle))
        .scaleEffect(scale)
        .offset(x: offsetX, y: offsetY)
    }

    // MARK: - Step 1: Sports (multi-select)

    private var sportsStep: some View {
        QuestionScaffold(
            kicker: "About you",
            title: "What do you play?",
            subtitle: "Pick all that apply. We'll surface games at courts near you.",
            primaryTitle: "Continue",
            primaryEnabled: !store.onboardingSports.isEmpty,
            onPrimary: advance,
            onBack: back
        ) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(Sport.allCases) { sport in
                    SelectTile(
                        emoji: sport.emoji,
                        title: sport.title,
                        selected: store.onboardingSports.contains(sport)
                    ) {
                        if store.onboardingSports.contains(sport) {
                            store.onboardingSports.remove(sport)
                        } else {
                            store.onboardingSports.insert(sport)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Step 2: Skill

    private var skillStep: some View {
        QuestionScaffold(
            kicker: "About you",
            title: "How would you describe your game?",
            subtitle: "We'll match you with games at your speed.",
            primaryTitle: "Continue",
            primaryEnabled: true,
            onPrimary: advance,
            onBack: back
        ) {
            VStack(spacing: 12) {
                ForEach(SkillLevel.allCases) { skill in
                    RowOption(
                        title: skill.title,
                        subtitle: skill.blurb,
                        emoji: emojiForSkill(skill),
                        selected: store.onboardingSkill == skill
                    ) {
                        store.onboardingSkill = skill
                    }
                }
            }
        }
    }

    private func emojiForSkill(_ s: SkillLevel) -> String {
        switch s {
        case .chill: "🧘"
        case .casual: "🤝"
        case .competitive: "🔥"
        }
    }

    // MARK: - Step 3: Frequency

    private var frequencyStep: some View {
        QuestionScaffold(
            kicker: "Your rhythm",
            title: "How often do you want to play?",
            subtitle: "We'll set your default reminders around it.",
            primaryTitle: "Continue",
            primaryEnabled: true,
            onPrimary: advance,
            onBack: back
        ) {
            VStack(spacing: 12) {
                ForEach(HuddleStore.PlayFrequency.allCases) { f in
                    RowOption(
                        title: f.rawValue,
                        subtitle: subtitleForFrequency(f),
                        emoji: f.emoji,
                        selected: store.onboardingFrequency == f
                    ) {
                        store.onboardingFrequency = f
                    }
                }
            }
        }
    }

    private func subtitleForFrequency(_ f: HuddleStore.PlayFrequency) -> String {
        switch f {
        case .rarely:  "Casual, when the weather's right"
        case .monthly: "A few times a month"
        case .weekly:  "Most weeks, one or two games"
        case .daily:   "You live at the court"
        }
    }

    // MARK: - Step 4: Neighborhood (text)

    private var neighborhoodStep: some View {
        QuestionScaffold(
            kicker: "Your spot",
            title: "Where are you playing?",
            subtitle: "Type your neighborhood — we'll surface the closest courts and fields.",
            primaryTitle: "Continue",
            primaryEnabled: true, // optional
            onPrimary: advance,
            onBack: back
        ) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Theme.accent)
                    TextField("e.g. Williamsburg", text: Binding(
                        get: { store.onboardingNeighborhood },
                        set: { store.onboardingNeighborhood = $0 }
                    ))
                    .textInputAutocapitalization(.words)
                    .font(.title3.weight(.semibold))
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Theme.hairline, lineWidth: 1)
                )

                Text("Optional. You can skip and we'll use your location instead.")
                    .font(.footnote)
                    .foregroundStyle(Theme.subtle)
            }
        }
    }

    // MARK: - Step 5: Social proof

    private var socialProofStep: some View {
        QuestionScaffold(
            kicker: "Players love Huddle",
            title: "You're in good company.",
            subtitle: nil,
            primaryTitle: "Continue",
            primaryEnabled: true,
            onPrimary: advance,
            onBack: back
        ) {
            VStack(spacing: 14) {
                StatRow()
                TestimonialCard(
                    name: "Marcus, Brooklyn",
                    emoji: "🏀",
                    quote: "Found a 5v5 run two blocks from my apartment in under a minute. Now I play three nights a week."
                )
                TestimonialCard(
                    name: "Priya, Queens",
                    emoji: "🏓",
                    quote: "I'm new to the city and Huddle is how I made my pickleball crew. The regulars are real."
                )
            }
        }
    }

    // MARK: - Step 6: Notifications priming

    private var notificationsStep: some View {
        PrimingStep(
            icon: "bell.badge.fill",
            kicker: "One quick thing",
            title: "Never miss a game.",
            subtitle: "Get a heads-up when a game pops up near you, when a spot opens on a game you saved, or when your crew is rolling.",
            bullets: [
                ("⚡️", "New games near you"),
                ("🔔", "Roster updates on games you join"),
                ("👥", "When your regulars are playing")
            ],
            primary: "Enable notifications",
            secondary: "Maybe later",
            onPrimary: {
                store.notificationsPrimed = true
                advance()
            },
            onSecondary: advance,
            onBack: back
        )
    }

    // MARK: - Step 7: Location priming

    private var locationStep: some View {
        PrimingStep(
            icon: "location.fill",
            kicker: "Last thing",
            title: "Show games near you.",
            subtitle: "Huddle uses your location to surface pickup games on courts and fields close by — and to recommend spots where the regulars actually show up.",
            bullets: [
                ("📍", "Games sorted by distance"),
                ("🗺️", "A live map of nearby spots"),
                ("🔒", "Never shared with other players")
            ],
            primary: "Turn on location",
            secondary: "Not now",
            onPrimary: {
                store.locationPrimed = true
                advance()
            },
            onSecondary: advance,
            onBack: back
        )
    }

    // MARK: - Step 8: Analyzing

    private var analyzingStep: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                Circle()
                    .stroke(Theme.surfaceAlt, lineWidth: 10)
                    .frame(width: 160, height: 160)
                Circle()
                    .trim(from: 0, to: analyzeProgress)
                    .stroke(Theme.accent, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 160, height: 160)
                Text("\(Int(analyzeProgress * 100))%")
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.primary)
                    .contentTransition(.numericText())
            }

            VStack(spacing: 8) {
                Text("Building your Huddle…")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Theme.primary)
                Text(analyzeLine)
                    .font(.subheadline)
                    .foregroundStyle(Theme.subtle)
                    .transition(.opacity)
                    .id(analyzeLine)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear { runAnalyze() }
    }

    @State private var analyzeLineIndex: Int = 0
    private let analyzeLines = [
        "Scanning courts and fields near you…",
        "Matching your sports & skill level…",
        "Finding regulars in your neighborhood…",
        "Pulling games for this week…"
    ]
    private var analyzeLine: String { analyzeLines[min(analyzeLineIndex, analyzeLines.count - 1)] }

    private func runAnalyze() {
        analyzeProgress = 0
        analyzeLineIndex = 0
        Task {
            for i in 1...20 {
                try? await Task.sleep(nanoseconds: 110_000_000)
                withAnimation(.easeInOut(duration: 0.12)) {
                    analyzeProgress = Double(i) / 20.0
                }
                if i % 5 == 0 {
                    withAnimation(.easeInOut) {
                        analyzeLineIndex = min(analyzeLineIndex + 1, analyzeLines.count - 1)
                    }
                }
            }
            try? await Task.sleep(nanoseconds: 250_000_000)
            await MainActor.run { advance() }
        }
    }

    // MARK: - Step 9: Reveal

    private var revealStep: some View {
        let count = max(store.personalizedGameCount, 6)
        let samples = store.personalizedSampleGames
        return VStack(spacing: 0) {
            Spacer(minLength: 8)
            VStack(spacing: 6) {
                Text("Your plan is ready")
                    .font(.caption.weight(.heavy))
                    .tracking(1.5)
                    .foregroundStyle(Theme.accent)
                Text("\(count) games this week")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.primary)
                    .multilineTextAlignment(.center)
                Text("match what you play and how you play.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.subtle)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)

            VStack(spacing: 10) {
                ForEach(Array(samples.enumerated()), id: \.element.id) { _, g in
                    revealRow(for: g)
                }
                if samples.isEmpty {
                    revealEmpty
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 22)

            Spacer()

            VStack(spacing: 10) {
                Button { advance() } label: { Text("See my games") }
                    .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
        }
    }

    @ViewBuilder
    private func revealRow(for g: Game) -> some View {
        let spot = store.spot(of: g)
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(LinearGradient(colors: [Theme.accent, Theme.primary],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 56, height: 56)
                Text(g.sport.emoji).font(.system(size: 26))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(spot?.name ?? g.sport.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Theme.primary)
                    .lineLimit(1)
                Text("\(HuddleFormat.relativeDay(g.startTime)) · \(HuddleFormat.timeOnly.string(from: g.startTime)) · \(spot?.neighborhood ?? "")")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.subtle)
                    .lineLimit(1)
            }
            Spacer()
            Text("\(g.spotsLeft) left")
                .font(.caption.weight(.heavy))
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(Capsule().fill(Theme.accentSoft))
                .foregroundStyle(Theme.accent)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous).fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Theme.hairline, lineWidth: 1)
        )
    }

    private var revealEmpty: some View {
        Text("Fresh games drop every day — check back tomorrow.")
            .font(.subheadline)
            .foregroundStyle(Theme.subtle)
            .padding(20)
    }

    // MARK: - Step 10: Name

    private var nameStep: some View {
        QuestionScaffold(
            kicker: "Almost in",
            title: "What should we call you?",
            subtitle: "This is how you'll show up on the attendee list.",
            primaryTitle: "Start playing",
            primaryEnabled: !name.trimmingCharacters(in: .whitespaces).isEmpty,
            onPrimary: finish,
            onBack: back
        ) {
            VStack(spacing: 12) {
                FieldRow(icon: "person.fill", placeholder: "Your name", text: $name)
                FieldRow(icon: "at", placeholder: "Handle (optional)", text: $handle)
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill").font(.caption2)
                    Text("Now it's time to get in the game. Tap start and we'll drop you straight onto today's board.")
                        .font(.footnote)
                }
                .foregroundStyle(Theme.subtle)
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Nav

    private func advance() {
        withAnimation { step += 1 }
    }
    private func back() {
        withAnimation { step = max(0, step - 1) }
    }
    private func finish() {
        store.completeOnboarding(name: name, handle: handle)
    }
}

// MARK: - Scaffolds & components

private struct QuestionScaffold<Content: View>: View {
    let kicker: String
    let title: String
    let subtitle: String?
    let primaryTitle: String
    let primaryEnabled: Bool
    let onPrimary: () -> Void
    let onBack: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundStyle(Theme.primary)
                        .frame(width: 38, height: 38)
                        .background(Circle().fill(Theme.surface))
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(kicker.uppercased())
                            .font(.caption.weight(.heavy))
                            .tracking(1.4)
                            .foregroundStyle(Theme.accent)
                        Text(title)
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.primary)
                            .fixedSize(horizontal: false, vertical: true)
                        if let subtitle {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundStyle(Theme.subtle)
                        }
                    }
                    content
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 120)
            }

            VStack {
                Button(action: onPrimary) {
                    Text(primaryTitle)
                }
                .buttonStyle(PrimaryButtonStyle())
                .opacity(primaryEnabled ? 1 : 0.45)
                .disabled(!primaryEnabled)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
            .background(
                LinearGradient(colors: [Theme.background.opacity(0), Theme.background],
                               startPoint: .top, endPoint: .bottom)
                    .frame(height: 120)
                    .allowsHitTesting(false),
                alignment: .bottom
            )
        }
    }
}

private struct SelectTile: View {
    let emoji: String
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(emoji).font(.system(size: 36))
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Theme.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(selected ? Theme.accentSoft : Theme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(selected ? Theme.accent : Theme.hairline, lineWidth: selected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct RowOption: View {
    let title: String
    let subtitle: String
    let emoji: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(emoji).font(.system(size: 30))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline).foregroundStyle(Theme.primary)
                    Text(subtitle).font(.footnote).foregroundStyle(Theme.subtle)
                }
                Spacer()
                ZStack {
                    Circle().stroke(selected ? Theme.accent : Theme.hairline, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if selected {
                        Circle().fill(Theme.accent).frame(width: 14, height: 14)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(selected ? Theme.accentSoft.opacity(0.6) : Theme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(selected ? Theme.accent : Theme.hairline, lineWidth: selected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct FieldRow: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(Theme.accent)
                .frame(width: 24)
            TextField(placeholder, text: $text)
                .font(.title3.weight(.semibold))
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Theme.hairline, lineWidth: 1)
        )
    }
}

private struct StatRow: View {
    var body: some View {
        HStack(spacing: 10) {
            stat(value: "42K+", label: "Players")
            stat(value: "1,800", label: "Spots")
            stat(value: "4.9 ★", label: "Avg game")
        }
    }
    private func stat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.primary)
            Text(label).font(.caption.weight(.semibold)).foregroundStyle(Theme.subtle)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.surface))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Theme.hairline, lineWidth: 1))
    }
}

private struct TestimonialCard: View {
    let name: String
    let emoji: String
    let quote: String
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle().fill(Theme.accentSoft).frame(width: 48, height: 48)
                Text(emoji).font(.system(size: 24))
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("\"\(quote)\"")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Theme.primary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 4) {
                    ForEach(0..<5) { _ in
                        Image(systemName: "star.fill").font(.caption2).foregroundStyle(Theme.accent)
                    }
                    Text("— \(name)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.subtle)
                        .padding(.leading, 4)
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.surface))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Theme.hairline, lineWidth: 1))
    }
}

private struct PrimingStep: View {
    let icon: String
    let kicker: String
    let title: String
    let subtitle: String
    let bullets: [(String, String)]
    let primary: String
    let secondary: String
    let onPrimary: () -> Void
    let onSecondary: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.headline).foregroundStyle(Theme.primary)
                        .frame(width: 38, height: 38)
                        .background(Circle().fill(Theme.surface))
                }
                Spacer()
            }
            .padding(.horizontal, 16).padding(.top, 4)

            Spacer(minLength: 10)

            ZStack {
                Circle().fill(Theme.accentSoft).frame(width: 120, height: 120)
                Image(systemName: icon)
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(Theme.accent)
            }

            VStack(spacing: 10) {
                Text(kicker.uppercased())
                    .font(.caption.weight(.heavy)).tracking(1.4)
                    .foregroundStyle(Theme.accent)
                Text(title)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.primary)
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.subtle)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.top, 16)

            VStack(spacing: 12) {
                ForEach(bullets, id: \.1) { b in
                    HStack(spacing: 12) {
                        Text(b.0).font(.title3)
                        Text(b.1)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.primary)
                        Spacer()
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.surface))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Theme.hairline, lineWidth: 1))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 22)

            Spacer()

            VStack(spacing: 8) {
                Button(action: onPrimary) { Text(primary) }
                    .buttonStyle(PrimaryButtonStyle())
                Button(action: onSecondary) {
                    Text(secondary)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.subtle)
                        .padding(.vertical, 10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 18)
        }
    }
}

private struct LightCapsuleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Theme.primary)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Capsule().fill(.white))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    OnboardingFlow().environment(HuddleStore())
}
