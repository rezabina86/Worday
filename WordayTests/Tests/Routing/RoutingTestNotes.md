# Routing — Test Notes

Covers all three routing flavours under `Routing/` (Navigation, Modal, Alert).

The **routers** (`NavigationRouter`, `ModalRouter`, `AlertRouter`) are covered by `NavigationRouterTests`,
`ModalRouterTests`, and `AlertRouterTests`, and every routing registration is exercised by
`DependencyGraphTests`. The following routing types are intentionally **not** unit-tested, for the same
reason Views aren't:

- **`NavigationHostModifier` / `ModalHostModifier` / `AlertHostModifier`** — dumb `ViewModifier`s. They own
  no business logic; they observe a router and drive `NavigationStack` / `.sheet` / `.fullScreenCover` /
  `.alert`, routing SwiftUI's own pops/dismiss/button taps back through the router. There is nothing to
  assert that isn't SwiftUI's behaviour.
- **`NavigationDestinationViewProvider` / `ModalDestinationViewProvider`** — thin `AnyView` builders: a
  `switch` from a destination case to a screen built via an injected factory/converter. They return
  `AnyView`, which is not meaningfully assertable, and hold no decision logic beyond the mapping. Their
  construction is verified by `DependencyGraphTests`; the screens they build are tested via their own
  view-model/converter suites. (The alert host needs no provider — `AlertState` is a plain value.)

The *behaviour* that matters — pushing/presenting the right destination or alert — is asserted where it
originates: `FinishedGameViewModelTests` (`push(.wordList)` and the meaning-load retry alert),
`WordListViewStateConverterTests` (`push(.wordMeaning(word:))`), `OngoingGameViewModelTests`
(`present(.info)`), `WordMeaningViewModelTests` (the retry alert, and that Retry re-loads), and
`GameViewModelTests` (the fatal-error alert). Because `AlertState` carries `UserAction` closures, those
tests assert on inspectable fields (title, button titles) and invoke the buttons — rather than comparing
whole `AlertState` values (`UserAction` equality is flag-based).
