import SwiftUI

/// The dictionary-data acknowledgements screen, pushed from the Info modal. Required by the licenses of
/// the bundled offline dictionary — Wiktionary content is CC BY-SA (attribution + share-alike) and
/// WordNet obliges its copyright notice on all copies (see `tools/PROVENANCE.md`). A dumb view over a
/// value `AcknowledgementsViewState`; because it is shown inside the Info modal's own `NavigationStack`
/// (a sheet sits above the app-root navigation host), it is not a root `NavigationDestination`.
struct AcknowledgementsView: View {

    let viewState: AcknowledgementsViewState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .space_24pt) {
                ForEach(viewState.sections) { section in
                    VStack(alignment: .leading, spacing: .space_8pt) {
                        Text(section.title)
                            .font(.headline)
                        Text(section.body)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        if let link = section.link {
                            Link(link.absoluteString, destination: link)
                                .font(.callout)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.space_24pt)
        }
        .navigationTitle(viewState.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AcknowledgementsViewState: Equatable {
    let title: String
    let sections: [Section]

    struct Section: Equatable, Identifiable {
        let id: String
        let title: String
        let body: String
        let link: URL?
    }
}

#Preview {
    NavigationStack {
        AcknowledgementsView(viewState: .init(
            title: "Acknowledgements",
            sections: [
                .init(id: "wiktionary", title: "Wiktionary",
                      body: "Definitions include content from Wiktionary, available under CC BY-SA 4.0.",
                      link: URL(string: "https://www.wiktionary.org")),
                .init(id: "wordnet", title: "Princeton WordNet",
                      body: "WordNet 3.0 Copyright 2006 by Princeton University. All rights reserved.",
                      link: URL(string: "https://wordnet.princeton.edu"))
            ]))
    }
}
