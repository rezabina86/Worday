import SwiftUI

struct WordListView: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: .space_12pt) {
                ForEach(viewState.cards) { card in
                    Button {
                        card.onTap.action()
                    } label: {
                        createCard(card)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.space_12pt)
        }
        .navigationTitle(viewState.navogationTitle)
    }
    
    let viewState: WordListViewState
    
    // MARK: - Privates
    @ViewBuilder
    private func createCard(_ card: WordListViewState.Card) -> some View {
        VStack(alignment: .center, spacing: .space_2pt) {
            Text(card.word.uppercased())
                .font(titleFont3)
            
            Text(card.dateSection.title)
                .font(.caption)
            
            Text(card.dateSection.date, style: .date)
                .font(.caption)
            
        }
        .padding(.space_12pt)
        .frame(maxWidth: .infinity)
        .frame(height: .size_96pt + .size_8pt)
        .cornerRadius(.radius_medium)
        .overlay(
            RoundedRectangle(cornerRadius: .radius_medium)
                .stroke(Color.primary, lineWidth: 1 / 2)
        )
    }
    
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: .space_12pt), count: 2)
}

struct WordListViewState: Equatable {
    let navogationTitle: String
    let cards: [Card]
}

extension WordListViewState {
    struct Card: Identifiable, Equatable {
        let id: String
        let dateSection: DateSection
        let word: String
        let onTap: UserAction
    }
}

extension WordListViewState.Card {
    struct DateSection: Equatable {
        let title: String
        let date: Date
    }
}

#Preview {
    WordListView(viewState: .init(
        navogationTitle: "Words",
        cards: [
            .init(id: "1", dateSection: .init(title: "Played on:", date: .now), word: "ABCDE", onTap: .empty),
            .init(id: "2", dateSection: .init(title: "Played on:", date: .now), word: "FGHIJ", onTap: .empty),
            .init(id: "3", dateSection: .init(title: "Played on:", date: .now), word: "KLMNO", onTap: .empty),
            .init(id: "4", dateSection: .init(title: "Played on:", date: .now), word: "PQRST", onTap: .empty),
            .init(id: "5", dateSection: .init(title: "Played on:", date: .now), word: "UVWXY", onTap: .empty)
        ])
    )
}
