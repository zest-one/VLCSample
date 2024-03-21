import SwiftUI
import MobileVLCKit

///A wrapper to use MobileVLCKit media player to play and stop videos

class VLCPlayerWrapper: NSObject, ObservableObject {
    
    enum Loudness {
        case volume(Int32)
        case mute
    }
    
    let player: VLCMediaPlayer
    let videoUrl: String
    let vttUrl: String
    
    @Published var isPlaying = false
    @Published var error = false
    @Published var progress: Double = 1 / 120
    @Published var time: VLCTime = .init(int: 1_000)
    @Published var length: VLCTime = .init(int: 120_000)
    @Published var vlcAudio: VLCAudio?
    @Published var isMuted: Bool
    private var videoSubTitlesIndex: Int32 = 0
    
    init(videoPayload: VideoPayload) {
        player = VLCMediaPlayer(
            options: [
                "-vv",
                "--network-caching=10000"
            ]
        )
        videoUrl = videoPayload.videoUrl
        vttUrl = videoPayload.vttUrl
        vlcAudio = player.audio
        isMuted = player.audio?.isMuted ?? true
        
        super.init()
        
        player.delegate = self
    }
    
    ///Method to add subtitles from vtt URL
    private func addPlaybackSubtitles(_ enforceSubtitles: Bool) {
        if let vtt = URL(string: vttUrl) {
            player
                .addPlaybackSlave(
                    vtt,
                    type: .subtitle,
                    enforce: enforceSubtitles
                )
        }
    }
    
    ///Method to begin playing the specified URL
    func play(enforceSubtitles: Bool) {
        guard let url = URL(string: videoUrl) else { return }
        
        let media = VLCMedia(url: url)
        length = media.length
        progress = 0.0
        player.media = media
        addPlaybackSubtitles(enforceSubtitles)
        player.play()
        isPlaying = true
    }
    
    ///Method to enable / disable the subtitles
    func enableSubtitles(_ enabled: Bool) {
        guard enabled else {
            player.currentVideoSubTitleIndex = -1
            return
        }
        
        player.currentVideoSubTitleIndex = videoSubTitlesIndex
    }
    
    ///Method to stop playing the currently playing video
    func stop() {
        player.stop()
        isPlaying = false
    }
    
    func pause() {
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
    
    func mute() {
        guard let vlcAudio, !isMuted else {
            return
        }
        
        vlcAudio.isMuted.toggle()
        isMuted.toggle()
    }
    
    func loud() {
        guard let vlcAudio, isMuted else {
            return
        }
        
        vlcAudio.isMuted.toggle()
        isMuted.toggle()
    }
}

extension VLCPlayerWrapper: VLCMediaPlayerDelegate {
    ///Implementation for VLCMediaPlayerDelegate to handle media player state change
    func mediaPlayerStateChanged(_ aNotification: Notification) {
        videoSubTitlesIndex = player.currentVideoSubTitleIndex
        switch player.state {
        case .error:
            error = true
        default:
            error = false
        }
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification) {
        time = player.time
        progress = (time.value?.doubleValue ?? 0.0) / (length.value?.doubleValue ?? 1.0)
    }
    
    func mediaPlayerLoudnessChanged(_ aNotification: Notification) {
        print("^ Volume: \(player.audio?.volume ?? 0)")
    }
}

///A wrapper which allows the MobileVLCKit to be used with SwiftUI
struct VLCMediaPlayerView: UIViewRepresentable {
    typealias UIViewType = UIView
    
    @ObservedObject var playerWrapper: VLCPlayerWrapper
    
    ///Method to create the UIKit view that is to be represented in SwiftUI
    func makeUIView(context: Context) -> UIView {
        let playerView = UIView()
        return playerView
    }
    
    ///Method to update the UIKit view that is being used in SwiftUI
    func updateUIView(_ uiView: UIView, context: Context) {
        playerWrapper.player.drawable = uiView
    }
}
