import SwiftUI
import Charts

struct UsageCard: View {
    let state: DashboardState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Usage — 7 Days").font(Theme.cardTitle).foregroundStyle(Theme.textMuted)
            if case .error(let msg) = state.usageState {
                Label(msg, systemImage: "wifi.slash")
                    .font(Theme.meta).foregroundStyle(Theme.warn)
            }
            Chart(state.usageDays) { day in
                BarMark(x: .value("Day", String(day.date.suffix(2))),
                        y: .value("Tokens", day.tokens ?? 0))
                    .foregroundStyle(Theme.accent)
                    .cornerRadius(3)
            }
            .chartXAxis(.hidden).chartYAxis(.hidden)
            .frame(height: 56)
            HStack(alignment: .firstTextBaseline) {
                if let cost = state.totalCost {
                    Text(cost, format: .currency(code: "EUR"))
                        .font(Theme.bigNumber).foregroundStyle(Theme.money)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    if let reqs = state.totalRequests {
                        Text("\(reqs) requests")
                    }
                    if let toks = state.totalTokens {
                        Text("\(toks.formatted(.number.notation(.compactName))) tokens")
                    }
                }
                .font(Theme.meta).foregroundStyle(Theme.textMuted)
            }
        }
        .cardStyle()
    }
}
