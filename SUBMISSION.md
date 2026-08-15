# Submitting Nocturn to the App Store

## One-time setup (you)
1. You already have a developer account — skip enrollment.
2. Xcode → Settings → Accounts → add your Apple ID, let Xcode manage signing.
3. In project.yml, set your team: under targets.Nocturn.settings add
   DEVELOPMENT_TEAM: <YOUR_TEAM_ID>, then `xcodegen generate`.
   (Find the team ID at developer.apple.com/account → Membership.)

## Per-release
1. `xcodegen generate` and open Nocturn.xcodeproj in Xcode.
2. Product → Archive (once with "Any iOS Device", once with "Any Mac").
3. Organizer → Distribute App → App Store Connect → Upload (both archives).
4. appstoreconnect.apple.com → My Apps → "+" → New App:
   - Name: Nocturn · Bundle ID: com.brianmurphy.nocturn
   - Category: Developer Tools · Price: your call
   - Privacy policy URL: (host privacy-policy.md anywhere public — a GitHub
     gist or repo page is fine)
   - App Privacy: "Data Not Collected"
5. Screenshots: iPhone 6.7" and Mac — run in demo mode, capture the
   dashboard. (Cmd+S in Simulator saves a correctly sized PNG.)
6. Review notes: paste this —
   "Nocturn is a monitor for the open-source, self-hosted Hermes agent
   (github.com/NousResearch/Hermes-Agent). Reviewers: enable Settings →
   Demo Mode to see the full UI with sample data; no server required."
7. Submit for review. Typical turnaround 1–2 days.
