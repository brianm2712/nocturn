import SwiftUI

struct CronJobDetailView: View {
    let job: CronRow
    @Environment(MonitorStore.self) private var store
    @State private var runs: [SessionInfo] = []
    @State private var selectedRun: SessionInfo?
    @State private var messages: [SessionMessage] = []
    @State private var isLoadingRuns = false
    @State private var isLoadingMessages = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.gridSpacing) {
                // Job header
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: job.paused ? "pause.circle" : "clock")
                            .foregroundStyle(job.paused ? Theme.textMuted : Theme.accent)
                        Text(job.name).font(Theme.bigNumber).foregroundStyle(Theme.textPrimary)
                    }
                    HStack(spacing: 12) {
                        if !job.schedule.isEmpty {
                            Label(job.schedule, systemImage: "calendar")
                                .font(Theme.meta).foregroundStyle(Theme.textMuted)
                        }
                        if let next = job.nextRun {
                            Label("next: \(next.formatted(.relative(presentation: .named)))",
                                  systemImage: "arrow.clockwise")
                                .font(Theme.meta).foregroundStyle(Theme.textMuted)
                        }
                        if let profile = job.profile {
                            Label(profile, systemImage: "person.crop.circle")
                                .font(Theme.meta).foregroundStyle(Theme.textMuted)
                        }
                    }
                    if let status = job.lastStatus {
                        HStack(spacing: 4) {
                            Text("last:").font(Theme.meta).foregroundStyle(Theme.textMuted)
                            Text(status)
                                .font(Theme.meta)
                                .padding(.horizontal, 6).padding(.vertical, 1)
                                .background(statusColor(status).opacity(0.15))
                                .foregroundStyle(statusColor(status))
                                .clipShape(Capsule())
                        }
                    }
                    if let error = job.lastError, !error.isEmpty {
                        Text(error).font(Theme.meta).foregroundStyle(Theme.error)
                            .lineLimit(2)
                    }
                }
                .cardStyle()

                // Runs list
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Runs").font(Theme.cardTitle).foregroundStyle(Theme.textMuted)
                    if isLoadingRuns && runs.isEmpty {
                        ProgressView().tint(Theme.accent)
                    } else if runs.isEmpty {
                        Text("No runs yet").font(Theme.meta).foregroundStyle(Theme.textMuted)
                    }
                    ForEach(runs) { run in
                        Button { Task { await loadMessages(for: run) } } label: {
                            HStack {
                                Image(systemName: run.isActive == true ? "bolt.fill" : "checkmark.circle")
                                    .foregroundStyle(run.isActive == true ? Theme.ok : Theme.textMuted)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(run.title ?? run.id)
                                        .font(Theme.body).foregroundStyle(Theme.textPrimary)
                                        .lineLimit(1)
                                    if let active = run.lastActive {
                                        Text(active.formatted(.relative(presentation: .named)))
                                            .font(Theme.meta).foregroundStyle(Theme.textMuted)
                                    }
                                }
                                Spacer()
                                if let count = run.messageCount {
                                    Text("\(count) msgs")
                                        .font(Theme.meta).foregroundStyle(Theme.textMuted)
                                }
                                Image(systemName: "chevron.right")
                                    .font(Theme.meta).foregroundStyle(Theme.textMuted)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 4)
                        Divider()
                    }
                }
                .cardStyle()

                // Message output
                if !messages.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Output").font(Theme.cardTitle).foregroundStyle(Theme.textMuted)
                            Spacer()
                            if isLoadingMessages {
                                ProgressView().tint(Theme.accent).scaleEffect(0.7)
                            }
                        }
                        ForEach(messages) { msg in
                            MessageBubble(message: msg)
                        }
                    }
                    .cardStyle()
                }
            }
            .padding(Theme.gridSpacing)
        }
        .background(Theme.background)
        .navigationTitle(job.name)
        #if os(macOS)
        .navigationSubtitle(job.schedule)
        #endif
        .task { await loadRuns() }
    }

    private func loadRuns() async {
        isLoadingRuns = true
        if store.settings.demoMode {
            runs = DemoData.cronRuns
        } else {
            runs = await store.loadCronRuns(jobId: job.id, profile: job.profile)
        }
        isLoadingRuns = false
    }

    private func loadMessages(for run: SessionInfo) async {
        isLoadingMessages = true
        selectedRun = run
        if store.settings.demoMode {
            messages = DemoData.cronMessages
        } else {
            messages = await store.loadMessages(sessionId: run.id)
        }
        isLoadingMessages = false
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

struct MessageBubble: View {
    let message: SessionMessage

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(message.role.capitalized)
                    .font(Theme.meta)
                    .foregroundStyle(roleColor)
                if let tool = message.toolName {
                    Text("→ \(tool)")
                        .font(Theme.meta)
                        .foregroundStyle(Theme.accent)
                }
                Spacer()
                if let ts = message.timestamp {
                    Text(ts.formatted(date: .omitted, time: .shortened))
                        .font(Theme.meta).foregroundStyle(Theme.textMuted)
                }
            }
            if let content = message.content, !content.isEmpty {
                Text(content)
                    .font(Theme.body)
                    .foregroundStyle(Theme.textPrimary)
                    .textSelection(.enabled)
                    .lineLimit(8)
            }
        }
        .padding(.vertical, 3)
    }

    private var roleColor: Color {
        switch message.role {
        case "assistant": return Theme.accent
        case "user": return Theme.ok
        case "tool": return Theme.warn
        default: return Theme.textMuted
        }
    }
}
