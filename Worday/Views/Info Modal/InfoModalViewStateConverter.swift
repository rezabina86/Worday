import Foundation

protocol InfoModalViewStateConverterType {
    func make() -> InfoModalViewState
}

struct InfoModalViewStateConverter: InfoModalViewStateConverterType {
    
    init(bundle: BundleType) {
        self.bundle = bundle
    }
    
    func make() -> InfoModalViewState {
        .init(
            topics: [
                "Each day, the game provides a new word for you to guess.",
                "Rearrange the letters to form the correct word.",
                "The color of the tiles will change to show how close your guess was to the word.",
                "Once you've guessed the word, its meaning will be revealed."
            ],
            versionString: "Version \(bundle.versionDescription ?? "")"
        )
    }
    
    // MARK: - Privates
    private let bundle: BundleType
}
