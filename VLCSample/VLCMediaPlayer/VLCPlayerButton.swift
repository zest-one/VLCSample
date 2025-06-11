import SwiftUI

struct VLCPlayerButton: View {
    var edge: CGFloat = 150
    var videoPayload: VideoPayload = .sky
    @State private var showVLCMediaPlayer = false
    
    var body: some View {
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
            VLCVideoPlayer(videoPayload: videoPayload)
        }
    }
}
