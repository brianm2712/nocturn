import SwiftUI

struct ProfilesCard: View {
    let state: DashboardState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Profiles").font(Theme.cardTitle).foregroundStyle(Theme.textMuted)
                if case .error(let msg) = state.profilesState {
                    Spacer()
                    Label(msg, systemImage: "wifi.slash")
                        .font(Theme.meta).foregroundStyle(Theme.warn)
                }
            }
            if state.profiles.isEmpty {
                Text("No profiles found")
                    .font(Theme.meta).foregroundStyle(Theme.textMuted)
            }
            ForEach(state.profiles) { profile in
                HStack(spacing: 10) {
                    // Gateway status LED
                    Circle()
                        .fill(profile.gatewayRunning == true ? Theme.ok : Theme.error)
                        .frame(width: 8, height: 8)
                    VStack(alignment: .leading, spacing: 1) {
                        HStack {
                            Text(profile.name)
                                .font(Theme.body)
                                .foregroundStyle(Theme.textPrimary)
                            if profile.isDefault {
                                Text("default")
                                    .font(Theme.meta)
                                    .padding(.horizontal, 5).padding(.vertical, 1)
                                    .background(Theme.accent.opacity(0.15))
                                    .foregroundStyle(Theme.accent)
                                    .clipShape(Capsule())
                            }
                        }
                        if let model = profile.model, !model.isEmpty {
                            Text(model)
                                .font(Theme.meta).foregroundStyle(Theme.textMuted)
                        } else if let desc = profile.description, !desc.isEmpty {
                            Text(desc)
                                .font(Theme.meta).foregroundStyle(Theme.textMuted)
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                    if let provider = profile.provider, !provider.isEmpty {
                        Text(provider)
                            .font(Theme.meta)
                            .foregroundStyle(Theme.textMuted)
                    }
                    if let skills = profile.skillCount, skills > 0 {
                        Label("\(skills)", systemImage: "book.closed")
                            .font(Theme.meta).foregroundStyle(Theme.textMuted)
                    }
                }
            }
        }
        .cardStyle()
    }
}
