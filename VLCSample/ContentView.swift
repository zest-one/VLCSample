import SwiftUI
import AVFoundation

struct ContentView: View {
    let showVLCButton: Bool
    let showAVPlayerButton: Bool
    let edge: CGFloat
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                if showVLCButton {
                    VLCPlayerButton(
                        edge: edge,
                        videoPayload: .sky
                    )
                }
                
                if showAVPlayerButton {
                    AVPlayerButton(
                        edge: edge,
                        useSampleFile: true
                    )
                }
            }
        }
        .tint(.white)
    }
}

#Preview {
    ContentView(
        showVLCButton: false,
        showAVPlayerButton: true,
        edge: 150
    )
}
