import SwiftUI

/// The dictionary-data acknowledgements screen, pushed from the Info modal. Required by the licenses of
/// the bundled offline dictionary — Wiktionary content is CC BY-SA (attribution + share-alike) and
/// WordNet obliges its copyright notice on all copies (see `tools/PROVENANCE.md`). A dumb view over a
/// value `AcknowledgementsViewState`; because it is shown inside the Info modal's own `NavigationStack`
/// (a sheet sits above the app-root navigation host), it is not a root `NavigationDestination`.
struct AcknowledgementsView: View {

    let viewState: AcknowledgementsViewState

    var body: some View {
        ZStack {
            WDBackground()

            ScrollView {
                VStack(spacing: .space_16pt) {
                    ForEach(viewState.sections) { section in
                        DSCard {
                            VStack(alignment: .leading, spacing: .space_8pt) {
                                DSSectionHeader(section.title)
                                Text(section.body)
                                    .dsFont(.callout)
                                    .foregroundStyle(DSColor.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                if let link = section.link {
                                    DSLink(link.host() ?? link.absoluteString, url: link)
                                        .padding(.top, .space_4pt)
                                }
                            }
                        }
                    }
                }
                .padding(.space_24pt)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(viewState.title)
                    .dsFont(.sectionTitle)
                    .foregroundStyle(DSColor.textPrimary)
            }
        }
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
