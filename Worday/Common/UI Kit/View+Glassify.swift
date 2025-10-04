import SwiftUI

extension View {
    @ViewBuilder
    func glassify() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.clear)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func glassify(with cornerRadius: CGFloat) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.clear.interactive(),
                             in: .rect(cornerRadius: cornerRadius))
        } else {
            self
        }
    }
}
