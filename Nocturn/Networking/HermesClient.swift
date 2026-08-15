import Foundation

/// Read-only client for the Hermes dashboard API. Thread-safe via actor.
actor HermesClient {
    private let settings: ConnectionSettings
    private var token: String?
    private let session: URLSession
    private let decoder: JSONDecoder

    init(settings: ConnectionSettings, session: URLSession = .shared) {
        self.settings = settings
        self.session = session
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        self.decoder = d
        if !settings.manualToken.isEmpty { self.token = settings.manualToken }
    }

    /// The dashboard injects its session token into index.html. Extract it.
    nonisolated static func extractToken(fromHTML html: String) -> String? {
        let pattern = #"__HERMES_SESSION_TOKEN__\s*=\s*"([^"]+)""#
        guard let r = html.range(of: pattern, options: .regularExpression),
              let inner = html[r].range(of: #""([^"]+)""#, options: .regularExpression)
        else { return nil }
        return String(html[inner].dropFirst().dropLast())
    }

    private func refreshToken() async throws {
        if !settings.manualToken.isEmpty { token = settings.manualToken; return }
        let (data, _) = try await session.data(from: settings.baseURL)
        token = Self.extractToken(fromHTML: String(decoding: data, as: UTF8.self))
    }

    private func get<T: Decodable>(_ path: String, as type: T.Type, retried: Bool = false) async throws -> T {
        if token == nil { try await refreshToken() }
        var req = URLRequest(url: settings.baseURL.appending(path: path))
        if let token { req.setValue(token, forHTTPHeaderField: "X-Hermes-Session-Token") }
        let (data, resp) = try await session.data(for: req)
        let code = (resp as? HTTPURLResponse)?.statusCode ?? 0
        if code == 401, !retried {
            // Token rotates on gateway restart — refetch once.
            try await refreshToken()
            return try await get(path, as: type, retried: true)
        }
        guard (200..<300).contains(code) else {
            throw URLError(.badServerResponse)
        }
        return try decoder.decode(T.self, from: data)
    }

    func status() async throws -> StatusResponse { try await get("api/status", as: StatusResponse.self) }
    func sessions() async throws -> SessionsResponse { try await get("api/sessions?limit=20&order=recent", as: SessionsResponse.self) }
    func usage(days: Int = 7) async throws -> UsageResponse { try await get("api/analytics/usage?days=\(days)", as: UsageResponse.self) }
    func credentials() async throws -> CredentialPoolResponse { try await get("api/credentials/pool", as: CredentialPoolResponse.self) }
    func cronJobs() async throws -> [CronJob] { try await get("api/cron/jobs?profile=all", as: [CronJob].self) }
    func systemStats() async throws -> SystemStats { try await get("api/system/stats", as: SystemStats.self) }
    func errorLogs() async throws -> LogsResponse { try await get("api/logs?level=ERROR&lines=50", as: LogsResponse.self) }

    /// The Tasks & Cron card shows a kanban row only when the kanban
    /// dashboard plugin is installed. `/api/dashboard/plugins` is the
    /// documented discovery endpoint.
    struct PluginManifest: Decodable { var name: String? }
    func kanbanInstalled() async -> Bool {
        guard let plugins = try? await get("api/dashboard/plugins", as: [PluginManifest].self)
        else { return false }
        return plugins.contains { $0.name?.localizedCaseInsensitiveContains("kanban") == true }
    }
}
