import SwiftUI

/// The raw type faces DailySort draws on — the bottom tier of the typography system. Semantic roles
/// (`DSFont`) resolve to one of these; features never touch a family directly. This is the single swap
/// point: point a case at a different face (e.g. a bundled custom font) and every role using it updates.
enum DSFontFamily {
    /// Baskerville — the elegant serif used for hero titles and the wordmark.
    case display
    /// Copperplate — the engraved serif used for UI chrome, section titles, and body copy.
    case chrome
    /// Impact — the heavy condensed face for loud display moments.
    case impact
    /// The system monospaced face — gameplay tiles, counters, and interface numerals.
    case mono
    /// The system (sans) face — compact interface labels.
    case ui

    func font(size: CGFloat, weight: Font.Weight) -> Font {
        switch self {
        case .display: .custom("Baskerville", size: size).weight(weight)
        case .chrome:  .custom("Copperplate", size: size).weight(weight)
        case .impact:  .custom("Impact", size: size).weight(weight)
        case .mono:    .system(size: size, weight: weight, design: .monospaced)
        case .ui:      .system(size: size, weight: weight)
        }
    }
}
