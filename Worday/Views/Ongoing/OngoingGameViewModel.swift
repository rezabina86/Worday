import Foundation
import Observation

protocol OngoingGameViewModelFactoryType {
    func make(with word: String) -> OngoingGameViewModelType
}

struct OngoingGameViewModelFactory: OngoingGameViewModelFactoryType {
    let wordProviderUseCase: WordProviderUseCaseType
    let arrayShuffle: ArrayShuffleType
    let modalRouter: ModalRouterType
    let attemptTrackerUseCase: AttemptTrackerUseCaseType

    func make(with word: String) -> OngoingGameViewModelType {
        OngoingGameViewModel(word: word,
                             wordProviderUseCase: wordProviderUseCase,
                             arrayShuffle: arrayShuffle,
                             modalRouter: modalRouter,
                             attemptTrackerUseCase: attemptTrackerUseCase)
    }
}

protocol OngoingGameViewModelType: AnyObject {
    var viewState: GameViewState.OngoingGameViewState { get }
}

@Observable
final class OngoingGameViewModel: OngoingGameViewModelType {

    // MARK: - Life Cycle

    init(word: String,
         wordProviderUseCase: WordProviderUseCaseType,
         arrayShuffle: ArrayShuffleType,
         modalRouter: ModalRouterType,
         attemptTrackerUseCase: AttemptTrackerUseCaseType) {
        self.word = word.split(separator: "").map { String($0) }
        self.shuffledCharacters = arrayShuffle.shuffle(array: self.word)
        self.wordProviderUseCase = wordProviderUseCase
        self.arrayShuffle = arrayShuffle
        self.modalRouter = modalRouter
        self.attemptTrackerUseCase = attemptTrackerUseCase
    }

    // MARK: - Publics

    var viewState: GameViewState.OngoingGameViewState {
        .init(
            characters: characters,
            numberOfTries: attemptTrackerUseCase.numberOfTries,
            keyboardViewState: makeKeyboardViewState,
            onTapInfoButton: .init { [weak self] in self?.presentInfoModal() }
        )
    }

    // MARK: - Privates

    @ObservationIgnored private let word: [String]
    @ObservationIgnored private let shuffledCharacters: [String]

    @ObservationIgnored private let wordProviderUseCase: WordProviderUseCaseType
    @ObservationIgnored private let arrayShuffle: ArrayShuffleType
    @ObservationIgnored private let modalRouter: ModalRouterType
    @ObservationIgnored private let attemptTrackerUseCase: AttemptTrackerUseCaseType

    private var characters: [GameViewState.OngoingGameViewState.Character] = [
        .empty(id: "0"), .empty(id: "1"), .empty(id: "2"), .empty(id: "3"), .empty(id: "4")
    ]

    private var makeKeyboardViewState: KeyBoardViewState {
        let keys: [KeyViewState] = shuffledCharacters.enumerated()
            .map { index, char in
                    .init(
                        id: "\(index)",
                        character: char,
                        onTap: .init { [weak self] in self?.updateCharacters(with: char) }
                    )
            }
        return .init(
            keys: keys,
            onTapEnter: .init { [weak self] in self?.performEnter() },
            onTapDelete: .init { [weak self] in self?.performDelete() }
        )
    }

    private func presentInfoModal() {
        modalRouter.present(.info)
    }

    private func updateCharacters(with char: String) {
        guard let index = characters.firstIndex(where: { $0.isEmpty }) else {
            return
        }
        characters[index] = .init(id: "\(index)", state: .draft(char: char))
    }

    private func performDelete() {
        guard let index = characters.lastIndex(where: { $0.isEmpty == false }) else {
            return
        }
        characters[index] = .empty(id: "\(index)")
    }

    private func performEnter() {
        guard characters.allSatisfy({ $0.isEmpty == false }) &&
              characters.contains(where: { $0.isDraft }) else {
            return
        }

        var charactersToUpdate: [GameViewState.OngoingGameViewState.Character] = []

        for (index, character) in characters.enumerated() {
            guard let char = character.character else { return }
            if word[index] == char {
                charactersToUpdate.append(.init(id: "\(index)", state: .correct(char: char)))
            } else {
                charactersToUpdate.append(.init(id: "\(index)", state: .misplaced(char: char)))
            }
        }

        characters = charactersToUpdate
        attemptTrackerUseCase.advance()

        if charactersToUpdate.allSatisfy({ $0.isCorrect }) {
            wordProviderUseCase.store(word: word.joined().lowercased())
        }
    }
}
