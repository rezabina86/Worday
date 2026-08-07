import SwiftUI

/// The DailySort wordmark — the app logo beside its engraved-serif name. Pure-visual leaf.
struct DSWordmark: View {

    var body: some View {
        HStack(spacing: .space_8pt) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: .size_24pt, height: .size_24pt)
            Text("DailySort")
                .dsFont(.sectionTitle)
                .foregroundStyle(DSColor.textPrimary)
        }
    }
}
