import SwiftUI

/// An external link styled in the brand accent (never system blue), with a trailing arrow glyph.
/// Opens the URL via SwiftUI's `Link`. Pure-visual leaf.
struct DSLink: View {

    // MARK: - Life Cycle

    init(_ title: String, url: URL) {
        self.title = title
        self.url = url
    }

    // MARK: - Publics

    var body: some View {
        Link(destination: url) {
            HStack(spacing: .space_4pt) {
                Text(title)
                    .dsFont(.callout)
                Image(systemName: "arrow.up.right")
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(DSColor.link)
        }
    }

    // MARK: - Privates

    private let title: String
    private let url: URL
}
