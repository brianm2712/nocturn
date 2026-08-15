import SwiftUI

struct LiveAgentsCard: View {
    let state: DashboardState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Live Agents").font(Theme.cardTitle).foregroundStyle(Theme.textMuted)
            if case .error(let msg) = state.agentsState {
                Label(msg, systemImage: "wifi.slash")
                    .font(Theme.meta).foregroundStyle(Theme.warn)
            }
            ForEach(state.agents.prefix(6)) { agent in
                HStack {
                    Image(systemName: agent.sourceIcon)
                        .frame(width: 18)
                        .foregroundStyle(Theme.accent)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(agent.title).font(Theme.body)
                            .foregroundStyle(Theme.textPrimary).lineLimit(1)
                        Text(agent.source).font(Theme.meta)
                            .foregroundStyle(Theme.textMuted)
                    }
                    Spacer()
                    statusTag(agent)
                }
            }
        }
        .cardStyle()
    }

    private func statusTag(_ agent: AgentRow) -> some View {
        Text(agent.isActive ? "working" : relative(agent.lastActivity))
            .font(Theme.meta)
            .padding(.horizontal, 7).padding(.vertical, 2)
            .background((agent.isActive ? Theme.ok : Theme.textMuted).opacity(0.15))
            .foregroundStyle(agent.isActive ? Theme.ok : Theme.textMuted)
            .clipShape(Capsule())
    }

    private func relative(_ date: Date?) -> String {
        guard let date else { return "idle" }
        return "idle \(date.formatted(.relative(presentation: .named)))"
    }
}
