# ProjectPrivacy Architecture Migration — Design

Status: **approved (brainstorm Stage 1)** · Owner: iOS · Started 2026-08-06

Goal: migrate Worday's architecture to match the reusable conventions of the sibling app
**ProjectPrivacy**, starting with the modal/navigation coordinators. Product-specific ProjectPrivacy
features (Splash, Onboarding, Privacy Screen, Monetization, Home Widgets, PII/Redaction, TabRouter) are
**out of scope** — they don't apply to a single-screen word game.

## Decisions (from the brainstorm)

1. **Single-stack navigation**, not per-tab. Worday has one screen; the router holds one
   `[NavigationDestination]`, no `EntityID<AppTab>` keying.
2. **Value destinations + providers.** Destinations are lightweight `Hashable` value enums; a
   `…ViewProvider` builds each screen's view/view-model lazily via factories — never carry a view model
   or view state through navigation.
3. **Full architecture-migration audit** (this document), sequenced A→B→C→D; the Alert host (E) is
   deferred until a real alert appears.
4. **WordayApp applies the hosts** (`.navigationHost` / `.modalHost` wrap `GameView` at the app root).
5. **Minimal, extensible modal presentation style** — `ModalDestination.presentationStyle` with
   `.sheet(detents)` now; the host also handles `.fullScreenCover` so adding one later is a new case, not
   a rewrite. No fitted-sheet machinery until needed.

Each phase is its own PR (`[WRD-N] …`), TDD, green baseline, reviewed before the next.

---

## Phase A — Modal + Navigation routing (WRD-43)

Replace the inline navigation/sheet wiring in `GameView` with ProjectPrivacy's **router (state) +
`ViewModifier` host + `…ViewProvider`** shape, and slim destinations to value cases.

### Target file layout

```
Worday/Navigation Routing/            (renamed from "Navigation Router")
  NavigationDestination.swift
  NavigationRouter.swift
  NavigationHostModifier.swift
  NavigationDestinationViewProvider.swift
Worday/Modal Routing/                 (renamed from "Modal Coordinator")
  ModalDestination.swift
  ModalRouter.swift                   (renamed from ModalCoordinator)
  ModalHostModifier.swift
  ModalDestinationViewProvider.swift
```

### Types

```swift
// Navigation Routing/NavigationDestination.swift
enum NavigationDestination: Hashable {
    case wordList
    case wordMeaning(word: String)
}

// Navigation Routing/NavigationRouter.swift  (@Observable, .container)
protocol NavigationRouterType: AnyObject {
    var path: [NavigationDestination] { get }
    func push(_ destination: NavigationDestination)
    func pop()
    func popToRoot()
    func setPath(_ path: [NavigationDestination])   // only so the host binding can route system pops back
}

// Modal Routing/ModalDestination.swift
enum ModalDestination: Identifiable, Hashable {
    case info
    var id: String { … }
    var presentationStyle: ModalPresentationStyle { .sheet(detents: [.large]) }   // info = a sheet
}
enum ModalPresentationStyle: Hashable { case sheet(detents: Set<PresentationDetent>); case fullScreenCover }

// Modal Routing/ModalRouter.swift  (@Observable, .container)
protocol ModalRouterType: AnyObject {
    var presented: ModalDestination? { get }
    func present(_ destination: ModalDestination)
    func dismiss()
}
```

The routers are **state-only**; the hosts present. Both stay `@Observable` + `.container` (already true).

### Hosts (dumb `ViewModifier`s)

- `NavigationHostModifier` + `func navigationHost(router:provider:) -> some View` — wraps content in
  `NavigationStack(path: Binding<[NavigationDestination]>)` bound to `router.path` (setter →
  `router.setPath`), `.navigationDestination(for: NavigationDestination.self) { provider.view(for:) }`.
- `ModalHostModifier` + `func modalHost(router:provider:) -> some View` — reads `router.presented`,
  drives `.sheet(item:)` for `.sheet(...)` styles and `.fullScreenCover(item:)` for `.fullScreenCover`
  (disjoint bindings so they never fight); a system dismiss routes back through `router.dismiss()`; sheet
  applies `presentationDetents`.
- Hosts own no logic and are **not unit-tested** — recorded in `RoutingTestNotes.md`.

### Providers (the only place that knows concrete pushed/presented screens)

```swift
protocol NavigationDestinationViewProviderType {
    func view(for destination: NavigationDestination) -> AnyView
}
struct NavigationDestinationViewProvider {          // injects the screens' builders
    // .wordList        -> WordListView(viewState: wordListViewStateConverter.make())
    // .wordMeaning(w)  -> WordMeaningView(viewModel: wordMeaningViewModelFactory.make(word: w))
}

protocol ModalDestinationViewProviderType {
    func view(for destination: ModalDestination) -> AnyView
}
struct ModalDestinationViewProvider {               // injects the screens' builders
    // .info -> InfoModalView(viewState: infoModalViewStateConverter.make())
}
```

### Call-site changes

| Site | Today | After |
|---|---|---|
| `FinishedGameViewModel` (All words) | `router.gotoDestination(.wordList(viewState: converter.make()))` | `router.push(.wordList)` — **drops** `wordListViewStateConverter` dep |
| `WordListViewStateConverter` (card tap) | `router.gotoDestination(.wordMeaning(viewModel: factory.make(word:)))` | `router.push(.wordMeaning(word:))` — **drops** `wordMeaningViewModelFactory` dep |
| `OngoingGameViewModel` (info) | `modalCoordinator.present(.info(converter.make()))` | `modalRouter.present(.info)` — **drops** `infoModalViewStateConverter` dep |

The dropped deps move into the providers.

### `GameView` / `WordayApp`

- Delete the inline `NavigationStack` + `destination(for:)` switch and the inline `.sheet(item:)` switch
  from `GameView`. `GameView` renders only the game content (`view(for: viewModel.viewState)` over
  `WDBackground`).
- `WordayApp` resolves `NavigationRouterType` + `NavigationDestinationViewProviderType` +
  `ModalRouterType` + `ModalDestinationViewProviderType` and wraps:
  `GameView(viewModel:).navigationHost(router:provider:).modalHost(router:provider:)` — **`modalHost`
  outermost** so a modal covers a pushed screen.
- **`GameViewModel` drops** `navigationPath` / `modalDestination` proxies and both router deps entirely
  (it never navigates or presents). Its `GameViewModelType` shrinks to `viewState` + `refresh()` +
  `observeGameFinished()`.

### DI

- Register `NavigationDestinationViewProviderType`, `ModalDestinationViewProviderType`; rename the
  `ModalCoordinatorType` registration to `ModalRouterType` (both stay `.container`); update
  `GameViewModelFactory` (drop routers), `OngoingGameViewModelFactory`/`FinishedGameViewModelFactory`
  (drop the converters/factories that moved to providers). Add all new types to `DependencyGraphTests`.

### Tests

- Rename `ModalCoordinatorMock` → `ModalRouterMock` (property `presented` + `present`/`dismiss` calls).
- Rewrite `NavigationRouterMock` for `path`/`push`/`pop`/`popToRoot`/`setPath`; `NavigationRouterTests`
  for the array-path API.
- New `NavigationDestinationViewProviderMock` / `ModalDestinationViewProviderMock` + their suites.
- Update `FinishedGameViewModelTests` / `WordListViewStateConverterTests` / `OngoingGameViewModelTests`
  to assert value pushes (`push(.wordList)`, `push(.wordMeaning(word:))`, `present(.info)`).
- Hosts + providers-of-`AnyView` are view-layer → not unit-tested; note in `RoutingTestNotes.md`.

---

## Phase B — Shared store projection (WRD-44)

`WordListViewStateConverter` and `StreakUseCase` each call `wordContext.fetchAll()` independently. Adopt
ProjectPrivacy's **`.container` `@Observable` read-projection** over the store:

- Introduce `PlayedWordsLibrary` (`PlayedWordsLibraryType`, `@Observable`, `.container`) that owns the
  observable list derived from `WordStorageModelContextType` — `load()` at launch, `reload()` after a
  word is stored.
- `WordListViewStateConverter` reads `library.words` (word list becomes reactive); `StreakUseCase` reads
  the same window. `WordProviderUseCase.store(...)` calls `library.reload()` after saving.
- The store stays the single source of truth; the projection only derives. Add `===` to
  `DependencyGraphTests`; ship a mock + suite.

## Phase C — `EntityID<T>` (WRD-45)

Adopt ProjectPrivacy's phantom-typed id to replace raw `String`/`Int` ids:

- Add `EntityID<T>` (a `Hashable`, `Sendable`, `Codable` wrapper around a `String`/`UUID` raw value).
- Type the domain ids: `WordStorageEntity.id: EntityID<WordStorageEntity>`, and the id-bearing view-state
  value types (word-list card, meaning, definition). Update `UUIDProviderType` usage to mint `EntityID`s.
- Mechanical but wide (storage + view states + fakes + tests). No behaviour change.

## Phase D — Feature docs + per-feature DI polish (WRD-46)

- Add a `<Feature>.md` "how to use" doc to each feature folder (starting with the new `Navigation Routing`
  / `Modal Routing`), per the Feature Documentation rule.
- Optionally split the per-*area* DI files into per-*feature* files in each feature folder (finer than the
  current `CommonDependencies`/`ViewDependencies` grouping), matching ProjectPrivacy's
  `<Feature>Dependencies.swift`-in-the-feature-folder convention.

## Phase E — Alert host (deferred)

Worday has no alerts today (the meaning-load failure is an inline error state). When the first alert is
needed, adopt ProjectPrivacy's shape verbatim: `AlertRouter` (`@Observable`, `.container`) + a dumb
`AlertHostModifier` (`.alertHost(router:)`) applied at the app root **outside** `modalHost`. Not a task
until then.

---

## Sequencing & guarantees

A → B → C → D, each a standalone PR off `develop`, each ending on a green build + full suite and (for
user-facing changes) a simulator smoke test. E is opened only when a real alert lands. CLAUDE.md's
Navigation & Presentation-Hosts sections are updated in the same PR that introduces each pattern, and
every new DI registration is added to `DependencyGraphTests`.
