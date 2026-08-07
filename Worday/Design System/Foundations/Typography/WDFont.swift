import SwiftUI

/// Legacy font constants, retained as thin aliases onto the semantic `DSFont` roles so screens written
/// before the typography system keep their exact look. New code uses `.dsFont(_:)` directly; these are
/// migrated away as each screen is touched.
let wdFont: Font   = DSFont.gameTile.font
let wdFont24: Font = DSFont.gameHeading.font
let wdFont20: Font = DSFont.gameTitle.font
let wdFont16: Font = DSFont.label.font
let wdFont12: Font = DSFont.labelSmall.font
let wdFont8: Font  = DSFont.gameCaption.font

let titleFont: Font  = DSFont.largeTitle.font
let titleFont2: Font = DSFont.impact.font
let titleFont3: Font = DSFont.title.font
let bodyFont: Font   = DSFont.body.font
