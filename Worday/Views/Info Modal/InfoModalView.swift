import SwiftUI

struct InfoModalView: View {

    let viewState: InfoModalViewState

    var body: some View {
        NavigationStack {
            ZStack {
                WDBackground()
                content
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    DSWordmark()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewState.dismiss.action()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .tint(DSColor.textPrimary)
                }
            }
        }
        .presentationDetents([.large])
    }

    // MARK: - Privates

    private var content: some View {
        VStack(spacing: .space_32pt) {
            DSCard {
                VStack(alignment: .leading, spacing: .space_16pt) {
                    DSSectionHeader("How the Game Works")
                    VStack(alignment: .leading, spacing: .space_12pt) {
                        ForEach(viewState.topics, id: \.self) { topic in
                            DSBulletRow(topic)
                        }
                    }
                }
            }

            Spacer()

            footer
        }
        .padding(.space_24pt)
    }

    private var footer: some View {
        VStack(spacing: .space_12pt) {
            NavigationLink {
                AcknowledgementsView(viewState: viewState.acknowledgements)
            } label: {
                Text("Acknowledgements")
                    .dsFont(.callout)
                    .foregroundStyle(DSColor.link)
            }

            (
                Text("Made with ").dsFont(.callout)
                + Text(Image(systemName: "heart.fill")).foregroundColor(DSColor.brand)
                + Text(" in Berlin").dsFont(.callout)
            )
            .foregroundStyle(DSColor.textSecondary)

            Text(viewState.versionString)
                .dsFont(.caption)
                .foregroundStyle(DSColor.textSecondary)
        }
    }
}

struct InfoModalViewState: Equatable {
    let topics: [String]
    let versionString: String
    let acknowledgements: AcknowledgementsViewState
    let dismiss: UserAction
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            InfoModalView(viewState: .init(
                topics: [
                    "Each day, the game provides a new word for you to guess.",
                    "Rearrange the letters to form the correct word.",
                    "The color of the tiles will change to show how close your guess was to the word.",
                    "Once you've guessed the word, its meaning will be revealed."
                ],
                versionString: "Version 1.7.0 (1)",
                acknowledgements: .init(title: "Acknowledgements", sections: []),
                dismiss: .empty
            ))
        }
}
