import Foundation

enum LoadState: Equatable { case loading, loaded(Date), error(String) }

struct AgentRow: Identifiable, Equatable {
    var id: String
    var title: String
    var source: String       // "cli", "telegram", "desktop", "cron", ...
    var lastActivity: Date?
    var isActive: Bool       // active within last 5 min

    var sourceIcon: String {
        switch source {
        case "cli": return "terminal"
        case "telegram", "whatsapp", "slack", "discord": return "bubble.left"
        case "desktop": return "desktopcomputer"
        case "cron": return "clock"
        default: return "circle"
        }
    }
}

struct ProviderHealth: Identifiable, Equatable {
    var id: String { name }
    var name: String
    var ok: Bool
    var detail: String?      // e.g. "401"
}

struct ErrorEvent: Identifiable, Equatable {
    var id = UUID()
    var timestamp: Date?
    var message: String
}

struct CronRow: Identifiable, Equatable {
    var id: String
    var name: String
    var schedule: String
    var nextRun: Date?
    var paused: Bool
}

struct DashboardState: Equatable {
    var gatewayUp: Bool?
    var providers: [ProviderHealth] = []
    var cpuPercent: Double?
    var memoryUsedBytes: Int64?
    var agents: [AgentRow] = []
    var usageDays: [UsageDay] = []
    var totalCost: Double?
    var totalRequests: Int?
    var totalTokens: Int?
    var errors: [ErrorEvent] = []
    var cron: [CronRow] = []
    var kanbanInstalled: Bool = false

    var healthState: LoadState = .loading
    var agentsState: LoadState = .loading
    var usageState: LoadState = .loading
    var errorsState: LoadState = .loading
    var cronState: LoadState = .loading
}

extension UsageDay: Equatable {
    static func == (l: UsageDay, r: UsageDay) -> Bool { l.date == r.date && l.tokens == r.tokens }
}

// Pure merge helpers — unit-testable without networking.
enum StateReducer {
    static func agentRows(from sessions: [SessionInfo], now: Date = .now) -> [AgentRow] {
        sessions.map { s in
            AgentRow(id: s.id,
                     title: s.title ?? s.id,
                     source: s.source ?? "unknown",
                     lastActivity: s.updatedAt,
                     isActive: s.updatedAt.map { now.timeIntervalSince($0) < 300 } ?? false)
        }
    }

    static func providerHealth(from pool: CredentialPoolResponse) -> [ProviderHealth] {
        pool.providers.map { p in
            let bad = p.entries.first { $0.lastErrorCode != nil }
            return ProviderHealth(name: p.provider,
                                  ok: bad == nil,
                                  detail: bad?.lastErrorCode.map(String.init))
        }
    }
}
