import SwiftUI

struct KeyBoardView: View {
    
    let viewState: KeyBoardViewState
    
    var body: some View {
        VStack(spacing: .space_16pt) {
            HStack(spacing: .space_16pt) {
                ForEach(viewState.keys) { key in
                    buildKey(from: key)
                }
            }
            HStack(spacing: .space_16pt) {
                enterKey
                deleteKey
            }
        }
    }
    
    @ViewBuilder
    private var enterKey: some View {
        Button("ENTER") {
            viewState.onTapEnter.action()
        }
        .font(.caption2)
        .fontWeight(.bold)
        .scaledToFill()
        .minimumScaleFactor(0.01)
        .padding(.space_8pt)
        .foregroundColor(Color.textColor)
        .frame(height: .size_48pt)
        .background(Color.backgroundKeyNoneColor)
        .cornerRadius(.radius_small)
    }
    
    @ViewBuilder
    private var deleteKey: some View {
        Button {
            viewState.onTapDelete.action()
        } label: {
            Image(systemName: "delete.left")
                .fontWeight(.bold)
                .padding(.space_8pt)
                .foregroundColor(Color.textColor)
                .frame(height: .size_48pt)
                .background(Color.backgroundKeyNoneColor)
                .cornerRadius(.radius_small)
        }
    }
    
    @ViewBuilder
    private func buildKey(from viewState: KeyViewState) -> some View {
        Button(viewState.character.uppercased()) {
            viewState.onTap.action()
        }
        .font(.title3)
        .fontWeight(.bold)
        .foregroundColor(Color.textColor)
        .frame(minWidth:29)
        .frame(height: .size_48pt)
        .background(Color.backgroundKeyNoneColor)
        .cornerRadius(.radius_small)
    }
}

struct KeyBoardViewState: Equatable {
    let keys: [KeyViewState]
    let onTapEnter: UserAction
    let onTapDelete: UserAction
}

struct KeyViewState: Equatable, Identifiable {
    let id: String
    let character: String
    let onTap: UserAction
}

extension KeyBoardViewState {
    static let empty: Self = .init(
        keys: [.init(id: "1", character: "A", onTap: .empty),
               .init(id: "2", character: "B", onTap: .empty),
               .init(id: "3", character: "C", onTap: .empty),
               .init(id: "4", character: "D", onTap: .empty),
               .init(id: "5", character: "E", onTap: .empty)],
        onTapEnter: .empty,
        onTapDelete: .empty
    )
}
