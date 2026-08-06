# Routing — Test Notes

The **navigation/modal routers** (`NavigationRouter`, `ModalRouter`) are covered by `NavigationRouterTests`
and `ModalRouterTests`, and every routing registration is exercised by `DependencyGraphTests`. The
following routing types are intentionally **not** unit-tested, for the same reason Views aren't:

- **`NavigationHostModifier` / `ModalHostModifier`** — dumb `ViewModifier`s. They own no business logic;
  they observe a router and drive `NavigationStack` / `.sheet` / `.fullScreenCover`, routing SwiftUI's
  own pops/dismiss back through the router. There is nothing to assert that isn't SwiftUI's behaviour.
- **`NavigationDestinationViewProvider` / `ModalDestinationViewProvider`** — thin `AnyView` builders: a
  `switch` from a destination case to a screen built via an injected factory/converter. They return
  `AnyView`, which is not meaningfully assertable, and hold no decision logic beyond the mapping. Their
  construction is verified by `DependencyGraphTests`; the screens they build are tested via their own
  view-model/converter suites.

The *behaviour* that matters — pushing/presenting the right destination — is asserted where it
originates: `FinishedGameViewModelTests` (`push(.wordList)`), `WordListViewStateConverterTests`
(`push(.wordMeaning(word:))`), and `OngoingGameViewModelTests` (`present(.info)`).
