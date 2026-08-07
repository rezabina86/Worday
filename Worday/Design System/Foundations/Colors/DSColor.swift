import SwiftUI

/// The semantic colour tokens — the tier features use. Each names a *purpose* and aliases a `DSPalette`
/// entry, so a screen asks for `DSColor.textSecondary`, never a raw asset name or a system colour. Adding
/// a colour means adding a token here mapped to a palette entry — never inlining `Color(...)` in a view.
enum DSColor {
    // Surfaces
    static let background   = DSPalette.paper
    static let banner       = DSPalette.banner

    // Content
    static let textPrimary   = DSPalette.ink
    static let textSecondary = DSPalette.darkGrey
    static let textInverted  = DSPalette.paper

    // Lines
    static let border      = DSPalette.borderActive
    static let borderMuted = DSPalette.borderInactive

    // Brand & interaction — DailySort's accent is the cardinal red; links wear it, never system blue.
    static let brand = DSPalette.cardinal
    static let link  = DSPalette.cardinal

    // Gameplay feedback
    static let correct   = Color.green
    static let misplaced = Color.yellow
    static let wrong     = DSPalette.backgroundWrong
    static let keyNone   = DSPalette.keyNone

    // Elevation — stays dark in both appearances (a shadow, never a glow).
    static let shadow = Color.black
}
