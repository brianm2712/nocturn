import XCTest
@testable import Nocturn

final class APIModelsTests: XCTestCase {
    let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    func testDecodeStatus() throws {
        let s = try decoder.decode(StatusResponse.self, from: Fixtures.status)
        XCTAssertEqual(s.gatewayRunning, true)
        XCTAssertEqual(s.gatewayState, "running")
        XCTAssertEqual(s.gatewayPid, 12345)
    }

    func testDecodeSessions() throws {
        let s = try decoder.decode(SessionsResponse.self, from: Fixtures.sessions)
        XCTAssertEqual(s.sessions.count, 2)
        XCTAssertEqual(s.sessions[0].source, "cli")
        XCTAssertEqual(s.sessions[0].model, "claude-sonnet-5")
        XCTAssertEqual(s.sessions[0].isActive, true)
    }

    func testDecodeUsage() throws {
        let u = try decoder.decode(UsageResponse.self, from: Fixtures.usage)
        XCTAssertEqual(u.days.count, 2)
        XCTAssertEqual(u.totalCost ?? 0, 21.50, accuracy: 0.001)
    }

    func testDecodeCredentials_surfacesFireworks401() throws {
        let c = try decoder.decode(CredentialPoolResponse.self, from: Fixtures.credentials)
        let fw = c.providers.first { $0.provider == "fireworks" }
        XCTAssertEqual(fw?.entries.first?.lastErrorCode, 401)
    }

    func testDecodeCron() throws {
        let jobs = try decoder.decode([CronJob].self, from: Fixtures.cron)
        XCTAssertEqual(jobs.first?.name, "morning-brief")
        XCTAssertEqual(jobs.first?.scheduleDisplay, "0 7 * * *")
        XCTAssertEqual(jobs.first?.enabled, true)
        XCTAssertEqual(jobs.first?.lastStatus, "completed")
        XCTAssertEqual(jobs.first?.profileName, "default")
        // Backward-compat computed properties
        XCTAssertEqual(jobs.first?.paused, false)
        XCTAssertEqual(jobs.first?.schedule, "0 7 * * *")
    }

    func testDecodeCronRuns() throws {
        let resp = try decoder.decode(CronRunsResponse.self, from: Fixtures.cronRuns)
        XCTAssertEqual(resp.runs.count, 1)
        XCTAssertEqual(resp.runs.first?.source, "cron")
        XCTAssertEqual(resp.runs.first?.messageCount, 4)
    }

    func testDecodeSessionMessages() throws {
        let resp = try decoder.decode(SessionMessagesResponse.self, from: Fixtures.sessionMessages)
        XCTAssertEqual(resp.messages.count, 2)
        XCTAssertEqual(resp.messages[0].role, "user")
        XCTAssertEqual(resp.messages[1].role, "assistant")
    }

    func testDecodeProfiles() throws {
        let resp = try decoder.decode(ProfilesResponse.self, from: Fixtures.profiles)
        XCTAssertEqual(resp.profiles.count, 2)
        XCTAssertEqual(resp.profiles[0].name, "default")
        XCTAssertEqual(resp.profiles[0].gatewayRunning, true)
        XCTAssertEqual(resp.profiles[0].model, "claude-sonnet-5")
        XCTAssertEqual(resp.profiles[1].name, "secops")
    }

    func testDecodeSystemStats() throws {
        let s = try decoder.decode(SystemStats.self, from: Fixtures.systemStats)
        XCTAssertEqual(s.cpuPercent ?? 0, 12.0, accuracy: 0.001)
    }

    func testDecodeLogs() throws {
        let l = try decoder.decode(LogsResponse.self, from: Fixtures.logs)
        XCTAssertEqual(l.lines.first?.level, "ERROR")
    }
}
