import Foundation

enum DemoData {
    static var state: DashboardState {
        var s = DashboardState()
        let now = Date()
        s.gatewayUp = true
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
        s.cron = [CronRow(id: "j1", name: "morning-brief", schedule: "0 7 * * *",
                          nextRun: now.addingTimeInterval(21600), paused: false)]
        s.kanbanInstalled = true
        let t = LoadState.loaded(now)
        s.healthState = t; s.agentsState = t; s.usageState = t
        s.errorsState = t; s.cronState = t
        return s
    }
}
