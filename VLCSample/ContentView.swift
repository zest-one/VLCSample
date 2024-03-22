import SwiftUI

struct ContentView: View {
    private let edge: CGFloat = 150
    @State private var showVLCMediaPlayer = false
    @State private var showAVPlayer = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Button {
                    showVLCMediaPlayer.toggle()
                } label: {
                    VStack(spacing: 20) {
                        Image(systemName: "play.fill")
                            .font(.largeTitle)
                        
                        Text("VLC Player")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                    .frame(width: edge, height: edge)
                    .padding(edge / 10)
                    .background { Color.secondary }
                    .cornerRadius(edge / 10)
                }
                .fullScreenCover(isPresented: $showVLCMediaPlayer) {
                    VLCVideoPlayer(videoPayload: .mock)
                }
                
                Button {
                    showAVPlayer.toggle()
                } label: {
                    VStack(spacing: 20) {
                        Image(systemName: "play.fill")
                            .font(.largeTitle)
                        
                        Text("AVPlayer")
                            .foregroundColor(.white)
                            .font(.title)
                    }
                    .frame(width: edge, height: edge)
                    .padding(edge / 10)
                    .background { Color.secondary }
                    .cornerRadius(edge / 10)
                }
                .fullScreenCover(isPresented: $showAVPlayer) {
                    AVVideoPlayer(videoPayload: .mock)
                }
            }
        }
        .tint(.white)
    }
}

#Preview {
    ContentView()
}
