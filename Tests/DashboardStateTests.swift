import XCTest
@testable import Nocturn

final class DashboardStateTests: XCTestCase {
    func testAgentRowActiveWithin5Minutes() {
        let now = Date()
        let sessions = [
            SessionInfo(id: "a", title: "hot", source: "cli",
                        lastActive: now.addingTimeInterval(-60), messageCount: 1),
            SessionInfo(id: "b", title: "cold", source: "telegram",
                        lastActive: now.addingTimeInterval(-3600), messageCount: 1),
        ]
        let rows = StateReducer.agentRows(from: sessions, now: now)
        XCTAssertTrue(rows[0].isActive)
        XCTAssertFalse(rows[1].isActive)
    }

    func testProviderHealthFlagsErrorCode() throws {
        let d = JSONDecoder()
        let pool = try d.decode(CredentialPoolResponse.self, from: Fixtures.credentials)
        let health = StateReducer.providerHealth(from: pool)
        XCTAssertEqual(health.first { $0.name == "fireworks" }?.ok, false)
        XCTAssertEqual(health.first { $0.name == "fireworks" }?.detail, "401")
        XCTAssertEqual(health.first { $0.name == "nous" }?.ok, true)
    }

    func testCronRowsFromJobs() throws {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        let jobs = try d.decode([CronJob].self, from: Fixtures.cron)
        let rows = StateReducer.cronRows(from: jobs)
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].name, "morning-brief")
        XCTAssertEqual(rows[0].paused, false)
        XCTAssertEqual(rows[0].profile, "default")
        XCTAssertEqual(rows[0].lastStatus, "completed")
    }

    func testProfileRowsFromProfiles() throws {
        let d = JSONDecoder()
        let resp = try d.decode(ProfilesResponse.self, from: Fixtures.profiles)
        let rows = StateReducer.profileRows(from: resp.profiles)
        XCTAssertEqual(rows.count, 2)
        XCTAssertEqual(rows[0].name, "default")
        XCTAssertEqual(rows[0].isDefault, true)
        XCTAssertEqual(rows[0].gatewayRunning, true)
        XCTAssertEqual(rows[0].model, "claude-sonnet-5")
        XCTAssertEqual(rows[1].name, "secops")
        XCTAssertEqual(rows[1].isDefault, false)
    }
}
