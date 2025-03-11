import SwiftUI

struct WDBackground: View {
    var body: some View {
        ZStack {
            Color.gray
                .opacity(0.25)
                .ignoresSafeArea()

            Color.white
                .opacity(0.7)
                .blur(radius: 200)
                .ignoresSafeArea()

            GeometryReader { proxy in
                let size = proxy.size
                
                Circle()
                    .fill(Color.darkGrey)
                    .padding(50)
                    .blur(radius: 120)
                    .offset(x: -size.width/1.8, y: -size.height/5)
                
                Circle()
                    .fill(Color.bronze)
                    .padding(50)
                    .blur(radius: 150)
                    .offset(x: size.width/1.8, y: size.height/2)
            }
        }
        .ignoresSafeArea(.all)
    }
}
