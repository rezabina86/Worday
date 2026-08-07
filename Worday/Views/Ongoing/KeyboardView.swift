import SwiftUI

struct KeyBoardView: View {
    
    let viewState: KeyBoardViewState
    
    var body: some View {
        VStack(spacing: .space_8pt) {
            HStack(spacing: .space_8pt) {
                ForEach(viewState.keys) { key in
                    buildKey(from: key)
                }
            }
            HStack(spacing: .space_8pt) {
                enterKey
                deleteKey
            }
        }
    }
    
    @ViewBuilder
    private var enterKey: some View {
        Button {
            viewState.onTapEnter.action()
        } label: {
            Text("ENTER")
                .font(.caption2)
                .fontWeight(.bold)
                .scaledToFill()
                .minimumScaleFactor(0.01)
                .padding(.space_8pt)
                .foregroundColor(DSColor.textPrimary)
                .frame(width: .size_72pt, height: .size_48pt)
                .buttonBackground
        }
    }
    
    @ViewBuilder
    private var deleteKey: some View {
        Button {
            viewState.onTapDelete.action()
        } label: {
            Image(systemName: "delete.left")
                .fontWeight(.bold)
                .padding(.space_8pt)
                .foregroundColor(DSColor.textPrimary)
                .frame(width: .size_48pt, height: .size_48pt)
                .buttonBackground
        }
    }
    
    @ViewBuilder
    private func buildKey(from vs: KeyViewState) -> some View {
        Button {
            vs.onTap.action()
        } label: {
            Text(vs.character.uppercased())
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(DSColor.textPrimary)
                .frame(width: .size_48pt, height: .size_48pt)
                .buttonBackground
        }
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
        keys: [.init(id: "0", character: "A", onTap: .empty),
               .init(id: "1", character: "B", onTap: .empty),
               .init(id: "2", character: "C", onTap: .empty),
               .init(id: "3", character: "D", onTap: .empty),
               .init(id: "4", character: "E", onTap: .empty)],
        onTapEnter: .empty,
        onTapDelete: .empty
    )
}

private extension View {
    @ViewBuilder
    var buttonBackground: some View {
        if #available(iOS 26.0, *) {
            self.glassify(with: .radius_medium)
                .contentShape(Rectangle())
        } else {
            self.background(DSColor.keyNone)
                .cornerRadius(.radius_medium)
                .contentShape(Rectangle())
        }
    }
}
