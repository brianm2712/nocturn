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
    }

    func testDecodeSessions() throws {
        let s = try decoder.decode(SessionsResponse.self, from: Fixtures.sessions)
        XCTAssertEqual(s.sessions.count, 2)
        XCTAssertEqual(s.sessions[0].source, "cli")
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
