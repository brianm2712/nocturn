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
        _ = await (health, agents, usage, errors, cron)
    }

    private func refreshHealth() async {
        do {
            let status = try await client.status()
            let creds = try await client.credentials()
            let sys = try? await client.systemStats()
            state.gatewayUp = status.gatewayRunning ?? false
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
            state.cron = jobs.map {
                CronRow(id: $0.id, name: $0.name ?? $0.id,
                        schedule: $0.schedule ?? "", nextRun: $0.nextRun,
                        paused: $0.paused ?? false)
            }
            state.cronState = .loaded(.now)
        } catch { state.cronState = .error(error.localizedDescription) }
    }
}
