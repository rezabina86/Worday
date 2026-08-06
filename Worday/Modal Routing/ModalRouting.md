# Modal Routing

Programmatic modal presentation in the ProjectPrivacy **router + host + provider** shape — the modal
counterpart of Navigation Routing. A feature presents a modal by asking the router; a dumb `ViewModifier`
host drives `.sheet`/`.fullScreenCover`; a provider maps the destination to its view.

## Components

- **`ModalDestination`** — a `Hashable`, `Identifiable` value enum of every modal (`.info`), each
  declaring a `presentationStyle` (`ModalPresentationStyle`: `.sheet(detents:)` today, `.fullScreenCover`
  supported by the host for later). Cases carry only values, never a view state.
- **`ModalRouter`** (`ModalRouterType`, `@Observable`, `.container`) — holds `presented: ModalDestination?`
  with `present`/`dismiss`.
- **`ModalHostModifier`** — a dumb `ViewModifier` (`.modalHost(router:provider:)`) that observes the
  router and drives `.sheet(item:)` / `.fullScreenCover(item:)` (disjoint by `presentationStyle`), routing
  a system dismiss back through `router.dismiss()`. Applied at the app root **outermost** (after
  `.navigationHost`) so a modal covers a pushed screen.
- **`ModalDestinationViewProvider`** (`ModalDestinationViewProviderType`) — the only place that maps a
  `ModalDestination` to its screen, built via injected converters/factories.

## How to use

**Present / dismiss** — inject `ModalRouterType`:

```swift
modalRouter.present(.info)
modalRouter.dismiss()          // also happens automatically on a system swipe-to-dismiss
```

**Add a new modal:**

1. Add a case to `ModalDestination` and give it a `presentationStyle` (`.sheet([...])` or
   `.fullScreenCover`).
2. Add an arm to `ModalDestinationViewProvider.destinationView(for:)`; inject its builder and register the
   provider's dependency in `ViewDependencies`.
3. Present it from the interaction (`modalRouter.present(.newModal)`).

The host never changes. Hosts and the `AnyView` provider are view-layer (not unit-tested — see
`RoutingTestNotes.md`); the behaviour (presenting the right destination) is asserted on a `ModalRouterMock`.
