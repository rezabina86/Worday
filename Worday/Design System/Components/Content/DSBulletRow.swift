import SwiftUI

/// A bulleted list item — a brand-tinted dot beside a line of body copy. Used for short instructional
/// lists (e.g. "How the Game Works"). Pure-visual leaf.
struct DSBulletRow: View {

    // MARK: - Life Cycle

    init(_ text: String) {
        self.text = text
    }

    // MARK: - Publics

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: .space_12pt) {
            Circle()
                .fill(DSColor.brand)
                .frame(width: .size_8pt, height: .size_8pt)
                .alignmentGuide(.firstTextBaseline) { $0[.bottom] - $0.height * 0.15 }
            Text(text)
                .dsFont(.callout)
                .foregroundStyle(DSColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Privates

    private let text: String
}
