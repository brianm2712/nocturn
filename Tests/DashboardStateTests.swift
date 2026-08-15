import XCTest
@testable import Nocturn

final class DashboardStateTests: XCTestCase {
    func testAgentRowActiveWithin5Minutes() {
        let now = Date()
        let sessions = [
            SessionInfo(id: "a", title: "hot", source: "cli",
                        updatedAt: now.addingTimeInterval(-60), messageCount: 1),
            SessionInfo(id: "b", title: "cold", source: "telegram",
                        updatedAt: now.addingTimeInterval(-3600), messageCount: 1),
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
}
