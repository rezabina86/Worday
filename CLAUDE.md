# Worday (DailySort) — Claude Instructions

## Persona & Standards

Behave as a principal iOS developer at Apple. Apply the highest standards of Swift API design, SOLID
principles, and idiomatic SwiftUI patterns. Prefer clarity, correctness, and long-term maintainability
over shortcuts. Prefer **Swift 6** language mode and concurrency-safe patterns, and add tests for every
new type.

**Be a nitpicker — attention to detail is paramount, in both UI and business logic.** Sweat the small
things: pixel-level fidelity to the design (spacing, sizing, shadows, corner radii, color, motion),
correct edge-case behavior, naming, and state handling. Don't ship "good enough." Every screen,
component, and code path should be the *best version* of itself, using the **latest Apple technologies,
APIs, and Human Interface Guidelines** (newest SwiftUI/SDK affordances, current iOS design language)
rather than older patterns. When something is merely passable, refine it; when a newer Apple API does it
better, use it.

---

## Product Context

Worday ships on the App Store as **DailySort** — a daily word game. The loop:

- **One word per day.** A word is drawn from a bundled common-word list (`common.json`); the puzzle is
  the day's word with its letters **scrambled** into tiles.
- **Unscramble by sorting.** The player rearranges the tiles to spell the hidden word. Tile colours give
  Wordle-style feedback: correct position, misplaced, or not-yet-placed.
- **Learn on success.** Guess correctly and the app unlocks the word's **dictionary meaning** (fetched
  from `dictionaryapi.dev`), and records the word in the player's history.
- **Streaks & history.** Played words are persisted (SwiftData) so the game can show a streak, a total
  count, and a browsable word list with each word's meaning.

This frames product decisions:
- **The daily cadence is the spine.** "Today's word", "already played today", and "come back tomorrow"
  are first-class states. The `DateService`/`CalendarService`/`DateProvider` seams exist so "today" is
  deterministic and testable — never call `Date()`/`Calendar.current` directly.
- **Fully offline.** Word list, gameplay, *and* meanings are all on-device — the daily word, validity,
  and every definition are served from a bundled `dictionary.json` by `WordDatabase` (see
  [Offline Dictionary](#offline-dictionary--word-list-pipeline)). There is no network path anymore (the
  whole `API Client/` layer was removed); the meaning screen still keeps a defensive `.error` state, but
  the bundle guarantees coverage so it should never fire.
- **Small, polished, and fast.** This is a lightweight daily game. Favor a tiny, sharp surface: instant
  launch, fluid tile animations, and a design-system-driven look (see [Design System](#design-system)).

---

## Where Rules Live

Every project rule, convention, or standing instruction the user gives belongs in **this file**. When
the user states a new rule, codify it here in the same change — this document is the single source of
truth for how to work in this codebase.

**Every design or architectural decision must be recorded in *both* this file and local memory, in the
same change** — not one or the other. `CLAUDE.md` is the in-repo source of truth; local memory carries
the rationale ("Why" / "How to apply") across sessions. A decision that lives in only one place is not
durably captured. Keep the two in sync whenever either changes.

---

## Feature Workflow

**This workflow is opt-in, triggered by the word "brainstorm."** When the user says some
variant of *"let's brainstorm"* / *"we need to start brainstorming"* a new feature, follow the
full seven-stage flow below, in order. When the user already knows how to design and architect
the feature and does **not** ask to brainstorm, skip this path entirely and implement directly
(still honoring every other convention in this file). Brainstorming is the gate; absent it, do
not impose these stages.

The stages (each is a phase to actually run, not just to mention):

1. **Brainstorming** — *before any code.* Refine the rough idea through questions, explore
   alternatives, and present the design in sections for the user to validate one at a time. Save
   the agreed design as a design document.
2. **Using git worktrees** — *after the design is approved.* Create an isolated workspace on a
   new branch (per the [Branching & Pull Requests](#branching--pull-requests) naming rules), run
   project setup, and verify a clean test baseline before writing anything.
3. **Writing plans** — *with the approved design.* Break the work into bite-sized tasks (2–5
   minutes each). Every task lists exact file paths, the complete code, and its verification
   steps.
4. **Subagent-driven development / executing plans** — *with the plan.* Either dispatch a fresh
   subagent per task with a two-stage review (first spec compliance, then code quality), or
   execute the plan in batches with human checkpoints.
5. **Test-driven development** — *during implementation.* Enforce RED-GREEN-REFACTOR: write a
   failing test, watch it fail, write the minimal code, watch it pass, commit. Delete any code
   that was written before its test.
6. **Requesting code review** — *between tasks.* Review against the plan and report issues by
   severity; critical issues block further progress until resolved.
7. **Finishing a development branch** — *when the tasks are complete.* Verify the tests, present
   the options (merge / open a PR / keep the branch / discard), and clean up the worktree.

---

## Architecture Conventions

The app is a layered, protocol-oriented, dependency-injected SwiftUI app:

```
View  →  ViewModel (@Observable)  →  UseCase  →  Repository  →  Service
                                                                  ├─ HTTPClient        (network)
                                                                  ├─ ResourceLoader    (bundle)
                                                                  └─ ModelContext      (SwiftData)
```

Always follow the existing architecture conventions (DI wiring, the View + ViewState + ViewModel +
Factory shape, protocol-per-type, per-layer seams) when adding features.

**Search for an existing utility before adding a new shared/Common type.** Before creating any generic
helper, value type, wrapper, protocol, or view (anything that would live in `Common/` or read as "this
is probably reusable"), **grep the repo first**. Reuse the existing primitive; do not duplicate it. The
project already has: `UserAction` (an `Equatable` box around a closure), the `…Type` seams for the
clock (`DateProviderType`, `DateServiceType`, `CalendarServiceType`), `UUIDProviderType`,
`RandomWordProducerType`, `ArrayShuffleType`, `BundleType`, `ResourceLoaderType`, and the DS tokens in
`Common/UI Kit`. Act as a principal engineer who knows the codebase, not one who adds the first thing
that compiles.

---

## Dependency Injection

Never construct dependencies inside entities. All collaborators must be injected via the initializer —
no `let foo = ConcreteType()` inside methods or factory functions. This applies to view models,
factories, use cases, repositories, services, and every other entity.

This includes system singletons **and system codecs** (`UserDefaults.standard`, `URLSession.shared`,
`Bundle.main`, `JSONEncoder()`, `JSONDecoder()`, …) **and the clock** (`Date()` / `Date.now` /
`Calendar.current`): never reference or construct them directly inside an entity. Declare a protocol
named after the system type with the `Type` suffix, conform the system type to it, and inject it. The
seams already exist — `UserDefaultsType`, `EncoderType`/`DecoderType`, `BundleType`, `DateProviderType`,
`DateServiceType`, `CalendarServiceType`, `UUIDProviderType` — inject and read through them.

```swift
// correct — Common/User settings/UserDefaultsType.swift
public protocol UserDefaultsType: AnyObject {
    func object(forKey defaultName: String) -> Any?
    func set(_ value: Any?, forKey defaultName: String)
    func removeObject(forKey defaultName: String)
}
extension UserDefaults: UserDefaultsType {}

// the singleton is referenced only at the composition root (Dependencies.swift)
register { _ -> UserDefaultsType in UserDefaults.standard }

// wrong — inside an entity
let tries = UserDefaults.standard.integer(forKey: "number_of_tries")
```

### The container & scopes

`ContainerType` (a `final class Container`) resolves by type. `register` takes a `Scope`, picked by
*who must own the lifetime*:

- **`.default`** — a **fresh instance every `resolve()`**. The default for stateless, value-type-ish
  collaborators (use cases, repositories, factories, converters, providers).
- **`.container`** — the container caches the instance **strongly** for its entire lifetime (one shared
  instance, stable identity, never released). This is the scope for **durable shared state that must
  survive view/view-model churn**: the routers, the modal coordinator, and any `@Observable` holder read
  by more than one surface (`AttemptTrackerUseCase`, `NavigationRouter`, `ModalCoordinator`). Stable
  identity is load-bearing — `DependencyGraphTests` asserts `===` for these.
- **`.weakContainer`** — the container holds the instance **weakly**: it lives only while something else
  strongly references it, then the next `resolve()` builds a fresh one. Reference types only. Use it for
  a shared-but-disposable service that should tear down when its users go away.

**Never use `.weakContainer` for durable-state holders** — a view-model rebuild has a transient window
where the old owner is gone and the new one isn't built yet; under `.weakContainer` the holder would
deallocate in that window and the next resolve would return a fresh, reset instance (silently dropping an
in-flight task or a counter). These holders are cheap; permanence costs nothing and correctness depends
on it — use `.container`.

### Per-feature registration

The composition root is a thin aggregator. **Each feature owns its wiring in a `<Feature>Dependencies.swift`
file co-located in that feature's own folder** — the registration lives next to the type it constructs, not
in a distant grab-bag. It's declared as an extension method on `ContainerType` — main-actor by default, no
explicit `@MainActor`:

```swift
// Worday/Views/Game/GameDependencies.swift
extension ContainerType {
    func registerGameDependencies() {
        register { container in
            GameViewModelFactory(fetchWordUseCase: container.resolve(), /* … */)
            as GameViewModelFactoryType
        }
    }
}
```

`Dependencies.swift` then only calls each feature's method — no `register` calls of its own:

```swift
func injectDependencies(into container: ContainerType) {
    // Cross-cutting seams + persistence
    container.registerCommonDependencies()
    container.registerStorageDependencies()
    // Routing
    container.registerNavigationRoutingDependencies()
    container.registerModalRoutingDependencies()
    container.registerAlertRoutingDependencies()
    // Network + domain
    container.registerAPIClientDependencies()
    container.registerDictionaryDependencies()
    // Application use cases
    container.registerUseCasesDependencies()
    // Screens
    container.registerGameDependencies()
    container.registerOngoingGameDependencies()
    container.registerFinishedGameDependencies()
    container.registerWordMeaningDependencies()
    container.registerWordListDependencies()
    container.registerInfoModalDependencies()
}
```

The concrete homes: each **screen** folder (`Views/<Screen>/`) registers its own view-model factory or
converter; each **routing** folder (`Routing/Navigation`, `Routing/Modal`, `Routing/Alert`) registers its
router and provider; `Storage/` registers the `ModelContext` seam and `PlayedWordsLibrary`; `Use Cases/`
registers the use cases plus the word-provider pipeline (service → repository → provider) they build on.
Only genuinely **cross-cutting** system seams that belong to no single feature — the bundle loaders, the
clock (`CalendarServiceType`/`DateServiceType`), `UserSettingsType`/`UserDefaultsType`, and the app-wide
`FinishGameRelay` — stay grouped in `registerCommonDependencies()` (they *are* the Common area). A one-off
wrapper seam does not get its own DI file; a feature does.

Adding a dependency means adding its `register` to its feature's file (or a new `<Feature>Dependencies.swift`
plus one aggregator line), never growing a monolith. Every new registration is also added to
`DependencyGraphTests`.

---

## Concurrency (Swift 6)

The project builds in the **Swift 6 language mode** with complete concurrency checking, and the module is
**main-actor-isolated by default** (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` on both targets). This is
the idiomatic model for a UI app of this size: everything — views, view models, factories, routers, the
coordinator, `@Observable` holders, use cases, converters, the DI container, and even the thin network
layer — is `@MainActor` unless explicitly opted out. The rules:

- **Don't sprinkle `@MainActor`.** It is the default, so annotating a view model/router/use case with
  `@MainActor` is redundant — omit it. Only reach for isolation attributes to *opt out*: mark a type or
  member `nonisolated` when it genuinely must run off the main actor, and only after measuring that it
  needs to.
- **All async work uses `async/await` and structured concurrency.** No Combine, no `DispatchQueue`, no
  completion handlers. A one-shot operation is an `async` function; a genuine multi-value stream is an
  `AsyncStream`/`AsyncSequence` or an `@Observable` state holder (see
  [Reactive State & Events](#reactive-state--events)). The network call stays on the main actor — the
  actual socket I/O happens inside `URLSession` off-main, and only the tiny JSON decode runs on-main,
  which is negligible. Introduce a `nonisolated` data path only if a heavy off-main workload appears.
- **`Sendable` for the value types that escape the main actor.** `UserAction` (a closure box invoked only
  on the main actor) is `@unchecked Sendable` so it can live in `static` members and value states; the
  shared JSON codecs are `Sendable`. A type crossing into a `nonisolated` context must be `Sendable`.
- **SwiftData is naturally main-actor here.** `ModelContext`, `ModelContainer`, and the `@Model`
  `WordStorageEntity` are not `Sendable`; because the whole app is main-actor, all
  `WordStorageModelContextType` access already sits on one actor. Never capture a `ModelContext` or a
  `@Model` object into a detached/`nonisolated` task. Reach for `@ModelActor` only if a real
  background-persistence need appears (none today).
- **No timing via a Combine scheduler.** Deterministic waits use an injected clock/sleeper seam, not
  `DispatchQueue.main`.
- Use `@preconcurrency import` only when a framework has not yet adopted concurrency annotations.

**A class-bound `…Type` protocol you assert `===` on must be declared `: AnyObject`** (e.g.
`HTTPClientType`). Comparing two `any Protocol` values with `===` forces an `as AnyObject` bridge that
crashes SILGen in the current toolchain (hit in `DependencyGraphTests`); a class-bound protocol compares
with the native class `===` and sidesteps it.

---

## Reactive State & Events

The app uses **`@Observable` and `async/await` — never Combine** (there is no `import Combine` anywhere;
adding one is a regression). When wiring state or events, pick by the *shape of the signal*:

- **Observable state (a value that changes over time and drives the UI)** → an **`@Observable final
  class`** (main-actor by default) with a plain stored property. This replaces every `CurrentValueSubject` +
  `AnyPublisher` pair. The counter in `AttemptTrackerUseCase`, the `NavigationPath` in `NavigationRouter`,
  the current destination in `ModalCoordinator`, and every view model's `viewState` are `@Observable`
  state, **not** publishers.
- **One-shot async result** (load a meaning, fetch the word) → a plain **`async` function** returning the
  value (or throwing). `DictionaryUseCase`'s `Future<…>.prepend(.loading)` becomes an `async` call whose
  caller renders `.loading` while it is in flight.
- **Fire-and-forget event (a "something happened" pulse with no value)** → an **`AsyncStream`** the
  consumer drives with `for await` inside a `.task`, **or** an `@Observable` generation counter when many
  UI surfaces must merely re-render off it. The game-finished event is `FinishGameRelay.events`
  (`AsyncStream`), consumed by `GameViewModel.observeGameFinished()` from `GameView`'s `.task`.
  App-became-active flows straight from SwiftUI's `scenePhase` (`GameView`'s `.onChange(of:)` calls
  `refresh()`) — there is deliberately **no** `ScenePhaseObserver`/`AppTrigger` re-broadcaster (both were
  removed in the Combine migration); don't reintroduce that indirection.

Never store-and-reassign a view state, and never expose a `viewState` as a publisher. A view reads
`viewModel.viewState` directly and SwiftUI re-renders because the model is `@Observable`. The custom
`ObservedState` property wrapper and the `.task { for await … in viewModel.viewState.values }` bridge are
legacy Combine plumbing and are removed as each screen migrates.

---

## MARK Sections

Every Swift type is organized with these MARK sections, in this order:

```swift
// MARK: - Life Cycle   (init)
// MARK: - Publics      (public/internal methods and properties, incl. the computed viewState)
// MARK: - Privates     (private stored properties — deps and state — and private methods)
```

Include a section even if it has only one member; omit any section that would be empty. Private stored
dependencies go under `Privates`, not inline near the init.

---

## Protocol-Per-Type Pattern

Every concrete collaborator type has a corresponding protocol, named by appending `Type` to the concrete
name, declared in the same file **above** the concrete type.

```swift
protocol WordServiceType {
    func load() throws -> WordEntity
}

final class WordService: WordServiceType { … }
```

All dependency sites (inits, factories, the container) reference the protocol, never the concrete type.
The exceptions are **view models** (their factory is the seam — see below), plain **value types /
view-states** used as data, and pure presentation **Views / DS primitives** (no logic → no protocol).

---

## Naming Conventions

**Types**
- Concrete types: descriptive nouns — `WordProviderUseCase`, `DictionaryRepository`, `NavigationRouter`
- Protocols: concrete name + `Type` — `WordProviderUseCaseType`, `NavigationRouterType`
- Error enums: concrete name + `Error` — `ResourceLoaderError`, `DictionaryRepositoryError`
- View states: `<Name>ViewState`; factories: `<Name>Factory` / `<Name>ViewModelFactory`

**Methods and properties**
- Action verbs for mutating methods: `advance`, `fetch`, `store`, `present`, `reset`
- Boolean predicates with `is`/`has` prefix: `isDateInToday(_:)`
- **Factory methods are `make()`** — never `create`, `build`, or `new`. (The codebase currently uses
  `create()` on factories; new code uses `make()`, and existing factories are renamed as they are
  touched during the refactor.)

**Tests and mocks**
- Test suite: `<ComponentName>Tests`
- Test methods: a **descriptive phrase without a `test` prefix** — `advancesTheAttemptCounter()`,
  `createsErrorStateWhenTheLookupFails()`. (Legacy suites use a `test` prefix; normalize when touched.)
- Mock class: `<ProtocolBaseName>Mock` — `NavigationRouterMock`, `DictionaryUseCaseMock`

---

## Value Types

Prefer structs over classes. Use a struct for all data containers (`WordModel`, `WordMeaningModel`, every
`…ViewState`), and for stateless engines/repositories/converters/factories. Use a `final class` only when
reference semantics are required — an `@Observable` view model / router / holder that owns mutable state,
the DI container, or a mock (mocks are classes so they can be `@unchecked Sendable` with mutable
recording state).

---

## Views & View Models

A screen is three parts — a **View**, a **view state**, and a **view model** — wired by a **factory**.

**The View is dumb.** A SwiftUI `View` renders its view model's `viewState` and forwards user
interactions. It contains **no business logic, makes no decisions, and knows nothing about collaborators**
(routers, use cases). It stores a single `private let viewModel` and reads `viewModel.viewState` in
`body`; nothing else.

**The view state is a value type.** `<Name>ViewState` is an `Equatable` struct (or enum) describing
exactly what the view shows. User interactions are carried as **`UserAction`** (an `Equatable` box around
`() -> Void`), so the whole state stays `Equatable` and snapshot-testable. In tests, use `UserAction.fake`
as the expected value to assert a state's shape while ignoring its closures.

**The view model owns the logic.** It is an **`@Observable final class`** (main-actor by default — see
[Concurrency](#concurrency-swift-6)) exposing a **computed** `var viewState: <Name>ViewState`. It holds the collaborators and any mutable UI state
(private under `Privates`), and maps state → view-state through a pure `private static func
makeViewState(...)` or an injected converter. It has no `…Type` protocol of its own — its factory is the
seam.

Three rules govern state and interaction flow — the view is a pure function of `viewState`, `viewState`
is a pure function of one source-of-truth state, and interactions never *build* a view state, they only
mutate the source of truth and `viewState` re-derives:

- **Rule A — `viewState` is *computed*, never stored-and-reassigned.** Reading it in `body` registers
  `@Observable` reads on exactly the stored state it touches, so re-render is automatic and minimal —
  there is no "publish" step to forget. An interactive value (a tile's state, a selected meaning) is
  **data in the state** re-derived from a stored property; the `UserAction` flips that property and the
  view reflects it on the next read. This *replaces* the Combine `.assign(to:)` / reassign-a-subject
  style — never re-publish a stored state.
- **Rule B — where the source-of-truth state lives is decided by the VM's *lifetime*.** A
  **stable-lifetime** VM (the root game VM, a `@State`-owned sheet VM) keeps mutable state in its **own
  stored properties**. A **rebuildable** VM — one made by `factory.make()` inside a re-running
  `@ViewBuilder` (`.navigationDestination`, `.sheet(item:)`) — keeps it in a **DI-owned `.container`
  `@Observable`** and is a stateless projection of it.
- **Rule C — `UserAction` wiring happens in the computed getter, not in a `static` func.** A pure
  `static makeViewState` maps *data*, but cannot wire an `onTap` that calls instance behavior. Wire each
  `UserAction` in the instance getter, capturing the state owner (`[weak self]`, or the DI-owned
  `@Observable`). An action that only needs an injected *collaborator* (e.g. `navigationRouter.goto(…)`)
  may be wired inside the `static` func.

**Never construct a view model inline.** `SomeView(viewModel: SomeViewModel(...))` is the same
`ConcreteType()` violation banned under [Dependency Injection](#dependency-injection). Every view model
has a factory:

- A protocol `<Name>ViewModelFactoryType` and a concrete `<Name>ViewModelFactory`, declared together.
- The factory holds the view model's collaborators (injected, private) and exposes a single
  `make(...) -> <Name>ViewModel` (main-actor by default — no explicit `@MainActor` needed).
- The factory is registered in the DI container; consumers depend on the `…FactoryType` protocol and call
  `make(...)`, never the view model's initializer.

**Canonical shape:**

```swift
@Observable
final class OngoingGameViewModel {

    // MARK: - Life Cycle

    init(word: String, attemptTracker: AttemptTrackerUseCaseType, modalCoordinator: ModalCoordinatorType) {
        self.word = word
        self.attemptTracker = attemptTracker
        self.modalCoordinator = modalCoordinator
    }

    // MARK: - Publics

    var viewState: OngoingGameViewState {
        Self.makeViewState(
            characters: characters,
            numberOfTries: attemptTracker.numberOfTries,
            onKeyTap: { [weak self] key in self?.place(key) },
            onInfoTap: .init { [weak self] in self?.presentInfo() }
        )
    }

    // MARK: - Privates

    private let word: String
    private let attemptTracker: AttemptTrackerUseCaseType
    private let modalCoordinator: ModalCoordinatorType
    private var characters: [OngoingGameViewState.Character] = .emptyBoard

    private func place(_ key: String) { … }          // mutate `characters`; viewState re-derives
    private func presentInfo() { modalCoordinator.present(.info(…)) }

    private static func makeViewState(…) -> OngoingGameViewState { … }   // pure data → state
}
```

**Views are not unit-tested** — they hold no logic. Each new view gets a one-line note in its test folder
explaining why, named `<Feature>TestNotes.md` (never `README.md`, which collides at build time under
file-system-synchronized groups).

### View State Converters

When the `domain → viewState` transform holds collaborators (a formatter, a date provider, a
`ModelContext` reader) or has non-trivial branching, extract it into a **`<Name>ViewStateConverter`** — a
type conforming to `<Name>ViewStateConverterType` with a single `make(from:) -> <Name>ViewState`. This
keeps view models small: the VM owns *behavior*, the converter owns *rendering*. `WordListViewStateConverter`
and `InfoModalViewStateConverter` are the existing examples (screens with no VM, just a converter + a dumb
view). A **trivial, dependency-free** transform stays a `private static func makeViewState` on the VM —
don't wrap `Int(x) / 60` in a protocol + mock + DI. A dependency-holding converter gets the full
treatment (protocol + concrete + `…Mock` + DI registration + its own test suite) and is injected into the
VM's factory.

---

## Navigation & Modal Routing

Routing follows ProjectPrivacy's **router (state) + `ViewModifier` host + `…ViewProvider`** shape. Three
parts per concern, and a **lightweight value destination** enum:

- **The router holds only state.** `NavigationRouter` (`@Observable`, `.container`) owns
  `path: [NavigationDestination]` with `push`/`pop`/`popToRoot`/`setPath`; `ModalRouter` (`@Observable`,
  `.container`) owns `presented: ModalDestination?` with `present`/`dismiss`. A feature injects the
  `…RouterType` and calls `push(_:)` / `present(_:)` — it never touches a `NavigationStack` or `.sheet`.
- **The host is a dumb `ViewModifier`, applied via a `View` extension** — `.navigationHost(router:provider:)`
  and `.modalHost(router:provider:)`, applied at the app root in `WordayApp` (`.modalHost` **outermost** so
  a modal covers a pushed screen). The host observes the router, drives `NavigationStack` /
  `.sheet(item:)` / `.fullScreenCover(item:)`, and routes SwiftUI's own pops/dismiss back through the
  router (`setPath` / `dismiss`). It owns no logic and is **not** unit-tested (recorded in a
  `…TestNotes.md`). Never present with an inline `NavigationStack`/`.sheet` in a screen.
- **The provider is the only place that maps a destination to a screen.** `NavigationDestinationViewProvider`
  / `ModalDestinationViewProvider` (protocol + concrete) build the screen lazily via injected
  factories/converters (`WordListView(viewState: converter.make())`,
  `WordMeaningView(viewModel: factory.make(word:))`, `InfoModalView(...)`). Adding a destination is a case
  here, never a change to the host. Providers return `AnyView` and are view-layer (not unit-tested).
- **Destinations are lightweight `Hashable` value enums** — `NavigationDestination` (`.wordList`,
  `.wordMeaning(word:)`) and `ModalDestination` (`.info`, each declaring a `presentationStyle`). **Never
  carry a view model or a pre-built view state through a destination** — that smuggles reference/mutable
  state into navigation; carry ids/values and let the provider build the screen.
- **Behaviour is asserted where it originates** — the view model/converter that pushes/presents
  (`push(.wordList)`, `present(.info)`), against a `…RouterMock`.

This is the general **presentation-host** rule: any app-wide decoration (navigation, modals, alerts) is a
`ViewModifier` host driven by a `.container` `@Observable` router — never an inline container or a nested
host `View`. Hosts are applied at the app root and **order is layering**: `.navigationHost` (innermost) →
`.modalHost` → `.alertHost` (outermost), so a modal covers a pushed screen and an alert covers everything.
A navigation/modal host also takes a `…ViewProvider` (the destination→screen map); the **alert** host
needs none — an `AlertState` is a plain value, and feature-specific alert content is built by small
factories kept next to the feature (e.g. `AlertState.meaningLoadFailure(onRetry:)` in `Domain/Dictionary`).

All three flavours live under a single **`Routing/`** parent — `Routing/Navigation`, `Routing/Modal`,
`Routing/Alert` — each subfolder holding its router, host, provider (nav/modal), destinations, doc, and
its own co-located `…RoutingDependencies.swift`. See `Routing/Alert/AlertRouting.md` and
`ProjectPrivacyMigration-Design.md`.

---

## User Settings & Persistence

Two persistence surfaces, each behind an injected seam:

- **Key-value preferences** live in a single typed store: `UserSettingsType` (`AnyObject`) + `UserSettings`
  (`final class`, `.container` scope). Each preference is a typed property (`currentWord`, `numberOfTries`);
  call sites use the accessor, never a raw `UserDefaults` key. `UserDefaults` is wrapped in
  `UserDefaultsType`, bound to the singleton only at the composition root. Keys live in a private
  `CaseIterable enum Key` so `reset()` clears them all.
- **Played-word history** is **SwiftData**: the `@Model WordStorageEntity` (id, word, playedAt) via
  `WordStorageModelContextType` (`ModelContext` conforms). Access stays `@MainActor` (see
  [Concurrency](#concurrency-swift-6)). The default `fetchAll()` sorts by `playedAt` descending. The seam
  is registered **`.container`** (class-bound protocol, `===` in `DependencyGraphTests`) so the writer and
  every reader share **one** `ModelContext` over `sharedModelContainer` — an insert is immediately visible
  to a fetch, with a single stable identity; don't register it `.default` (that hands out a fresh context
  per resolve).

Any codec (`JSONEncoder`/`JSONDecoder`) is injected via `EncoderType`/`DecoderType` — never constructed
inline. Behaviour driven by a setting reads it **live** at the point of use, so a change takes effect
immediately; it is not captured at construction.

---

## Shared Store Projections

When **multiple surfaces read the same persisted collection**, don't let each call the store's
`fetchAll()` itself. Introduce **one `.container`-scoped `@Observable` read-projection** over the store —
the observable window everyone reads.

- **`PlayedWordsLibrary`** (`PlayedWordsLibraryType`, `@Observable`, `.container`) is the projection over
  `WordStorageModelContextType`: it owns `words`, derived via a single `reload()` (called once at launch
  to hydrate in `WordayApp.init`, and again after each change). A failed fetch keeps the last-known-good
  `words` rather than blanking them. The **store stays the single source of truth** — the projection only
  ever derives from it, so the readers can't disagree.
- **Readers take the projection, not the store.** `WordListViewStateConverter` and `StreakUseCase` read
  `playedWordsLibrary.words` — never `wordContext.fetchAll()`. Because it's a shared `@Observable`, a
  change re-renders every reader natively.
- **The writer owns the store and refreshes the projection.** `WordProviderUseCase` writes through
  `WordStorageModelContextType` (insert/save) and then calls `playedWordsLibrary.reload()` — a direct
  call, not a signal. The writer may still read the canonical store directly for its own logic; the
  projection is for the *display* readers.
- `.container` scope + `===` in `DependencyGraphTests` (one stable shared instance). A new display reader
  of the stored words takes `PlayedWordsLibraryType`; a new *store* is given its own projection.

---

## Entity Identifiers (`EntityID<T>`)

A genuine entity's id is an **`EntityID<Entity>`** (`Common/Entity ID`) — a phantom-typed wrapper around a
`String` raw value — never a bare `String`/`Int`. The phantom `Entity` parameter is compile-time only
(only `rawValue` is stored/encoded), so the compiler stops an `EntityID<WordStorageEntity>` being used
where another entity's id belongs.

- **Use it for real entity identity, not list positions.** `WordStorageEntity.id` is an
  `EntityID<WordStorageEntity>`, and a view state that represents a stored entity keys on that identity
  (`WordListViewState.Card.id = word.id`). Do **not** wrap purely **positional `ForEach` render-keys**
  (keyboard keys, character tiles, the enumerated meaning/definition ids) — those stay `String`; an
  `EntityID` there is ceremony, and phantom-typing a list index buys nothing.
- **`nonisolated`.** The module is main-actor-by-default, but an id is a plain value SwiftData and
  `Codable` touch off the main actor, so `EntityID` is declared `nonisolated`. It encodes as the **bare
  string** (a `singleValueContainer`) so its on-disk/on-wire form is just the id.

### SwiftData schema migrations

**Changing a persisted `@Model` property is a schema change — never do it in place on a shipped app.**
Retyping `WordStorageEntity.id` from `String` to `EntityID` would crash existing installs at
`ModelContainer` init (the `fatalError` in `sharedModelContainer`) with no lightweight migration. The
rule:

- Version the schema: a `VersionedSchema` per shape (`WordStorageSchemaV1` = the old `String` id,
  `WordStorageSchemaV2` = the current one), with `typealias WordStorageEntity = <latest>.WordStorageEntity`.
- Provide a `SchemaMigrationPlan` (`WordStorageMigrationPlan`) wired into `sharedModelContainer`. For a
  property **type** change (which SwiftData can't map automatically), the custom stage reads the old rows
  in `willMigrate`, empties the store so the structural change is trivial, and re-inserts them in
  `didMigrate` — **preserving every field**, not just adding/removing columns.
- **Prove the upgrade path with a migration test.** A fresh-install run can't catch a broken migration.
  `WordStorageMigrationTests` writes a real on-disk V1 store and re-opens it with V2 + the plan, asserting
  the rows survived. Any future `@Model` change adds a new version + stage + a migration test.

---

## Offline Dictionary & word-list pipeline

The app ships **no network layer** — the entire `API Client/` folder (`HTTPClient`, `Resource`,
`URLSession*` seams, `DictionaryService`, the `dictionaryapi.dev` call) was removed when meanings moved
on-device. The daily word, word validity, and every definition come from a single bundled resource,
`Worday/Common/Resources/dictionary.json`, read by **`WordDatabase`**.

- **`WordDatabaseType`** (`AnyObject`) + **`WordDatabase`** (`final class`, registered **`.container`**,
  `===` in `DependencyGraphTests`) is the one seam. It decodes the bundle **once at launch** — via the
  injected `ResourceLoaderType` + `DecoderType` — into in-memory collections (`[String]` answers,
  `Set<String>` valid, `[String: WordMeaningModel]` meanings) and exposes `answerWords() -> [String]`,
  `isValid(_:) -> Bool`, and `meaning(for:) -> WordMeaningModel?`. A decode failure is a build-time
  integrity error → `fatalError` (mirrors `sharedModelContainer`). `WordProviderUseCase` draws the daily
  pool from `answerWords()`; `DictionaryRepository` maps `meaning(for:)` (throwing `.noMeaning` on `nil`).
- **JSON-in-memory, not SQLite.** The data is ~7k words / ~380 KB, so the bundle is plain JSON loaded into
  memory — no third-party dependency (matches the existing `ResourceLoader`+`Codable` pattern), trivially
  testable. (SQLite/GRDB would only earn its keep at a much larger scale.)
- **Three tiers in one bundle.** `answers` (the fair, singular, defined daily pool ~1.9k), `valid` (the
  broad clean set for `isValid` ~7k, a superset of answers), and `definitions` (pos + definition for
  answers **plus every legacy word an existing install may hold in history** — the superset that
  guarantees a solved/historical word never reveals a blank meaning offline). Every answer is in `valid`
  and has a definition — asserted by `WordDatabaseTests` against the *shipped* bundle.
- **Never hand-edit `dictionary.json` — regenerate it.** It is generated by the reproducible pipeline in
  **`tools/`** (`build_wordlist.py` → `enrich_wiktionary.py` → `build_wordlist.py` → `build_bundle.py`;
  see `tools/PROVENANCE.md`). Sources: SCOWL/Hunspell (validity), WordNet (glosses + `morphy` plural
  filtering), wordfreq (frequency/difficulty), Wiktionary via kaikki (gap fill). Changing the word set or
  a filter rule means editing a source/rule and re-running — never patching the artifact. A curated
  `tools/data/blocklist.txt` (slurs + clinical terms) and `answers_exclude.txt` (proper nouns) gate the
  output; the plural filter's audit lists are eyeballed on every regen.
- **Attribution is required (CC BY-SA).** Because some definitions derive from Wiktionary (CC BY-SA 4.0)
  and WordNet obliges its copyright notice, the app **must** show the dictionary attribution — the
  `AcknowledgementsView`, reached from the Info modal (its own modal-local `NavigationStack`, since the
  Info modal is a sheet above the app-root nav host). The required notices are built in
  `InfoModalViewStateConverter` and guarded by `InfoModalViewStateConverterTests`. Attribution text lives
  in `tools/PROVENANCE.md`; keep the two in sync.

---

## Design System

All visual constants come from `Common/UI Kit` — never hard-code a colour, size, spacing, radius, or
font in a view:

- **`ColorTokens`** — semantic `Color`s loaded from the asset catalog (`backgroundColor`, `textColor`,
  `borderActiveColor`, `correct`, `misplaced`, …).
- **`MeasurementTokens`** — `CGFloat` size/space/radius tokens (`size_*pt`, `space_*pt`, `radius_*`).
- **`WDFont`** — the app's `Font` constants (`wdFont*`, `titleFont`, `bodyFont`).
- **`Buttons` / `GlassView` / `GlassPane` / `View+Glassify` / `WDBackground`** — the DS primitives (the
  glass surfaces gate the iOS 26 Liquid Glass API behind an availability check with a pre-26 fallback).

Add a token only when a number/colour has design meaning; a genuinely one-off local constant may stay
inline. Extract a DS primitive on the **second** use, not the first. The app ships **zero image assets**
beyond the app icon and logo — brand art is generated in SwiftUI.

---

## Error Handling

Define errors as enums conforming to both `LocalizedError` and `Equatable`, with an `errorDescription`
for every case:

```swift
enum ResourceLoaderError: LocalizedError, Equatable {
    case fileNotFound

    var errorDescription: String? {
        switch self {
        case .fileNotFound: "The requested resource could not be found in the bundle."
        }
    }
}
```

A screen whose data can fail (the meaning lookup) always has an explicit `.error` view state — never a
blank or spinner-forever screen.

---

## Testing

After implementing any change, **verify it compiles AND run the full test suite** before claiming
completion. Build & test with the project's Xcode via `DEVELOPER_DIR` (the shell's `xcode-select` points
at CommandLineTools):

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild test -project Worday.xcodeproj -scheme Worday \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

A green build and suite are necessary but not sufficient for a user-facing change: then **boot the app in
the simulator** and tell the user exactly what to test and how to reach it. Do not commit or open a PR
until they confirm.

### Test Structure

Use the **Swift Testing** framework (`import Testing`) — the whole target already does; never add XCTest.

- Test files live under `WordayTests/Tests/`, mirroring the source folder structure; each maps to exactly
  one source type.
- Suites are plain `struct`s (or `final class` only when a suite needs mutable captured state) with `@Test`
  methods. Prefer a fresh SUT built in `init()`.
- Test methods are descriptive phrases **without** a `test` prefix, ideally with a `@Test("…")` display
  name. Use `Issue.record("…")` and early-return when a precondition can't be met, rather than
  force-unwrapping.

### Mock Pattern

Every mock is a `final class` implementing the `…Type` protocol, marked `@unchecked Sendable`. It records
calls via a nested `enum Call: Equatable` (one case per method, associated values carry the args) appended
to a single `private(set) var calls: [Call] = []`. Return values are `var <method>ReturnValue` properties
with sensible defaults; thrown errors are `var <method>Throws: <Error>?`.

```swift
final class ResourceLoaderMock: ResourceLoaderType, @unchecked Sendable {

    // MARK: - Publics

    enum Call: Equatable {
        case loadResource(name: String, ext: String)
    }

    func loadResource(named name: String, withExtension ext: String) throws -> Data {
        calls.append(.loadResource(name: name, ext: ext))
        if let loadResourceThrows { throw loadResourceThrows }
        return loadResourceReturnValue
    }

    // MARK: - Privates

    private(set) var calls: [Call] = []
    var loadResourceReturnValue: Data = Data()
    var loadResourceThrows: ResourceLoaderError?
}
```

Mocks live under `WordayTests/Mocks/`, mirroring the source folder structure. For an `@Observable` state
holder, the mock exposes the same plain stored property the protocol declares (no subject).

### Test Assertions

Never assert `mock.calls.count == N`. Always assert on the **full** calls array with exact associated
values:

```swift
#expect(mock.calls == [.loadResource(name: "common", ext: "json")])
#expect(mock.calls == [])
```

### Async Test Waits

When a `@MainActor` test must wait for async work to land an observable effect, bound the wait by a
**count of `Task.yield()`s, never wall-clock time**. Add one shared helper
(`WordayTests/Helpers/AsyncTestSupport.swift`, e.g. `waitUntil(maxYields:_:)`) and reuse it — never a
per-suite `ContinuousClock`/`Duration` deadline (a flake under the parallel `@MainActor` run) and never a
copy per suite.

### Keeping Tests in Sync

Every time a new concrete type, protocol, or result type is added, ship all three:

- **Mock** — a `<TypeName>Mock` in `WordayTests/Mocks/` mirroring the source folder.
- **Fake** — if it's a value type used as test data, a `fake(...)` static factory (all params defaulted) in
  an extension under `WordayTests/Fakes/`.
- **Tests** — a `<TypeName>Tests` suite in `WordayTests/Tests/` with full behavioural coverage.

If a type genuinely needs no fake or no mock, leave a one-line note explaining why rather than silently
omitting it. **Codec seams have no bespoke mock** — use the real `JSONEncoder`/`JSONDecoder` and assert on
actual bytes.

### DI Graph Test

`DependencyGraphTests` resolves **every** registered type from a fully-wired container and asserts it
constructs, and asserts `===` identity for each `.container`-scoped holder. Every new DI registration is
added to it, so the composition root can never silently break.

---

## Directory Structure

Source and test files mirror each other folder-for-folder:

```
Worday/
├── Application/            (App entry, WordayApp)
├── Common/                 (DI aggregator + common seams, UI Kit, helpers, entity id)
├── Routing/                (presentation hosts, one subfolder per flavour)
│   ├── Navigation/         (router + host + provider + destinations + its DI file)
│   ├── Modal/
│   └── Alert/
├── Views/<Screen>/         (View + ViewState + ViewModel + Factory (or Converter) + its DI file)
├── Use Cases/              (application use cases + word-provider pipeline DI)
├── Domain/<Feature>/       (domain models + repositories + its DI file)
├── Repositories/
├── API Client/             (HTTPClient, Resource, Services + its DI file)
└── Storage/                (SwiftData model, schema/migration, context seam, projection + its DI file)

WordayTests/
├── Tests/   (mirrors source folder-for-folder)
├── Mocks/   (mirrors source folder-for-folder)
├── Fakes/   (value-type fake builders — flat)
└── Helpers/ (shared test support)
```

The project uses Xcode **file-system-synchronized groups** (`PBXFileSystemSynchronizedRootGroup`), so the
folder layout on disk *is* the Xcode group structure — moving a file with `git mv` reorganizes the project
with no `.pbxproj` edit. DI files are **co-located per feature** (see [Per-feature registration](#per-feature-registration)),
not gathered into one `Views`/area file.

---

## Branching & Pull Requests

Branch names follow:

- Bug fix: `fix/WRD-{ticket}-{explanation}`
- Feature/refactor: `feature/WRD-{ticket}-{explanation}`

`{explanation}` is a short kebab-case summary. The ticket number defaults to the next in sequence — find
the highest existing `[WRD-N]` (latest merged PR / `git log`) and use `N + 1` — unless the user specifies
one. PR titles follow `[WRD-{ticket}] …`. Every change goes through its own PR against `develop`; never
push directly to `develop`. When opening a PR, list every file actually committed — never claim a scope
without verifying `git status`.

`MARKETING_VERSION` in `project.pbxproj` is the source of truth for the app version; `ReleaseNotes.md`
tracks release notes.
