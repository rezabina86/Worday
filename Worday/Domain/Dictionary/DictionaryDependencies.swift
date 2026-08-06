import Foundation

extension ContainerType {
    func registerDictionaryDependencies() {
        register { container in DictionaryService(client: container.resolve()) as DictionaryServiceType }

        register { container in
            DictionaryRepository(dictionaryService: container.resolve()) as DictionaryRepositoryType
        }

        register { container in
            DictionaryUseCase(dictionaryRepository: container.resolve()) as DictionaryUseCaseType
        }
    }
}
