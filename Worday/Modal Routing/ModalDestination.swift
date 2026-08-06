import SwiftUI

/// Every modal the app can present, as a single closed set of lightweight value cases. A feature
/// presents one via `ModalRouterType.present(_:)`; the provider builds the screen behind it.
///
/// Each case declares how it is presented via `presentationStyle`. Today everything is a sheet, but the
/// host also handles `.fullScreenCover`, so adding a full-screen modal later is a new case, not a
/// rewrite.
enum ModalDestination: Identifiable, Hashable {
    /// The "how to play" / info sheet, presented from the ongoing game's info button.
    case info

    var id: String {
        switch self {
        case .info: "info_modal"
        }
    }

    var presentationStyle: ModalPresentationStyle {
        switch self {
        case .info: .sheet(detents: [.large])
        }
    }
}

/// How a `ModalDestination` is presented. `ModalHostModifier` routes each destination to exactly one of
/// `.sheet` / `.fullScreenCover` based on this.
enum ModalPresentationStyle: Hashable {
    case sheet(detents: Set<PresentationDetent>)
    case fullScreenCover
}
