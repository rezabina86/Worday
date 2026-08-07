import SwiftUI

/// The raw colour palette — the bottom tier, one entry per asset-catalog colorset (light/dark handled in
/// the catalog). Nothing outside the design system should reference these directly; features consume the
/// semantic `DSColor` tokens, which alias into here. This is the single place asset names are spelled.
enum DSPalette {
    static let paper           = Color("background")
    static let ink             = Color("textColor")
    static let borderActive    = Color("borderActive")
    static let borderInactive  = Color("borderInactive")
    static let backgroundWrong = Color("backgroundWrong")
    static let keyNone         = Color("backgroundKeyNone")
    static let banner          = Color("bannerBackground")
    static let bronze          = Color("bronze")
    static let cardinal        = Color("cardinal")
    static let darkGrey        = Color("darkGrey")
    static let raisinBlack     = Color("raisinBlack")
    static let silver          = Color("silver")
}
