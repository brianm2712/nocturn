import SwiftUI

/// Nocturn's entire look and feel. Edit this file to retheme the app —
/// no other file contains style constants.
enum Theme {
    // ── Colors ──────────────────────────────────────────────
    static let background = Color(red: 0.02, green: 0.04, blue: 0.06)
    static let panel      = Color(red: 0.09, green: 0.11, blue: 0.13)
    static let panelBorder = Color.white.opacity(0.08)
    static let textPrimary = Color(red: 0.90, green: 0.93, blue: 0.95)
    static let textMuted   = Color(red: 0.57, green: 0.60, blue: 0.63)
    static let accent  = Color(red: 0.35, green: 0.65, blue: 1.00)
    static let ok      = Color(red: 0.25, green: 0.73, blue: 0.31)
    static let warn    = Color(red: 0.82, green: 0.60, blue: 0.13)
    static let error   = Color(red: 0.97, green: 0.32, blue: 0.29)
    static let money   = ok

    // ── Metrics ─────────────────────────────────────────────
    static let cardRadius: CGFloat = 12
    static let cardPadding: CGFloat = 14
    static let gridSpacing: CGFloat = 12
    static let stripHeight: CGFloat = 36

    // ── Type ────────────────────────────────────────────────
    static let cardTitle = Font.system(size: 11, weight: .semibold).uppercaseSmallCaps()
    static let body = Font.system(size: 13)
    static let bigNumber = Font.system(size: 24, weight: .bold, design: .rounded)
    static let meta = Font.system(size: 11)
}

/// Standard card chrome used by every dashboard card.
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Theme.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.panel)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
            .overlay(RoundedRectangle(cornerRadius: Theme.cardRadius)
                .strokeBorder(Theme.panelBorder))
    }
}

extension View {
    func cardStyle() -> some View { modifier(CardStyle()) }
}
