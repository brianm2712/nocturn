import SwiftUI

struct HealthStrip: View {
    let state: DashboardState

    var body: some View {
        HStack(spacing: 14) {
            led(state.gatewayUp == true ? Theme.ok : Theme.error,
                state.gatewayUp == true ? "Gateway UP" : "Gateway DOWN")
            ForEach(state.providers) { p in
                led(p.ok ? Theme.ok : Theme.error,
                    p.ok ? "\(p.name.capitalized) OK"
                         : "\(p.name.capitalized) \(p.detail ?? "ERR")")
            }
            Spacer()
            if let cpu = state.cpuPercent {
                Text("CPU \(Int(cpu))%")
                    .font(Theme.meta).foregroundStyle(Theme.textMuted)
            }
            if let mem = state.memoryUsedBytes {
                Text("MEM \(ByteCountFormatter.string(fromByteCount: mem, countStyle: .memory))")
                    .font(Theme.meta).foregroundStyle(Theme.textMuted)
            }
        }
        .font(Theme.meta)
        .padding(.horizontal, Theme.cardPadding)
        .frame(height: Theme.stripHeight)
        .background(Theme.panel)
    }

    private func led(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).foregroundStyle(Theme.textPrimary)
        }
    }
}
