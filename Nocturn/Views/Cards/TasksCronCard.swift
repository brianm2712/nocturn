import SwiftUI

struct TasksCronCard: View {
    let state: DashboardState
    var onSelectJob: ((CronRow) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tasks & Cron").font(Theme.cardTitle).foregroundStyle(Theme.textMuted)
            if state.kanbanInstalled {
                HStack {
                    Image(systemName: "square.grid.3x1.below.line.grid.1x2")
                        .foregroundStyle(Theme.accent)
                    Text("Kanban board active").font(Theme.body)
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                }
            }
            if state.cron.isEmpty {
                Text("No scheduled jobs")
                    .font(Theme.meta).foregroundStyle(Theme.textMuted)
            }
            ForEach(state.cron.prefix(6)) { job in
                Button { onSelectJob?(job) } label: {
                    HStack {
                        Image(systemName: job.paused ? "pause.circle" : "clock")
                            .foregroundStyle(job.paused ? Theme.textMuted : Theme.accent)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(job.name).font(Theme.body).foregroundStyle(Theme.textPrimary)
                            if let profile = job.profile {
                                Text(profile)
                                    .font(Theme.meta).foregroundStyle(Theme.textMuted)
                            }
                        }
                        Spacer()
                        if let status = job.lastStatus {
                            Text(status)
                                .font(Theme.meta)
                                .padding(.horizontal, 5).padding(.vertical, 1)
                                .background(statusColor(status).opacity(0.15))
                                .foregroundStyle(statusColor(status))
                                .clipShape(Capsule())
                        }
                        if let next = job.nextRun {
                            Text(next.formatted(.relative(presentation: .named)))
                                .font(Theme.meta).foregroundStyle(Theme.textMuted)
                        } else {
                            Text(job.schedule).font(Theme.meta).foregroundStyle(Theme.textMuted)
                        }
                        Image(systemName: "chevron.right")
                            .font(Theme.meta).foregroundStyle(Theme.textMuted)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .cardStyle()
    }

    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "completed", "ok", "success": return Theme.ok
        case "error", "failed": return Theme.error
        case "running", "active": return Theme.accent
        default: return Theme.warn
        }
    }
}
