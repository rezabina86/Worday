import SwiftUI

struct InfoModalView: View {
    
    let viewState: InfoModalViewState
    
    var body: some View {
        VStack(spacing: .space_48pt) {
            Spacer(minLength: .space_8pt)
            
            HStack {
                Image("logo")
                    .resizable()
                    .frame(width: .size_24pt, height: .size_24pt)
                
                Text("DailySort")
                    .font(bodyFont)
                    
            }
            
            VStack(alignment: .leading, spacing: .space_12pt) {
                Text("How the Game Works:")
                    .font(.body)
                    .bold()
                
                ForEach(viewState.topics, id: \.self) { topic in
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: "smallcircle.filled.circle.fill")
                            .resizable()
                            .frame(width: .size_8pt, height: .size_8pt)
                        Text(topic)
                            .font(.callout)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            
            Spacer()
            
            VStack {
                Text("Made with ")
                +
                Text(Image(systemName: "heart.fill"))
                    .foregroundColor(.red)
                +
                Text(" in Berlin")
                
                Text(viewState.versionString)
                    .font(.caption2)
            }
        }
        .padding(.space_24pt)
        .presentationDetents([.large])
    }
}

struct InfoModalViewState: Equatable {
    let topics: [String]
    let versionString: String
}

#Preview {
    InfoModalView(viewState: .init(topics: [
        "Each day, the game provides a new word for you to guess.",
        "Rearrange the letters to form the correct word.",
        "The color of the tiles will change to show how close your guess was to the word.",
        "Once you've guessed the word, its meaning will be revealed."
    ], versionString: "Version 1.3.0"))
}
