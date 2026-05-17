import SwiftUI

enum Theme {
    static let primary    = Color(hex: 0x0B1220)
    static let accent     = Color(hex: 0x2563EB)
    static let accentSoft = Color(hex: 0xDCE6FB)
    static let background = Color(hex: 0xFFFFFF)
    static let surface    = Color(hex: 0xF4F7FB)
    static let surfaceAlt = Color(hex: 0xEAEFF6)
    static let text       = Color(hex: 0x0B1220)
    static let subtle     = Color(hex: 0x6B7280)
    static let hairline   = Color(hex: 0xE5EAF1)

    // Semantic accents kept inside-palette: shades/tints of the same blue + neutrals.
    static let success    = Color(hex: 0x16A34A) // status only — confirmed RSVP
    static let warning    = Color(hex: 0xF59E0B) // limited use — "almost full"
}

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >>  8) & 0xFF) / 255
        let b = Double( hex        & 0xFF) / 255
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

// MARK: - Reusable styles

struct PrimaryButtonStyle: ButtonStyle {
    var fullWidth: Bool = true
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.vertical, 16)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, fullWidth ? 0 : 24)
            .background(
                Capsule().fill(Theme.accent)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct SoftButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.primary)
            .padding(.vertical, 12)
            .padding(.horizontal, 18)
            .background(
                Capsule().fill(Theme.surface)
            )
            .overlay(
                Capsule().stroke(Theme.hairline, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
