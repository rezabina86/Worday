import Foundation

extension ContainerType {
    func registerDictionaryDependencies() {
        register { container in
            DictionaryRepository(wordDatabase: container.resolve()) as DictionaryRepositoryType
        }

        register { container in
            DictionaryUseCase(dictionaryRepository: container.resolve()) as DictionaryUseCaseType
        }
    }
}
