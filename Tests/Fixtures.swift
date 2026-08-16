import Foundation

enum Fixtures {
    static let status = Data("""
    {"gateway_running": true, "active_sessions": 2, "version": "1.4.2",
     "gateway_state": "running", "gateway_pid": 12345}
    """.utf8)

    static let sessions = Data("""
    {"sessions": [
      {"id": "abc", "title": "talos-console", "source": "cli",
       "last_active": "2026-08-15T08:27:00Z", "message_count": 12,
       "is_active": true, "model": "claude-sonnet-5"},
      {"id": "def", "title": "main", "source": "telegram",
       "last_active": "2026-08-15T07:00:00Z", "message_count": 42,
       "is_active": false}
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
    [{"id": "j1", "name": "morning-brief", "schedule_display": "0 7 * * *",
      "enabled": true, "next_run_at": "2026-08-16T07:00:00Z",
      "last_status": "completed", "last_error": null,
      "profile_name": "default", "prompt": "Daily briefing"}]
    """.utf8)

    static let cronRuns = Data("""
    {"runs": [
      {"id": "cron_j1_1692180000", "title": "morning-brief", "source": "cron",
       "started_at": "2026-08-16T07:00:00Z", "last_active": "2026-08-16T07:01:00Z",
       "ended_at": "2026-08-16T07:01:00Z", "is_active": false, "message_count": 4}
    ], "limit": 20}
    """.utf8)

    static let sessionMessages = Data("""
    {"session_id": "cron_j1_1692180000", "messages": [
      {"role": "user", "content": "Run the morning briefing.", "timestamp": "2026-08-16T07:00:00Z"},
      {"role": "assistant", "content": "Briefing delivered: 3 items.", "timestamp": "2026-08-16T07:01:00Z"}
    ]}
    """.utf8)

    static let profiles = Data("""
    {"profiles": [
      {"name": "default", "model": "claude-sonnet-5", "provider": "nous",
       "gateway_running": true, "is_default": true, "skill_count": 24,
       "description": "Talos local agent"},
      {"name": "secops", "model": "deepseek-v4-flash", "provider": "nous",
       "gateway_running": true, "is_default": false, "skill_count": 12,
       "description": "Security monitoring"}
    ]}
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
