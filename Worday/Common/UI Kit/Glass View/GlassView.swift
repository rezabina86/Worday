import SwiftUI

public struct GlassView: View {
    let cornerRadius: CGFloat
    let corners: UIRectCorner?
    let fill: Color
    let opacity: CGFloat
    let shadowRadius: CGFloat

    public init(cornerRadius: CGFloat, corners: UIRectCorner? = .allCorners, fill: Color = .white, opacity: CGFloat = 0.25, shadowRadius: CGFloat = 10.0) {
        self.cornerRadius = cornerRadius
        self.corners = corners
        self.fill = fill
        self.opacity = opacity
        self.shadowRadius = shadowRadius
    }

    public var body: some View {
        if let corners {
            Rectangle()
                .fill(fill)
                .opacity(opacity)
                .shadow(radius: shadowRadius)
                .cornerRadius(cornerRadius, corners: corners)
        } else {
            Rectangle()
                .fill(fill)
                .opacity(opacity)
                .shadow(radius: shadowRadius)
        }
    }
}

struct GlassView_Previews: PreviewProvider {
    static var previews: some View {
        GlassView(cornerRadius: 20.0)
    }
}

//MARK: - View Modifier

struct GlassModifier: ViewModifier {
    let cornerRadius: CGFloat
    let corners: UIRectCorner?
    let fill: Color
    let opacity: CGFloat
    let shadowRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background {
                GlassView(cornerRadius: cornerRadius, corners: corners, fill: fill, opacity: opacity, shadowRadius: shadowRadius)
            }
    }
}

//MARK: - View Extension

extension View {
    public func glass(cornerRadius: CGFloat, corners: UIRectCorner? = .allCorners, fill: Color = .white, opacity: CGFloat = 0.25, shadowRadius: CGFloat = 10.0) -> some View {
        modifier(GlassModifier(cornerRadius: cornerRadius, corners: corners, fill: fill, opacity: opacity, shadowRadius: shadowRadius))
    }
}

public struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

//MARK: - View Extension

extension View {
    public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
