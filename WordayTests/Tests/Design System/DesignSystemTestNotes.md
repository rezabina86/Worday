# Design System — Test Notes

The design system is intentionally **not** unit-tested, for the same reason Views aren't: its foundations
are compile-time constants and its components are pure, stateless presentation that hold no logic and make
no decisions.

**Foundations** — `DSFont` / `DSFontFamily`, `DSColor` / `DSPalette`, `MeasurementTokens` (and the legacy
`WDFont` / `ColorTokens` aliases) are just typed constants. There is nothing to assert that the compiler
doesn't already guarantee; that a role reads well or a colour is right is a visual concern, checked in
`#Preview`s and on device.

**Components** — `DSCard`, `DSSectionHeader`, `DSBulletRow`, `DSLink`, `DSWordmark`, and the glass /
background / button primitives are dumb leaf views. They take plain init params, own no state, and render
tokens. Like every View they carry no test; their look is verified in previews.

**Where behaviour is asserted instead** — when a component is driven by a screen's view state, that
screen's converter/view-model test covers the data and the interactions. Today that means
`InfoModalViewStateConverterTests` asserts the acknowledgement attribution content *and* that the Info
modal's ✕ dismiss action calls `modalRouter.dismiss()`. If a future `DS*` component carries an
`Equatable Model` with `UserAction`s, add a `Fake` for that model (under `WordayTests/Fakes/`) and assert
its shape through the consuming screen — never a bespoke mock for the dumb view itself.
