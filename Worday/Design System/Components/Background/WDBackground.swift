import SwiftUI

struct WDBackground: View {
    var body: some View {
        ZStack {
            Color.white
                .opacity(0.25)
                .ignoresSafeArea()
            
            DSPalette.silver
                .opacity(0.7)
                .blur(radius: 200)
                .ignoresSafeArea()
            
            GeometryReader { proxy in
                let size = proxy.size
                
                TimelineView(.animation) { timeline in
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    
                    // Keep time continuous and smooth
                    let x1 = -size.width / 2 + cos(time * 0.7) * 80
                    let y1 = -size.height / 6 + sin(time * 0.7) * 60

                    let x2 = size.width / 3 + sin(time * 0.5) * 70
                    let y2 = size.height / 2 + cos(time * 0.5) * 50
                    
                    ZStack {
                        Circle()
                            .fill(DSPalette.raisinBlack)
                            .padding(50)
                            .blur(radius: 100)
                            .offset(x: x1, y: y1)
                        
                        Circle()
                            .fill(DSPalette.cardinal)
                            .padding(50)
                            .blur(radius: 120)
                            .offset(x: x2, y: y2)
                    }
                }
            }
        }
        .ignoresSafeArea(.all)
    }
}
