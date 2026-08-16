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

struct CronRow: Identifiable, Equatable, Hashable {
    var id: String
    var name: String
    var schedule: String
    var nextRun: Date?
    var paused: Bool
    var profile: String?
    var lastStatus: String?
    var lastError: String?
}

struct ProfileRow: Identifiable, Equatable {
    var id: String { name }
    var name: String
    var model: String?
    var provider: String?
    var gatewayRunning: Bool?
    var isDefault: Bool
    var skillCount: Int?
    var description: String?
}

struct DashboardState: Equatable {
    var gatewayUp: Bool?
    var gatewayState: String?
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
    var profiles: [ProfileRow] = []
    var kanbanInstalled: Bool = false

    var healthState: LoadState = .loading
    var agentsState: LoadState = .loading
    var usageState: LoadState = .loading
    var errorsState: LoadState = .loading
    var cronState: LoadState = .loading
    var profilesState: LoadState = .loading
}

extension UsageDay: Equatable {
    static func == (l: UsageDay, r: UsageDay) -> Bool { l.date == r.date && l.tokens == r.tokens }
}

// Pure merge helpers — unit-testable without networking.
enum StateReducer {

    static func providerHealth(from pool: CredentialPoolResponse) -> [ProviderHealth] {
        pool.providers.map { p in
            let bad = p.entries.first { $0.lastErrorCode != nil }
            return ProviderHealth(name: p.provider,
                                  ok: bad == nil,
                                  detail: bad?.lastErrorCode.map(String.init))
        }
    }

    static func profileRows(from profiles: [ProfileInfo]) -> [ProfileRow] {
        profiles.map { p in
            ProfileRow(name: p.name,
                       model: p.model,
                       provider: p.provider,
                       gatewayRunning: p.gatewayRunning,
                       isDefault: p.isDefault ?? false,
                       skillCount: p.skillCount,
                       description: p.description)
        }
    }

    static func cronRows(from jobs: [CronJob]) -> [CronRow] {
        jobs.map { j in
            CronRow(id: j.id,
                    name: j.name ?? j.id,
                    schedule: j.scheduleDisplay ?? j.schedule ?? "",
                    nextRun: j.nextRunAt,
                    paused: !(j.enabled ?? true),
                    profile: j.profileName ?? j.profile,
                    lastStatus: j.lastStatus,
                    lastError: j.lastError)
        }
    }

    static func agentRows(from sessions: [SessionInfo], now: Date = .now) -> [AgentRow] {
        sessions.map { s in
            AgentRow(id: s.id,
                     title: s.title ?? s.id,
                     source: s.source ?? "unknown",
                     lastActivity: s.lastActive,
                     isActive: s.isActive ?? (s.lastActive.map { now.timeIntervalSince($0) < 300 } ?? false))
        }
    }
}
