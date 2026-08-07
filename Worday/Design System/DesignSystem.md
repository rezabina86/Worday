# DailySort Design System

A small, token-driven, **two-tier** design system: raw faces/palette → semantic roles/tokens →
`DS`-prefixed components. Features consume only the *semantic* tier and the components — never a raw face,
a raw asset name, or a system font/colour. The architecture follows ProjectPrivacy's; the values are
DailySort's own (glass surfaces, serif/mono faces, the cardinal-red accent).

```
Design System/
├── Foundations/
│   ├── Typography/  DSFontFamily (raw faces) → DSFont (semantic roles) + .dsFont(_:)
│   ├── Colors/      DSPalette (raw → asset colorsets) → DSColor (semantic)
│   └── Metrics/     MeasurementTokens (size / space / radius scales)
└── Components/
    ├── Glass/        GlassView · GlassPane · View+Glassify   (Liquid Glass, gated)
    ├── Background/    WDBackground   (the animated gradient backdrop)
    ├── Button/        Buttons (.wdButtonStyle())
    ├── Surface/       DSCard          (glass content card)
    ├── Wordmark/      DSWordmark
    └── Content/       DSSectionHeader · DSBulletRow · DSLink
```

## Foundations

### Typography — `DSFont` + `.dsFont(_:)`
`DSFont` is the semantic type scale — ask for a **role**, never a size. Apply with `.dsFont(_:)` (a
`View` **and** `Text` modifier that sets the font and its paired tracking together):

```swift
Text("Dictionary data").dsFont(.sectionTitle)
```

Roles resolve through `DSFontFamily`, the raw faces and the single swap point:
`display` = Baskerville · `chrome` = Copperplate · `impact` = Impact · `mono` = system monospaced ·
`ui` = system sans. **Content roles (`sectionTitle`, `callout`, `caption`) are clean system sans** — the
Copperplate engraved face is display-only, never body copy. Display serif is `largeTitle`/`title`
(Baskerville); the gameplay tiles/counters are `gameTile`/`gameHeading`/`gameTitle`/`gameCaption` (mono).

Every feature uses `.dsFont(_:)` — the pre-DS `wdFont*`/`titleFont`/`bodyFont` constants have been
removed. (A few screens still use raw system text styles like `.font(.caption)`; convert those to a
`DSFont` role when touched.)

### Colours — `DSColor` (→ `DSPalette`)
`DSColor` is the semantic layer features use (`textPrimary`, `textSecondary`, `background`, `border`,
`brand`, `link`, `correct`, `misplaced`, …). It aliases `DSPalette`, the raw layer that spells the asset
colorset names (light/dark handled in the catalog). **Links use `DSColor.link` — the cardinal brand red,
never system blue.** Adding a colour = add a `DSColor` token mapped to a `DSPalette` entry; never inline
`Color("…")` in a view. Inside DS components (e.g. `WDBackground`) the raw `DSPalette` tier is used
directly; features use only `DSColor`.

### Metrics — `MeasurementTokens`
`CGFloat` tokens on a 4pt rhythm: `size_*pt`, `space_*pt`, `radius_*`. A raw spacing/size/radius literal
in a view is a smell.

## Components
`DS`-prefixed, one folder per family, dumb leaf views. Pure-visual leaves (everything here today) take
plain init params. A component with interaction/state would carry a nested `Equatable Model` whose
interactions are `UserAction`s, and would live inside its screen's `Equatable` view state (so screens stay
snapshot-testable) — the same pattern the app's routing/view-state code already uses. Glass chrome gates
Liquid Glass (`if #available(iOS 26.0, *)`) with a translucent fallback; content surfaces stay solid.

## Testing
DS foundations and components are **not** unit-tested — they are pure, stateless presentation with no
logic (rationale: `WordayTests/Tests/Design System/DesignSystemTestNotes.md`). Tokens are compile-time
constants; look and motion are verified in `#Preview`s and on device. Where a screen consumes a
component, that screen's converter/view-model test asserts the data and that each `UserAction` drives the
right collaborator (e.g. the Info modal's ✕ → `modalRouter.dismiss()` in `InfoModalViewStateConverterTests`).

## Adding to the system
1. A new **type role** → add a `DSFont` case (+ its `Spec`); reuse a `DSFontFamily` face or add one.
2. A new **colour** → add a `DSColor` token → a `DSPalette` entry → an asset colorset.
3. A new **component** (on its 2nd use) → a `DS*` view in its own `Components/<Family>/` folder, built
   only from `DSFont`/`DSColor`/`MeasurementTokens` and existing primitives; add a `#Preview`.
