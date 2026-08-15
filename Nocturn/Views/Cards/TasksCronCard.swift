import SwiftUI

struct TasksCronCard: View {
    let state: DashboardState

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
                HStack {
                    Image(systemName: job.paused ? "pause.circle" : "clock")
                        .foregroundStyle(job.paused ? Theme.textMuted : Theme.accent)
                    Text(job.name).font(Theme.body).foregroundStyle(Theme.textPrimary)
                    Spacer()
                    if let next = job.nextRun {
                        Text(next.formatted(.relative(presentation: .named)))
                            .font(Theme.meta).foregroundStyle(Theme.textMuted)
                    } else {
                        Text(job.schedule).font(Theme.meta).foregroundStyle(Theme.textMuted)
                    }
                }
            }
        }
        .cardStyle()
    }
}
