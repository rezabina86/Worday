import Combine
import Foundation

protocol OngoingGameViewModelFactoryType {
    func create(with word: String) -> OngoingGameViewModelType
}

struct OngoingGameViewModelFactory: OngoingGameViewModelFactoryType {
    let wordProviderUseCase: WordProviderUseCaseType
    let arrayShuffle: ArrayShuffleType
    
    func create(with word: String) -> OngoingGameViewModelType {
        OngoingGameViewModel(word: word,
                             wordProviderUseCase: wordProviderUseCase,
                             arrayShuffle: arrayShuffle)
    }
}

protocol OngoingGameViewModelType {
    var viewState: AnyPublisher<GameViewState.OngoingGameViewState,Never> { get }
}

final class OngoingGameViewModel: OngoingGameViewModelType {
    
    init(word: String,
         wordProviderUseCase: WordProviderUseCaseType,
         arrayShuffle: ArrayShuffleType) {
        self.word = word.split(separator: "").map { String($0) }
        self.shuffledCharacters = arrayShuffle.shuffle(array: self.word)
        self.wordProviderUseCase = wordProviderUseCase
        self.arrayShuffle = arrayShuffle
    }
    
    var viewState: AnyPublisher<GameViewState.OngoingGameViewState, Never> {
        characters.map { [weak self] in
            guard let self else { return .empty }
            return .init(
                characters: $0,
                keyboardViewState: makeKeyboardViewState
            )
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Privates
    private let word: [String]
    private let shuffledCharacters: [String]
    
    private let wordProviderUseCase: WordProviderUseCaseType
    private let arrayShuffle: ArrayShuffleType
    
    private let characters: CurrentValueSubject<[GameViewState.OngoingGameViewState.Character], Never> = .init([
        .empty(id: "0"), .empty(id: "1"), .empty(id: "2"), .empty(id: "3"), .empty(id: "4")
    ])
    
    private var makeKeyboardViewState: KeyBoardViewState {
        let keys: [KeyViewState] = self.shuffledCharacters.enumerated()
            .map { (index, char) in
                    .init(
                        id: "\(index)",
                        character: char,
                        onTap: .init { [weak self] in
                            guard let self else { return }
                            updateCharacters(with: char)
                        }
                    )
            }
        return .init(
            keys: keys,
            onTapEnter: .init { [weak self] in
                guard let self else { return }
                performEnter()
            },
            onTapDelete: .init { [weak self] in
                guard let self else { return }
                performDelete()
            }
        )
    }
    
    private func updateCharacters(with char: String) {
        var charactersToUpdate = self.characters.value
        guard let index = charactersToUpdate.firstIndex(where: { $0.isEmpty }) else {
            return
        }
        let newCharater = GameViewState.OngoingGameViewState.Character(id: "\(index)", state: .draft(char: char))
        charactersToUpdate[index] = newCharater
        self.characters.send(charactersToUpdate)
    }
    
    private func performDelete() {
        var charactersToUpdate = self.characters.value
        guard let index = charactersToUpdate.lastIndex(where: { $0.isEmpty == false }) else {
            return
        }
        let newCharater = GameViewState.OngoingGameViewState.Character.empty(id: "\(index)")
        charactersToUpdate[index] = newCharater
        self.characters.send(charactersToUpdate)
    }
    
    private func performEnter() {
        guard self.characters.value.allSatisfy({ $0.isEmpty == false }) &&
              self.characters.value.contains(where: { $0.isDraft }) else {
            return
        }
        
        var charactersToUpdate: [GameViewState.OngoingGameViewState.Character] = []
        
        for (index, char) in self.characters.value.enumerated() {
            guard let char = char.character else { return }
            if self.word[index] == char {
                charactersToUpdate.append(.init(id: "\(index)", state: .correct(char: char)))
            } else {
                charactersToUpdate.append(.init(id: "\(index)", state: .misplaced(char: char)))
            }
        }
        
        self.characters.send(charactersToUpdate)
        
        if charactersToUpdate.allSatisfy({ $0.isCorrect }) {
            finishGame()
        }
    }
    
    private func finishGame() {
        wordProviderUseCase.store(word: word.joined())
    }
}
