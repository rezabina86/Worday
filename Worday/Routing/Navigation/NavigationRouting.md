# Navigation Routing

Programmatic, single-stack navigation in the ProjectPrivacy **router + host + provider** shape. A feature
pushes a screen by asking the router; a dumb `ViewModifier` host owns the `NavigationStack`; a provider
maps each destination to its view. Nothing pushes a `NavigationStack` or a `View` by hand.

## Components

- **`NavigationDestination`** — a `Hashable` value enum of every pushable screen (`.wordList`,
  `.wordMeaning(word:)`). Cases carry only lightweight values, never a view model or view state.
- **`NavigationRouter`** (`NavigationRouterType`, `@Observable`, `.container`) — holds the stack as
  `path: [NavigationDestination]`. Feature-facing API: `push`/`pop`/`popToRoot`. `setPath` exists only so
  the host can route SwiftUI's own pops back through the router.
- **`NavigationHostModifier`** — a dumb `ViewModifier` (`.navigationHost(router:provider:)`) that wraps
  content in a `NavigationStack` bound to `router.path` and resolves pushes through the provider. Applied
  once at the app root in `WordayApp`.
- **`NavigationDestinationViewProvider`** (`NavigationDestinationViewProviderType`) — the only place that
  maps a `NavigationDestination` to its screen, building the view model via injected factories/converters.

## How to use

**Push a screen** — inject `NavigationRouterType` and push a value case:

```swift
navigationRouter.push(.wordMeaning(word: "guide"))   // or .push(.wordList)
navigationRouter.pop()                                // or .popToRoot()
```

**Add a new pushable screen:**

1. Add a case to `NavigationDestination` (lightweight values only).
2. Add an arm to `NavigationDestinationViewProvider.destinationView(for:)` that builds the screen from its
   injected factory/converter; inject that collaborator into the provider (and register it in
   `ViewDependencies`).
3. Push it from wherever the interaction lives (`router.push(.newScreen(...))`).

The host never changes. The pushed screen owns its own nav chrome (title/back). The hosts and the
`AnyView` provider are view-layer and are not unit-tested (see `WordayTests/Tests/RoutingTestNotes.md`);
the *behaviour* — pushing the right destination — is asserted on a `NavigationRouterMock` in the view
model/converter that pushes.
