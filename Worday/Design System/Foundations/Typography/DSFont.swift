import SwiftUI

/// The semantic type scale — the tier features use. Each role names a *purpose* and resolves to a
/// `DSFontFamily` + size + weight + tracking, so screens ask for `.dsFont(.sectionTitle)`, never a raw
/// `.system(size:)`/`.custom(...)`. Mirrors the two-tier typography architecture (raw faces → roles).
///
/// The legacy `wdFont*` / `titleFont` / `bodyFont` constants are thin aliases onto these roles (see
/// `WDFont.swift`) so existing screens keep their exact look while new work uses `.dsFont(_:)`.
enum DSFont: CaseIterable {

    // Display serif (Baskerville)
    case largeTitle        // hero title / streak headline
    case title             // screen title

    // Content (system sans — clean and legible, matching the result screen)
    case sectionTitle      // grouped-section heading
    case callout           // body copy
    case caption           // footnotes, version string

    // Chrome serif (Copperplate) — legacy body role
    case body              // body copy (legacy `bodyFont`)

    // Impact
    case impact            // loud display moment

    // Mono (gameplay & interface)
    case gameTile          // the scrambled letter tiles
    case gameHeading       // large mono heading
    case gameTitle         // mono title
    case gameCaption       // micro mono caption

    // System (compact interface labels)
    case label
    case labelSmall

    // MARK: - Publics

    /// The resolved SwiftUI font (scales with Dynamic Type for the custom faces).
    var font: Font { spec.family.font(size: spec.size, weight: spec.weight) }

    /// Letter spacing that pairs with this role. Applied together with `font` by `.dsFont(_:)`.
    var tracking: CGFloat { spec.tracking }

    // MARK: - Privates

    private struct Spec {
        let family: DSFontFamily
        let size: CGFloat
        var weight: Font.Weight = .regular
        var tracking: CGFloat = 0
    }

    private var spec: Spec {
        switch self {
        case .largeTitle:   Spec(family: .display, size: 42)
        case .title:        Spec(family: .display, size: 32)
        case .sectionTitle: Spec(family: .ui, size: 20, weight: .semibold)
        case .callout:      Spec(family: .ui, size: 16)
        case .caption:      Spec(family: .ui, size: 13)
        case .body:         Spec(family: .chrome, size: 18)
        case .impact:       Spec(family: .impact, size: 36)
        case .gameTile:     Spec(family: .mono, size: 36, weight: .medium)
        case .gameHeading:  Spec(family: .mono, size: 24, weight: .medium)
        case .gameTitle:    Spec(family: .mono, size: 20, weight: .medium)
        case .gameCaption:  Spec(family: .mono, size: 8, weight: .medium)
        case .label:        Spec(family: .ui, size: 16)
        case .labelSmall:   Spec(family: .ui, size: 12)
        }
    }
}

extension View {
    /// Apply a semantic type role — sets the font and its paired tracking together.
    func dsFont(_ style: DSFont) -> some View {
        font(style.font).tracking(style.tracking)
    }
}

extension Text {
    /// `Text`-level variant so a role can be composed inside concatenated `Text` runs.
    func dsFont(_ style: DSFont) -> Text {
        font(style.font).tracking(style.tracking)
    }
}
