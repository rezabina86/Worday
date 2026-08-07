import SwiftUI

/// A grouped-section heading — the engraved-serif title that sits above a block of content. Pure-visual
/// leaf: plain init param, no state.
struct DSSectionHeader: View {

    // MARK: - Life Cycle

    init(_ title: String) {
        self.title = title
    }

    // MARK: - Publics

    var body: some View {
        Text(title)
            .dsFont(.sectionTitle)
            .foregroundStyle(DSColor.textPrimary)
    }

    // MARK: - Privates

    private let title: String
}
