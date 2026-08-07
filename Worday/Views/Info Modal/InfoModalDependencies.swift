import Foundation

extension ContainerType {
    /// The info-modal screen's view-state converter.
    func registerInfoModalDependencies() {
        register { _ in InfoModalViewStateConverter(bundle: Bundle.main) as InfoModalViewStateConverterType }
    }
}
