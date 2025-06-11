import SwiftUI
import AVKit

struct VideoDetailView: View {
    @Environment(\.dismiss) var dismiss
    let player: AVPlayer?
    
    init(videoUrl: URL) {
        player = .init(url: videoUrl)
        print("AVPlayer init with url \(videoUrl.absoluteString)")
    }
    
    init(playerItem: AVPlayerItem) {
        player = .init(playerItem: playerItem)
        print("AVPlayer init with player item")
    }
    
    var body: some View {
        VStack {
            AVPlayerView(player: player)
            
            ScrollView {
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Video Title: this is a sample video title on maximum 2 lines which can be truncated")
                        .font(.title)
                        .lineLimit(2)
                    
                    Text("2 giugno 2025")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    
                    Text("Description of the video content on maximum 2 lines with an expand / collapse button")
                        .font(.body)
                    
                    Text("Here will be placed the related videos:")
                        .font(.title)
                        .lineLimit(2, reservesSpace: true)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .safeAreaInset(
            edge: .top,
            alignment: .center,
            spacing: 0) {
                HStack {
                    Spacer()
                    
                    Button {
                        player?.rate = 0
                        dismiss()
                    } label: {
                        Image(systemName: "multiply")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background {
                    Color.red
                        .ignoresSafeArea()
                }
            }
    }
}

#Preview {
    AVPlayerButton(
        edge: 150,
        videoPayload: .sky
    )
    .tint(Color.white)
}
