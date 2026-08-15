import SwiftUI

struct ErrorsCard: View {
    let state: DashboardState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Errors").font(Theme.cardTitle).foregroundStyle(Theme.textMuted)
            if state.errors.isEmpty {
                Text("No recent errors")
                    .font(Theme.meta).foregroundStyle(Theme.textMuted)
            }
            ForEach(state.errors.prefix(5)) { e in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("ERR").font(Theme.meta)
                        .padding(.horizontal, 6).padding(.vertical, 1)
                        .background(Theme.error.opacity(0.15))
                        .foregroundStyle(Theme.error).clipShape(Capsule())
                    Text(e.message).font(Theme.body)
                        .foregroundStyle(Theme.textPrimary).lineLimit(2)
                    Spacer()
                    if let t = e.timestamp {
                        Text(t.formatted(date: .omitted, time: .shortened))
                            .font(Theme.meta).foregroundStyle(Theme.textMuted)
                    }
                }
            }
        }
        .cardStyle()
    }
}
