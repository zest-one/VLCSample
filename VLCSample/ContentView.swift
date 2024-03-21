import SwiftUI

struct ContentView: View {
    @State private var showVideoPlayer = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Button {
                
            } label: {
                VStack(spacing: 20) {
                    Image(systemName: "play.fill")
                        .font(.largeTitle)
                    
                    Text("Play Video")
                        .foregroundColor(.white)
                        .font(.headline)
                }
            }
        }
        .tint(.white)
        .fullScreenCover(isPresented: $showVideoPlayer) {
            VideoPlayer(videoPayload: .mock)
        }
    }
}

#Preview {
    ContentView()
}
