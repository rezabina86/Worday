import Foundation

extension ContainerType {
    /// The word-list screen's view-state converter.
    func registerWordListDependencies() {
        register { container in
            WordListViewStateConverter(playedWordsLibrary: container.resolve(),
                                       navigationRouter: container.resolve())
            as WordListViewStateConverterType
        }
    }
}
