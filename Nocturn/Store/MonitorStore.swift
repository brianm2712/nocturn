import Foundation
import Observation

@Observable @MainActor
final class MonitorStore {
    var state = DashboardState()
    var settings: ConnectionSettings {
        didSet { settings.save(); Task { await restart() } }
    }

    private var client: HermesClient
    private var pollTask: Task<Void, Never>?

    init(settings: ConnectionSettings) {
        self.settings = settings
        self.client = HermesClient(settings: settings)
    }

    func start() async {
        pollTask?.cancel()
        if settings.demoMode { state = DemoData.state; return }
        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.refreshAll()
                let interval = self?.settings.pollSeconds ?? 10
                try? await Task.sleep(for: .seconds(interval))
            }
        }
    }

    private func restart() async {
        client = HermesClient(settings: settings)
        await start()
    }

    func refreshAll() async {
        // Each section fails independently — one bad endpoint must not
        // blank the others.
        async let health: Void = refreshHealth()
        async let agents: Void = refreshAgents()
        async let usage: Void = refreshUsage()
        async let errors: Void = refreshErrors()
        async let cron: Void = refreshCron()
        async let profiles: Void = refreshProfiles()
        _ = await (health, agents, usage, errors, cron, profiles)
    }

    private func refreshHealth() async {
        do {
            let status = try await client.status()
            let creds = try await client.credentials()
            let sys = try? await client.systemStats()
            state.gatewayUp = status.gatewayRunning ?? false
            state.gatewayState = status.gatewayState
            state.providers = StateReducer.providerHealth(from: creds)
            state.cpuPercent = sys?.cpuPercent
            state.memoryUsedBytes = sys?.memoryUsedBytes
            state.healthState = .loaded(.now)
        } catch { state.healthState = .error(error.localizedDescription) }
    }

    private func refreshAgents() async {
        do {
            let resp = try await client.sessions()
            state.agents = StateReducer.agentRows(from: resp.sessions)
            state.agentsState = .loaded(.now)
        } catch { state.agentsState = .error(error.localizedDescription) }
    }

    private func refreshUsage() async {
        do {
            let u = try await client.usage(days: 7)
            state.usageDays = u.days
            state.totalCost = u.totalCost
            state.totalRequests = u.totalRequests
            state.totalTokens = u.totalTokens
            state.usageState = .loaded(.now)
        } catch { state.usageState = .error(error.localizedDescription) }
    }

    private func refreshErrors() async {
        do {
            let logs = try await client.errorLogs()
            state.errors = logs.lines.map {
                ErrorEvent(timestamp: $0.timestamp, message: $0.message ?? "unknown error")
            }
            state.errorsState = .loaded(.now)
        } catch { state.errorsState = .error(error.localizedDescription) }
    }

    private func refreshCron() async {
        state.kanbanInstalled = await client.kanbanInstalled()
        do {
            let jobs = try await client.cronJobs()
            state.cron = StateReducer.cronRows(from: jobs)
            state.cronState = .loaded(.now)
        } catch { state.cronState = .error(error.localizedDescription) }
    }

    private func refreshProfiles() async {
        do {
            let profiles = try await client.profiles()
            state.profiles = StateReducer.profileRows(from: profiles)
            state.profilesState = .loaded(.now)
        } catch { state.profilesState = .error(error.localizedDescription) }
    }

    // On-demand fetch for cron job detail view
    func loadCronRuns(jobId: String, profile: String? = nil) async -> [SessionInfo] {
        do { return try await client.cronJobRuns(jobId: jobId, profile: profile) }
        catch { return [] }
    }

    // On-demand fetch for session messages (cron run output)
    func loadMessages(sessionId: String) async -> [SessionMessage] {
        do { return try await client.sessionMessages(sessionId: sessionId) }
        catch { return [] }
    }
}
