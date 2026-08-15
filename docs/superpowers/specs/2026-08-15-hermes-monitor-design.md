# Nocturn (Hermes Monitor) — Design Spec

**Date:** 2026-08-15
**Status:** Approved by user (Sample A "Mission Control", all platforms)
**App name:** Nocturn
**Distribution:** App Store (iOS + macOS)

## Purpose

A native SwiftUI app (iPhone, iPad, Mac) that monitors the user's Hermes agent
installation at a glance: live agent sessions, usage/spend stats, provider and
gateway health, errors, kanban tasks, and cron schedules. Pure read-only client
of the existing Hermes dashboard FastAPI server on port 9119 — no server-side
changes.

## Visual design (approved)

"Mission Control" layout, dark theme:

- **Health strip** (top): gateway up/down, per-provider credential status
  (e.g. "Nous OK", "Fireworks 401"), CPU/MEM from system stats.
- **Live Agents card**: recent/active sessions with platform icon (cli,
  telegram, desktop, cron), title, status tag (working/idle/scheduled),
  relative last-activity time.
- **Usage card**: 7-day token bar chart, spend total, request count.
- **Recent Errors card**: recent error-level log/credential events with
  timestamp.
- **Tasks & Cron card**: kanban counts (in progress/todo) and cron jobs with
  next-run times.

Layout adapts: macOS + iPad = 2-column grid in a window; iPhone = vertically
stacked cards with a bottom tab bar (Status / Agents / Usage / Settings).

## Architecture

- **Project:** `HermesMonitor.xcodeproj`, single multiplatform SwiftUI app
  target. macOS 14+, iOS 17+.
- **No third-party dependencies.** Charts via Swift Charts (system framework).

### Modules

| Unit | Responsibility |
|------|----------------|
| `HermesClient` | async/await URLSession wrapper for the dashboard API. Typed `Decodable` models per endpoint. Knows nothing about views. |
| `MonitorStore` | `@Observable` object. Polls all endpoints on a timer (default 10 s), merges results into one `DashboardState` value. Tracks reachability and per-section errors. |
| `DashboardState` | Plain value type: health, agents, usage, errors, tasks/cron + per-section `LoadState` (loaded/stale/error). |
| `Theme.swift` | ALL look-and-feel constants: colors, fonts, spacing, radii, card styles. The single file the user edits to tweak the GUI. |
| Card views | `HealthStrip`, `LiveAgentsCard`, `UsageCard`, `ErrorsCard`, `TasksCronCard` — one file each, render from `DashboardState` only. |
| `SettingsView` | Host, port, session token (optional manual entry), poll interval. Persisted in `UserDefaults` (token in Keychain). |

### Endpoints used

- `GET /api/status` — gateway/agent status, active sessions
- `GET /api/sessions?limit=20&order=recent` — recent session list
- `GET /api/analytics/usage?days=7` — token/spend/request series
- `GET /api/credentials/pool` — provider credential health (401s etc.)
- `GET /api/cron/jobs?profile=all` — cron schedule
- `GET /api/system/stats` — CPU/MEM
- `GET /api/logs?level=ERROR&lines=50` — recent errors

### Auth

Dashboard loopback mode injects `window.__HERMES_SESSION_TOKEN__` into its
HTML and expects it back as `X-Hermes-Session-Token`. The app:

1. Fetches `http://host:9119/` once, regex-extracts the token from the HTML.
2. Sends it on every API request.
3. On 401, re-fetches the HTML (token rotates on gateway restart).
4. Settings offers a manual token field as fallback (e.g. gated mode).

### Networking reality for iPhone/iPad

The dashboard binds loopback by default. Remote devices require the user to
bind the dashboard to the LAN or use Tailscale. The app surfaces this in its
connection-error state with a short hint. Not the app's job to fix.

## Error handling

- Whole-server unreachable → persistent "Disconnected" banner, last-known data
  shown dimmed with its age ("as of 08:41").
- Single endpoint failing → that card shows an inline error row; other cards
  keep updating.
- Malformed/missing fields → decoders use optionals + defaults; a card renders
  what it can rather than failing the whole payload.

## Testing

- Unit tests: JSON decoding against fixtures captured from the live server;
  `DashboardState` merge logic (e.g. status+sessions → agent rows; stale
  marking on failure).
- Manual verification: run against the real gateway on this Mac; iPhone via
  simulator pointing at the Mac's LAN address.

## App Store distribution

- **Name:** Nocturn. Bundle ID `com.brianmurphy.nocturn` (adjustable to the
  user's developer team domain at signing time).
- **Deliverables the project must include:** app icon set (dark, abstract
  "night monitoring" mark), accent color, App Store screenshots checklist,
  privacy usage strings (local network access on iOS requires
  `NSLocalNetworkUsageDescription`), export compliance answer (standard HTTPS
  only → exempt), and a privacy-policy stub page (App Store requires a URL;
  the app collects nothing, phones home nowhere).
- **App Review consideration:** the app is useless without a Hermes server.
  To pass review, include a built-in **demo mode** (sample data, clearly
  labeled) so reviewers can exercise the UI without a server. Demo mode also
  doubles as the SwiftUI preview data source.
- **User-side steps (cannot be automated):** Apple Developer Program
  enrollment, App Store Connect listing creation, final submit. The project
  ships with a SUBMISSION.md walking through these.

## Out of scope (v1)

- Any write/control actions (restart gateway, pause cron, delete sessions).
- Push notifications / background refresh.
- Kanban board detail view (counts only, via dashboard plugin API if
  reachable; card hides the row if the endpoint is absent).
- Widgets/menu-bar extra (candidate for v2).
