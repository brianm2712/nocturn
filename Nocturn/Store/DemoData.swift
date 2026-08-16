import Foundation

enum DemoData {
    static var state: DashboardState {
        var s = DashboardState()
        let now = Date()
        s.gatewayUp = true
        s.gatewayState = "running"
        s.providers = [
            ProviderHealth(name: "nous", ok: true, detail: nil),
            ProviderHealth(name: "fireworks", ok: false, detail: "401"),
        ]
        s.cpuPercent = 12
        s.memoryUsedBytes = 3_328_599_654
        s.agents = [
            AgentRow(id: "1", title: "talos-console", source: "cli",
                     lastActivity: now.addingTimeInterval(-120), isActive: true),
            AgentRow(id: "2", title: "main", source: "telegram",
                     lastActivity: now.addingTimeInterval(-3600), isActive: false),
            AgentRow(id: "3", title: "morning-brief", source: "cron",
                     lastActivity: now.addingTimeInterval(-21600), isActive: false),
        ]
        s.usageDays = (0..<7).map { i in
            UsageDay(date: "2026-08-\(9 + i)",
                     tokens: [8, 12, 22, 15, 31, 19, 11][i] * 100_000,
                     requests: 40 + i * 7,
                     cost: Double([4, 6, 11, 8, 16, 10, 6][i]))
        }
        s.totalCost = 64.31
        s.totalRequests = 412
        s.totalTokens = 18_200_000
        s.errors = [ErrorEvent(timestamp: now.addingTimeInterval(-900),
                               message: "fireworks auth failed (401)")]
        s.cron = [
            CronRow(id: "j1", name: "morning-brief", schedule: "0 7 * * *",
                    nextRun: now.addingTimeInterval(21600), paused: false,
                    profile: "default", lastStatus: "completed", lastError: nil),
            CronRow(id: "j2", name: "security-digest", schedule: "0 8 * * *",
                    nextRun: now.addingTimeInterval(18000), paused: false,
                    profile: "secops", lastStatus: "completed", lastError: nil),
            CronRow(id: "j3", name: "vault-sync", schedule: "30m",
                    nextRun: now.addingTimeInterval(900), paused: false,
                    profile: "loki", lastStatus: "error",
                    lastError: "SSH connection refused to fenris01"),
        ]
        s.profiles = [
            ProfileRow(name: "default", model: "claude-sonnet-5",
                       provider: "nous", gatewayRunning: true,
                       isDefault: true, skillCount: 24,
                       description: "Talos local agent"),
            ProfileRow(name: "loki", model: "claude-sonnet-5",
                       provider: "nous", gatewayRunning: true,
                       isDefault: false, skillCount: 18,
                       description: "Build & execution agent"),
            ProfileRow(name: "secops", model: "deepseek-v4-flash",
                       provider: "nous", gatewayRunning: true,
                       isDefault: false, skillCount: 12,
                       description: "Security monitoring"),
            ProfileRow(name: "fenris01", model: "deepseek-v4-flash",
                       provider: "nous", gatewayRunning: true,
                       isDefault: false, skillCount: 15,
                       description: "VPS gateway + tutor"),
        ]
        s.kanbanInstalled = true
        let t = LoadState.loaded(now)
        s.healthState = t; s.agentsState = t; s.usageState = t
        s.errorsState = t; s.cronState = t; s.profilesState = t
        return s
    }

    static var cronRuns: [SessionInfo] {
        let now = Date()
        return [
            SessionInfo(id: "cron_j1_1692180000", title: "morning-brief",
                        source: "cron", model: "claude-sonnet-5",
                        startedAt: now.addingTimeInterval(-21600),
                        lastActive: now.addingTimeInterval(-21540),
                        endedAt: now.addingTimeInterval(-21540),
                        isActive: false, messageCount: 4,
                        inputTokens: 2100, outputTokens: 4800,
                        preview: "Daily briefing: 3 priority items...",
                        profile: "default"),
            SessionInfo(id: "cron_j1_1692093600", title: "morning-brief",
                        source: "cron", model: "claude-sonnet-5",
                        startedAt: now.addingTimeInterval(-108000),
                        lastActive: now.addingTimeInterval(-107940),
                        endedAt: now.addingTimeInterval(-107940),
                        isActive: false, messageCount: 4,
                        inputTokens: 1900, outputTokens: 4200,
                        preview: "Daily briefing: 2 priority items...",
                        profile: "default"),
        ]
    }

    static var cronMessages: [SessionMessage] {
        let now = Date()
        return [
            SessionMessage(role: "user", content: "Run the morning briefing for today.",
                           timestamp: now.addingTimeInterval(-21600)),
            SessionMessage(role: "assistant", content: "## Morning Brief — Aug 16\n\n**3 priority items:**\n\n1. Nocturn app screenshot still needed (display asleep)\n2. fenris02 honeypot check — verify tripwire is clean\n3. Vault sync to Drive — last push 2 days ago\n\n**Costs:** $9.10 yesterday, $64.31 this week.\n\n**Errors:** Fireworks API key still 401 — disabled in rotation.",
                           timestamp: now.addingTimeInterval(-21570)),
            SessionMessage(role: "assistant", content: "Briefing delivered. Next scheduled run: tomorrow 07:00 UTC.",
                           timestamp: now.addingTimeInterval(-21540)),
        ]
    }
}
