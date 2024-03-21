import SwiftUI

struct ContentView: View {
    @State private var showVideoPlayer = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Button {
                    showVideoPlayer.toggle()
                } label: {
                    VStack(spacing: 20) {
                        Image(systemName: "play.fill")
                            .font(.largeTitle)
                        
                        Text("VLC Player")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    .padding(20)
                    .background { Color.secondary }
                    .cornerRadius(20)
                }
                
                Button {
                    print("Open AVPlayerView")
                } label: {
                    VStack(spacing: 20) {
                        Image(systemName: "play.fill")
                            .font(.largeTitle)
                        
                        Text("AVPlayer   ")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    .padding(20)
                    .background { Color.secondary }
                    .cornerRadius(20)
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
