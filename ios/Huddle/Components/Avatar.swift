import SwiftUI

struct Avatar: View {
    let user: HuddleUser
    var size: CGFloat = 36
    var ring: Bool = false

    var body: some View {
        Text(user.initials)
            .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(
                LinearGradient(
                    colors: [user.avatarColor, user.avatarColor.opacity(0.75)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                in: Circle()
            )
            .overlay(
                Circle().stroke(ring ? Color.white : .clear, lineWidth: 2)
            )
    }
}

struct AvatarStack: View {
    let users: [HuddleUser]
    var size: CGFloat = 28
    var maxShown: Int = 4

    var body: some View {
        HStack(spacing: -size * 0.32) {
            ForEach(users.prefix(maxShown)) { u in
                Avatar(user: u, size: size, ring: true)
            }
            if users.count > maxShown {
                Text("+\(users.count - maxShown)")
                    .font(.system(size: size * 0.35, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.primary)
                    .frame(width: size, height: size)
                    .background(Theme.surface, in: Circle())
                    .overlay(Circle().stroke(.white, lineWidth: 2))
            }
        }
    }
}

#Preview {
    let store = HuddleStore()
    return VStack(spacing: 24) {
        Avatar(user: store.users[1], size: 64)
        AvatarStack(users: Array(store.users.prefix(5)))
    }
    .padding()
}
