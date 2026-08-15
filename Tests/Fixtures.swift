import Foundation

enum Fixtures {
    static let status = Data("""
    {"gateway_running": true, "active_sessions": 2, "version": "1.4.2"}
    """.utf8)

    static let sessions = Data("""
    {"sessions": [
      {"id": "abc", "title": "talos-console", "source": "cli",
       "updated_at": "2026-08-15T08:27:00Z", "message_count": 12},
      {"id": "def", "title": "main", "source": "telegram",
       "updated_at": "2026-08-15T07:00:00Z", "message_count": 42}
    ], "total": 2}
    """.utf8)

    static let usage = Data("""
    {"days": [
      {"date": "2026-08-14", "tokens": 2100000, "requests": 60, "cost": 9.10},
      {"date": "2026-08-15", "tokens": 3100000, "requests": 88, "cost": 12.40}
    ], "total_tokens": 5200000, "total_requests": 148, "total_cost": 21.50}
    """.utf8)

    static let credentials = Data("""
    {"providers": [
      {"provider": "nous", "entries": [
        {"label": "device_code", "last_status": null, "last_error_code": null}]},
      {"provider": "fireworks", "entries": [
        {"label": "FIREWORKS_API_KEY", "last_status": "exhausted",
         "last_error_code": 401, "last_error_message": "The API key you provided is invalid."}]}
    ]}
    """.utf8)

    static let cron = Data("""
    [{"id": "j1", "name": "morning-brief", "schedule": "0 7 * * *",
      "paused": false, "next_run": "2026-08-16T07:00:00Z"}]
    """.utf8)

    static let systemStats = Data("""
    {"cpu_percent": 12.0, "memory_used_bytes": 3328599654, "memory_total_bytes": 17179869184}
    """.utf8)

    static let logs = Data("""
    {"lines": [
      {"timestamp": "2026-08-15T08:33:00Z", "level": "ERROR",
       "message": "fireworks auth failed (401)"}
    ]}
    """.utf8)
}
