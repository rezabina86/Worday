import SwiftUI

/// A grouped content surface: a glass pane with standard inset, used to sit sections of text/rows on top
/// of `WDBackground`. Wraps the app's `GlassPane` (Liquid Glass on iOS 26, soft translucent fallback
/// before) so cards match the game's chrome instead of a flat system sheet.
struct DSCard<Content: View>: View {

    // MARK: - Life Cycle

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    // MARK: - Publics

    var body: some View {
        GlassPane(cornerRadius: .radius_xlarge, opacity: 0.18, shadowRadius: 8) {
            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.space_20pt)
        }
    }

    // MARK: - Privates

    private let content: Content
}

#Preview {
    ZStack {
        WDBackground()
        DSCard {
            VStack(alignment: .leading, spacing: .space_8pt) {
                DSSectionHeader("Dictionary data")
                Text("Word meanings are bundled for offline use.")
                    .dsFont(.callout)
                    .foregroundStyle(DSColor.textSecondary)
            }
        }
        .padding(.space_24pt)
    }
}
