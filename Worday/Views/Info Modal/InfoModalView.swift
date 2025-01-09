import SwiftUI

struct InfoModalView: View {
    var body: some View {
        VStack(spacing: .space_48pt) {
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
                
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: "smallcircle.filled.circle.fill")
                        .resizable()
                        .frame(width: .size_8pt, height: .size_8pt)
                    Text("Each day, the game provides a new word for you to guess.")
                        .font(.callout)
                }
                
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: "smallcircle.filled.circle.fill")
                        .resizable()
                        .frame(width: .size_8pt, height: .size_8pt)
                    Text("Rearrange the letters to form the correct word.")
                        .font(.callout)
                }
                
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: "smallcircle.filled.circle.fill")
                        .resizable()
                        .frame(width: .size_8pt, height: .size_8pt)
                    Text("The color of the tiles will change to show how close your guess was to the word.")
                        .font(.callout)
                }
                
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: "smallcircle.filled.circle.fill")
                        .resizable()
                        .frame(width: .size_8pt, height: .size_8pt)
                    Text("Once you've guessed the word, its meaning will be revealed.")
                        .font(.callout)
                }
            }
            
            Text("Made with ")
            +
            Text(Image(systemName: "heart.fill"))
                .foregroundColor(.red)
            +
            Text(" in Berlin")
        }
        .padding(.space_24pt)
    }
}

#Preview {
    InfoModalView()
}
