import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .frame(width: 200, height: 200)
            ProgressView()
        }
    }
}

#Preview {
    EmptyStateView()
}
