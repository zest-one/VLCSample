import SwiftUI

struct AVPlayerButton: View {
    var edge: CGFloat = 150
    var videoPayload: VideoPayload = .sky
    private let avPlayerAssetGenerator = AVPlayerAssetGenerator()
    @State private var playerAsset: PlayerAsset?
    @State private var videoData: VideoData?
    
    var body: some View {
        Button {
            Task {
                if
                    let videoUrl = URL(string: videoPayload.videoUrl)
                {
                    do {
                        let vttUrl = try await avPlayerAssetGenerator.bundledVTTURL(from: videoPayload.vttUrl)
                        
                        let playerItem = try await avPlayerAssetGenerator.getAVPlayerAsset(
                            videoUrl: videoUrl,
                            vttUrl: vttUrl
                        )
                        
                        playerAsset = .init(playerItem: playerItem)
                        print("Player Item Loaded")
                    } catch {
                        print("Error: \(error)")
                        videoData = .init(videoUrl: videoUrl)
                    }
                }
            }
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
        .fullScreenCover(
            item: $playerAsset,
            onDismiss: {
                playerAsset = nil
            }
        ) { item in
            VideoDetailView(playerItem: item.playerItem)
        }
        .fullScreenCover(
            item: $videoData,
            onDismiss: {
                videoData = nil
            }
        ) { item in
            VideoDetailView(videoUrl: item.videoUrl)
        }
    }
}

#Preview {
    AVPlayerButton()
        .tint(.white)
}
