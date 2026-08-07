import SwiftUI

/// The semantic type scale — the tier features use. Each role names a *purpose* and resolves to either a
/// fixed-size brand face (`DSFontFamily`) or a system text style (Dynamic-Type-scaled), so screens ask for
/// `.dsFont(.sectionTitle)`, never a raw `.system(size:)`/`.custom(...)`/`.font(.caption)`.
///
/// Display titles, the wordmark serif, the Impact face, and the gameplay tiles are **fixed** (their
/// layout is size-critical); content/label roles ride the **system text styles** so body copy scales for
/// accessibility and reads like the result screen.
enum DSFont: CaseIterable {

    // Display serif (Baskerville) — fixed
    case largeTitle        // hero title / streak headline
    case title             // screen title

    // Content (system text styles — Dynamic Type)
    case sectionTitle      // grouped-section heading
    case keyCap            // keyboard letter key
    case callout           // body copy
    case footnote          // compact stat / label
    case caption           // footnotes, version string
    case caption2          // smallest label

    // Chrome serif (Copperplate) — fixed
    case body              // engraved-serif body copy (game chrome, meaning screen)

    // Impact — fixed
    case impact            // loud display moment

    // Mono gameplay — fixed
    case gameTile          // the scrambled letter tiles

    // System label — fixed
    case label             // compact interface label (buttons)

    // MARK: - Publics

    /// The resolved SwiftUI font. Content roles scale with Dynamic Type; brand/gameplay roles are fixed.
    var font: Font {
        switch resolution {
        case let .face(family, size, weight):
            family.font(size: size, weight: weight)
        case let .textStyle(style, weight):
            .system(style, weight: weight)
        }
    }

    /// Letter spacing paired with this role (applied with `font` by `.dsFont(_:)`).
    var tracking: CGFloat { 0 }

    // MARK: - Privates

    private enum Resolution {
        case face(DSFontFamily, size: CGFloat, weight: Font.Weight)
        case textStyle(Font.TextStyle, weight: Font.Weight)
    }

    private var resolution: Resolution {
        switch self {
        case .largeTitle:   .face(.display, size: 42, weight: .regular)
        case .title:        .face(.display, size: 32, weight: .regular)
        case .sectionTitle: .textStyle(.title3, weight: .semibold)
        case .keyCap:       .textStyle(.title3, weight: .regular)
        case .callout:      .textStyle(.callout, weight: .regular)
        case .footnote:     .textStyle(.footnote, weight: .regular)
        case .caption:      .textStyle(.caption, weight: .regular)
        case .caption2:     .textStyle(.caption2, weight: .regular)
        case .body:         .face(.chrome, size: 18, weight: .regular)
        case .impact:       .face(.impact, size: 36, weight: .regular)
        case .gameTile:     .face(.mono, size: 36, weight: .medium)
        case .label:        .face(.ui, size: 16, weight: .regular)
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
