import XCTest
@testable import Nocturn

final class HermesClientTests: XCTestCase {
    func testExtractTokenFromDashboardHTML() {
        let html = """
        <script>window.__HERMES_SESSION_TOKEN__ = "tok_abc123";
        window.__HERMES_BASE_PATH__ = "";</script>
        """
        XCTAssertEqual(HermesClient.extractToken(fromHTML: html), "tok_abc123")
    }

    func testExtractTokenMissing() {
        XCTAssertNil(HermesClient.extractToken(fromHTML: "<html></html>"))
    }
}
