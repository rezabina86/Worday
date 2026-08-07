import Foundation

extension ContainerType {
    /// The info-modal screen's view-state converter.
    func registerInfoModalDependencies() {
        register { container in
            InfoModalViewStateConverter(bundle: Bundle.main, modalRouter: container.resolve())
            as InfoModalViewStateConverterType
        }
    }
}
