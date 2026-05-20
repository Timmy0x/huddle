import SwiftUI

struct LocationPrimingView: View {
    @Environment(HuddleStore.self) private var store

    var body: some View {
        Group {
            ZStack {
                // Atmospheric backdrop using palette only
                LinearGradient(
                    colors: [Theme.accent, Theme.primary],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            
                // Soft glow disks
                Circle().fill(.white.opacity(0.10)).frame(width: 340, height: 340)
                    .offset(x: -140, y: -260).blur(radius: 12)
                Circle().fill(.white.opacity(0.08)).frame(width: 260, height: 260)
                    .offset(x: 160, y: 280).blur(radius: 10)
            
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
            
                    // Stacked emoji "map pins" — the signature opener.
                    ZStack {
                        pin(emoji: "🏀", angle: -14, offsetX: -90, offsetY: -8, scale: 1.0)
                        pin(emoji: "⚽️", angle: 8,  offsetX:  90, offsetY: 18, scale: 0.95)
                        pin(emoji: "🏓", angle: -4, offsetX:  -8, offsetY: -70, scale: 0.88)
                        pin(emoji: "🏃", angle: 12, offsetX: 110, offsetY: -80, scale: 0.82)
                        pin(emoji: "🏐", angle: -10, offsetX: -110, offsetY: 80, scale: 0.82)
                    }
                    .frame(height: 240)
            
                    Spacer(minLength: 0)
            
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Find pickup games\nhappening near you.")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
            
                        Text("Huddle uses your location to show games on courts and fields close by — and to surface the spots where regulars actually play.")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .padding(.horizontal, 28)
            
                    VStack(spacing: 12) {
                        Button {
                            store.hasSeenLocationPriming = true
                        } label: {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("Turn on location")
                            }
                        }
                        .buttonStyle(ContrastButtonStyle())
            
                        Button {
                            store.hasSeenLocationPriming = true
                        } label: {
                            Text("Not now")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(.vertical, 10)
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 28)
                    .padding(.bottom, 18)
                }
            }
        }
        .trackView("LocationPrimingView")
    }

    @ViewBuilder
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
}

private struct ContrastButtonStyle: ButtonStyle {
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
    LocationPrimingView().environment(HuddleStore())
}
