import SwiftUI

/// The single extension point that maps a `ModalDestination` to the screen behind it. This is the only
/// place that knows concrete presented views — `ModalHostModifier` stays agnostic. Adding a modal means
/// adding a case here (and injecting whatever builder its screen needs), never touching the host.
@MainActor
protocol ModalDestinationViewProviderType {
    func view(for destination: ModalDestination) -> AnyView
}

struct ModalDestinationViewProvider: ModalDestinationViewProviderType {

    // MARK: - Life Cycle

    init(infoModalViewStateConverter: InfoModalViewStateConverterType) {
        self.infoModalViewStateConverter = infoModalViewStateConverter
    }

    // MARK: - Publics

    func view(for destination: ModalDestination) -> AnyView {
        AnyView(destinationView(for: destination))
    }

    // MARK: - Privates

    private let infoModalViewStateConverter: InfoModalViewStateConverterType

    @ViewBuilder
    private func destinationView(for destination: ModalDestination) -> some View {
        switch destination {
        case .info:
            InfoModalView(viewState: infoModalViewStateConverter.make())
        }
    }
}
