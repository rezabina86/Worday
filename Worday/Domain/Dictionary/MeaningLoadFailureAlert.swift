import Foundation

/// The alert shown when a word's dictionary meaning fails to load — shared by both meaning surfaces
/// (the pushed word-meaning screen and the finished-game meaning section) so they present the same thing.
/// Kept here (the dictionary domain) rather than on the generic `AlertState` infra.
extension AlertState {
    static func meaningLoadFailure(onRetry: @escaping () -> Void) -> AlertState {
        AlertState(
            title: "Couldn’t load the meaning",
            message: "Check your connection and try again.",
            buttons: [
                .init(title: "Retry", onTap: .init(onRetry)),
                .init(title: "OK", role: .cancel, onTap: .empty)
            ]
        )
    }
}
