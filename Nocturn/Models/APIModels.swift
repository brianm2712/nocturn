import Foundation

// All fields optional-friendly: the dashboard API adds fields freely and we
// must never fail the whole payload over one missing key.

struct StatusResponse: Decodable {
    var gatewayRunning: Bool?
    var activeSessions: Int?
    var version: String?
    enum CodingKeys: String, CodingKey {
        case gatewayRunning = "gateway_running"
        case activeSessions = "active_sessions"
        case version
    }
}

struct SessionInfo: Decodable, Identifiable {
    var id: String
    var title: String?
    var source: String?
    var updatedAt: Date?
    var messageCount: Int?
    enum CodingKeys: String, CodingKey {
        case id, title, source
        case updatedAt = "updated_at"
        case messageCount = "message_count"
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

struct CronJob: Decodable, Identifiable {
    var id: String
    var name: String?
    var schedule: String?
    var paused: Bool?
    var nextRun: Date?
    enum CodingKeys: String, CodingKey {
        case id, name, schedule, paused
        case nextRun = "next_run"
    }
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
