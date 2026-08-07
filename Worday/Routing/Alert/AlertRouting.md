# Alert Routing

Programmatic alerts in the same **router + host** shape as Navigation and Modal Routing (no provider —
the alert content is a plain value). A feature surfaces an alert by asking the router; a dumb
`ViewModifier` host drives SwiftUI's `.alert`.

## Components

- **`AlertState`** — a value description of an alert: `title`, optional `message`, and `buttons` (each a
  `title`, a `Role` — `.standard` / `.cancel` / `.destructive` — and an `onTap: UserAction`). `Equatable`.
- **`AlertRouter`** (`AlertRouterType`, `@Observable`, `.container`) — holds `presented: AlertState?` with
  `present`/`dismiss`. One alert at a time; presenting replaces.
- **`AlertHostModifier`** — a dumb `ViewModifier` (`.alertHost(router:)`) that renders the router's
  `AlertState` into `.alert`, maps each `Role` to a SwiftUI `ButtonRole`, and routes SwiftUI's auto-dismiss
  (any button tap) back through `dismiss()` — so button closures stay pure (just the action). Applied at
  the app root **outermost**, after `.modalHost`, so alerts sit above modals and pushed screens.

Feature-specific alert content is built with small factories kept next to the feature, not on `AlertState`
— e.g. `AlertState.meaningLoadFailure(onRetry:)` in `Domain/Dictionary`.

## How to use

Inject `AlertRouterType` and present a value:

```swift
alertRouter.present(.meaningLoadFailure(onRetry: { [weak self] in self?.retry() }))
alertRouter.present(.init(title: "Something went wrong",
                          message: "Please delete and re-install the app.",
                          buttons: [.init(title: "OK", role: .cancel, onTap: .empty)]))
```

Dismissal is automatic on any button tap (routed through `dismiss()`), so a button's `onTap` performs only
its action; a plain "OK" is `.empty`.

**Current consumers:** the word-meaning screen and the finished-game meaning section present a Retry alert
when the dictionary lookup fails (`WordMeaningViewModel` / `FinishedGameViewModel`); the game presents a
fatal-error alert when the day's word can't be resolved (`GameViewModel`).

The host is view-layer and not unit-tested (see `WordayTests/Tests/AlertRoutingTestNotes.md`); the
behaviour — presenting the right alert, and Retry re-loading — is asserted on an `AlertRouterMock`.
