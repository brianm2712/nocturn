import Foundation

// All fields optional-friendly: the dashboard API adds fields freely and we
// must never fail the whole payload over one missing key.

struct StatusResponse: Decodable {
    var gatewayRunning: Bool?
    var activeSessions: Int?
    var version: String?
    var gatewayState: String?
    var gatewayPid: Int?
    enum CodingKeys: String, CodingKey {
        case gatewayRunning = "gateway_running"
        case activeSessions = "active_sessions"
        case version
        case gatewayState = "gateway_state"
        case gatewayPid = "gateway_pid"
    }
}

struct SessionInfo: Decodable, Identifiable {
    var id: String
    var title: String?
    var source: String?
    var model: String?
    var startedAt: Date?
    var lastActive: Date?
    var endedAt: Date?
    var isActive: Bool?
    var messageCount: Int?
    var inputTokens: Int?
    var outputTokens: Int?
    var preview: String?
    var profile: String?
    enum CodingKeys: String, CodingKey {
        case id, title, source, model, preview, profile
        case startedAt = "started_at"
        case lastActive = "last_active"
        case endedAt = "ended_at"
        case isActive = "is_active"
        case messageCount = "message_count"
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
    }
}

struct SessionsResponse: Decodable {
    var sessions: [SessionInfo]
    var total: Int?
}

struct UsageDay: Decodable, Identifiable {
    var date: String
    var tokens: Int?
    var requests: Int?
    var cost: Double?
    var id: String { date }
}

struct UsageResponse: Decodable {
    var days: [UsageDay]
    var totalTokens: Int?
    var totalRequests: Int?
    var totalCost: Double?
    enum CodingKeys: String, CodingKey {
        case days
        case totalTokens = "total_tokens"
        case totalRequests = "total_requests"
        case totalCost = "total_cost"
    }
}

struct CredentialEntry: Decodable {
    var label: String?
    var lastStatus: String?
    var lastErrorCode: Int?
    var lastErrorMessage: String?
    enum CodingKeys: String, CodingKey {
        case label
        case lastStatus = "last_status"
        case lastErrorCode = "last_error_code"
        case lastErrorMessage = "last_error_message"
    }
}

struct CredentialProvider: Decodable {
    var provider: String
    var entries: [CredentialEntry]
}

struct CredentialPoolResponse: Decodable {
    var providers: [CredentialProvider]
}

// Full CronJob matching the dashboard's TS interface.
struct CronJob: Decodable, Identifiable {
    var id: String
    var profile: String?
    var profileName: String?
    var isDefaultProfile: Bool?
    var name: String?
    var prompt: String?
    var script: String?
    var skills: [String]?
    var scheduleDisplay: String?
    var enabled: Bool?
    var state: String?
    var deliver: String?
    var model: String?
    var provider: String?
    var noAgent: Bool?
    var lastRunAt: Date?
    var nextRunAt: Date?
    var lastStatus: String?
    var lastError: String?
    enum CodingKeys: String, CodingKey {
        case id, profile, name, prompt, script, skills, enabled, state
        case deliver, model, provider
        case profileName = "profile_name"
        case isDefaultProfile = "is_default_profile"
        case scheduleDisplay = "schedule_display"
        case noAgent = "no_agent"
        case lastRunAt = "last_run_at"
        case nextRunAt = "next_run_at"
        case lastStatus = "last_status"
        case lastError = "last_error"
    }

    // Backward-compat: old code used .paused / .schedule / .nextRun
    var paused: Bool? { !(enabled ?? true) }
    var schedule: String? { scheduleDisplay }
    var nextRun: Date? { nextRunAt }
}

// Cron job run history — same shape as SessionInfo (sessions with cron_ prefix ids).
struct CronRunsResponse: Decodable {
    var runs: [SessionInfo]
    var limit: Int?
}

// Session messages — the actual output of a cron run or agent session.
struct SessionMessage: Decodable, Identifiable {
    var id: String { (toolCallId ?? role) + (timestamp.map { String($0.timeIntervalSince1970) } ?? "") }
    var role: String
    var content: String?
    var toolName: String?
    var toolCallId: String?
    var timestamp: Date?
}

struct SessionMessagesResponse: Decodable {
    var sessionId: String?
    var messages: [SessionMessage]
    enum CodingKeys: String, CodingKey {
        case messages
        case sessionId = "session_id"
    }
}

// Profile info — shows every Hermes profile (barabus, fenris01, secops, etc.)
struct ProfileInfo: Decodable, Identifiable {
    var id: String { name }
    var name: String
    var path: String?
    var isDefault: Bool?
    var model: String?
    var provider: String?
    var hasEnv: Bool?
    var skillCount: Int?
    var gatewayRunning: Bool?
    var description: String?
    enum CodingKeys: String, CodingKey {
        case name, path, model, provider, description
        case isDefault = "is_default"
        case hasEnv = "has_env"
        case skillCount = "skill_count"
        case gatewayRunning = "gateway_running"
    }
}

struct ProfilesResponse: Decodable {
    var profiles: [ProfileInfo]
}

struct SystemStats: Decodable {
    var cpuPercent: Double?
    var memoryUsedBytes: Int64?
    var memoryTotalBytes: Int64?
    enum CodingKeys: String, CodingKey {
        case cpuPercent = "cpu_percent"
        case memoryUsedBytes = "memory_used_bytes"
        case memoryTotalBytes = "memory_total_bytes"
    }
}

struct LogLine: Decodable {
    var timestamp: Date?
    var level: String?
    var message: String?
}

struct LogsResponse: Decodable {
    var lines: [LogLine]
}
