# Acknowledgements — Test Notes

`AcknowledgementsView` is a dumb view — it renders an `AcknowledgementsViewState` (a value type carrying
the dictionary-data attribution sections) and holds no logic — so, like every other View, it is not
unit-tested.

The content that *matters* — that the app actually shows the licence-required attribution (Wiktionary
CC BY-SA and the Princeton WordNet copyright notice) — is produced by `InfoModalViewStateConverter` and is
asserted in `InfoModalViewStateConverterTests`, which checks the acknowledgement sections include the
Wiktionary and WordNet notices. The screen is reached via a `NavigationLink` inside the Info modal's own
`NavigationStack` (the Info modal is a sheet presented above the app-root navigation host, so this is
deliberately **not** a root `NavigationDestination`).
