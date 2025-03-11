import SwiftUI

struct WDButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(wdFont16.bold())
            .foregroundColor(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .stroke(Color.primary.opacity(0.5), lineWidth: 0.5)
            )
    }
}

extension View {
    func wdButtonStyle() -> some View {
        self.modifier(WDButtonStyle())
    }
}
