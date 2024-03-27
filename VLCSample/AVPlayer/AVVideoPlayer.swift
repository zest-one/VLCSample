import SwiftUI
import AVKit

fileprivate let loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

struct AVVideoPlayer: View {
    private let vttInterval: CMTime = .init(
        seconds: 0.1,
        preferredTimescale: CMTimeScale(NSEC_PER_SEC)
    )
    let videoPayload: VideoPayload
    let player: AVPlayer?
    @State private var subtitle: String = ""
    @State private var showSubtitles = true
    @State private var vtt: [ClosedRange<Double> : String] = [:]
    
    init(videoPayload: VideoPayload) {
        self.videoPayload = videoPayload
        
        if let url = URL(string: videoPayload.videoUrl) {
            player = .init(url: url)
            print("AVPlayer init with url \(url.absoluteString)")
        } else {
            player = nil
            print("AVPlayer initialisation failed")
        }
    }
    
    var body: some View {
        AVPlayerView(player: player, videoPayload: videoPayload)
            .ignoresSafeArea()
            .task {
                await setUpSubtitles()
            }
            .overlay {
                if !subtitle.isEmpty && showSubtitles {
                    VStack {
                        Color.clear
                            .frame(height: 120)
                            .allowsHitTesting(false)
                        
                        Text(subtitle)
                            .foregroundStyle(Color.white)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black, radius: 3)
                            .frame(maxWidth: .infinity, alignment: .bottom)
                            .padding(.bottom, 16.0)
                    }
                }
            }
            .overlay(alignment: .top) {
                Button {
                    showSubtitles.toggle()
                } label: {
                    Image(systemName: showSubtitles ? "captions.bubble" : "captions.bubble.fill")
                        .resizable()
                        .tint(.white)
                        .frame(width: 24, height: 22)
                        .padding(.top, 15)
                }
            }
    }
}

extension AVVideoPlayer {
    
    private func setUpSubtitles() async {
        guard 
            let vttUrl = URL(string: videoPayload.vttUrl),
            let player
        else {
            return
        }
        
        player.addPeriodicTimeObserver(
            forInterval: vttInterval,
            queue: DispatchQueue.global(qos: .background),
            using: { self.updateSubtitle($0) }
        )
        
        do {
            let (data, _) = try await URLSession.shared.data(from: vttUrl)
            let vttContent = String(decoding: data, as: UTF8.self)
            let parser = VTTParser(vttContent: vttContent)
            
            vtt = parser.parseWebVTT()
        } catch {
            print(error)
        }
    }
    
    private func updateSubtitle(_ time: CMTime) {
        let dictionary = vtt.first { (key, _) in
            key.contains(time.seconds)
        }
        
        subtitle = dictionary?.value ?? ""
    }
}

#Preview {
    AVVideoPlayer(videoPayload: .mock)
}
