# Alert Routing — Test Notes

`AlertRouter` is covered by `AlertRouterTests`, and its registration by `DependencyGraphTests`.

**`AlertHostModifier` is intentionally not unit-tested** — like the navigation/modal hosts it is a dumb
`ViewModifier` that renders the router's `AlertState` into SwiftUI's `.alert` and forwards each button as
a `UserAction`. There is nothing to assert that isn't SwiftUI's own behaviour.

The *behaviour* that matters — presenting the right alert — is asserted where it originates, against an
`AlertRouterMock`: `WordMeaningViewModelTests` / `FinishedGameViewModelTests` (the meaning-load retry
alert, and that Retry re-loads) and `GameViewModelTests` (the fatal-error alert). Because `AlertState`
carries `UserAction` closures, those tests assert on inspectable fields (title, button titles) and invoke
the buttons — rather than comparing whole `AlertState` values (`UserAction` equality is flag-based).
