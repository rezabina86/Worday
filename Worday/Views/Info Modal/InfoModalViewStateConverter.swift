import Foundation

protocol InfoModalViewStateConverterType {
    func make() -> InfoModalViewState
}

struct InfoModalViewStateConverter: InfoModalViewStateConverterType {
    
    init(bundle: BundleType) {
        self.bundle = bundle
    }
    
    func make() -> InfoModalViewState {
        .init(
            topics: [
                "Each day, the game provides a new word for you to guess.",
                "Rearrange the letters to form the correct word.",
                "The color of the tiles will change to show how close your guess was to the word.",
                "Once you've guessed the word, its meaning will be revealed."
            ],
            versionString: "Version \(bundle.versionDescription ?? "")",
            acknowledgements: Self.makeAcknowledgements()
        )
    }

    // MARK: - Privates
    private let bundle: BundleType

    /// The dictionary-data attribution the app is obliged to show: Wiktionary (CC BY-SA) and WordNet
    /// (copyright notice), plus the supporting data sources. Text mirrors `tools/PROVENANCE.md`.
    private static func makeAcknowledgements() -> AcknowledgementsViewState {
        typealias Section = AcknowledgementsViewState.Section
        let sections: [Section] = [
            Section(
                id: "intro",
                title: "Dictionary data",
                body: "Word meanings in DailySort are bundled for offline use and drawn from the open sources below.",
                link: nil
            ),
            Section(
                id: "wiktionary",
                title: "Wiktionary",
                body: "Some definitions include content from Wiktionary, available under the Creative Commons Attribution-ShareAlike License (CC BY-SA 4.0).",
                link: URL(string: "https://www.wiktionary.org")
            ),
            Section(
                id: "wordnet",
                title: "Princeton WordNet",
                body: "Definitions and lexical data also derive from Princeton WordNet. WordNet 3.0 Copyright 2006 by Princeton University. All rights reserved.",
                link: URL(string: "https://wordnet.princeton.edu")
            ),
            Section(
                id: "supporting",
                title: "Word data",
                body: "Word validity uses Hunspell/SCOWL spell-check data; word frequency uses wordfreq.",
                link: nil
            )
        ]
        return AcknowledgementsViewState(title: "Acknowledgements", sections: sections)
    }
}
