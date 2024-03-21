import SwiftUI
import MobileVLCKit
import GoogleInteractiveMediaAdsObjWrapper

///A wrapper to use MobileVLCKit media player to play and stop videos

class VLCPlayerWrapper: NSObject, ObservableObject {
    
    struct AdvertisingConfiguration {
        let queryItems = [
            "unviewed_position_start": "1",
            "output": "vast",
            "env": "vp",
            "gdfp_req": "1",
            "impl": "s",
            "sz": "640x480",
            "iu": "/316816995,22629227020/sky.it/test",
            "description_url": "http://xfactor.sky.it/",
            "correlator": String(describing: Date().timeIntervalSince1970)
        ]
        
        let advUrl = "https://pubads.g.doubleclick.net/gampad/ads"
    }
    
    let player: VLCMediaPlayer
    let videoUrl: String
    let vttUrl: String
    var viewController: UIViewController?
    
    @Published var isPlaying = false
    @Published var onPreRoll = false
    @Published var error = false
    @Published var progress: Double = 1 / 120
    @Published var time: VLCTime = .init(int: 1_000)
    @Published var length: VLCTime = .init(int: 120_000)
    @Published var vlcAudio: VLCAudio?
    @Published var isMuted: Bool
    private var videoSubTitlesIndex: Int32 = 0
    private let advConfig = AdvertisingConfiguration()
    private lazy var googleInteractiveMediaAdsWrapper: GoogleInteractiveMediaAdsWrapper = {
        .init(adsManagerDelegate: self)
    }()
    
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
        
        guard let url = URL(string: videoUrl) else { return }
        
        let media = VLCMedia(url: url)
        length = media.length
        progress = 0.0
        player.media = media
        addPlaybackSubtitles(true)
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
    
    private func playMedia() {
        player.play()
        onPreRoll = false
        isPlaying = true
        
        // payload.map(Tracker.startVideoContent)
    }
    
    ///Method to begin playing the specified URL
    func play() {
        if player.currentTime.isZero {
            requestAds()
            return
        }
        
        playMedia()
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
        player.rate = 0
        let seconds = Int(round(player.currentTime.rounded()))
        print("Will Track Stop Video Content at: \(seconds)")
        /*Tracker.stopVideoContent(videoName: payload.title,
         elapsedSeconds: seconds,
         videoLengthInSeconds: payload.durationInSeconds.intValue)*/
        if isPlaying {
            player.stop()
            isPlaying = false
        }
        
        // dismiss here?
    }
    
    func pause() {
        player.pause()
        isPlaying = false
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
    
    private func mediaDidFinishPlaying() {
        googleInteractiveMediaAdsWrapper.contentComplete()
        stop()
    }
    
    private func requestAds() {
        guard let viewController, var urlComponents = URLComponents(string: advConfig.advUrl) else {
            player.play()
            return
        }
        
        urlComponents.queryItems = advConfig.queryItems.map { URLQueryItem(name: $0, value: $1) }
        
        guard let url = urlComponents.url else {
            player.play()
            return
        }
        
        onPreRoll.toggle()
        googleInteractiveMediaAdsWrapper.requestAds(
            adTagUrl: url.absoluteString,
            adContainer: viewController.view,
            viewController: viewController,
            player: player
        )
    }
}

extension VLCPlayerWrapper: VLCMediaPlayerDelegate {
    ///Implementation for VLCMediaPlayerDelegate to handle media player state change
    func mediaPlayerStateChanged(_ aNotification: Notification) {
        videoSubTitlesIndex = player.currentVideoSubTitleIndex
        switch player.state {
        case .error:
            error = true
        case .ended:
            mediaDidFinishPlaying()
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

extension VLCPlayerWrapper: AdsManagerDelegate {
    
    func adsManagerDidReceiveError(_ message: String?) {
        playMedia()
    }
    
    func adsManagerDidRequestContentPause() {
        pause()
    }
    
    func adsManagerDidRequestContentResume() {
        playMedia()
    }
}

// MARK: - VLCMediaPlayer | Conformance to IMAContentPlayhead

extension VLCMediaPlayer {
    ///This is required in order to support GoogleInteractiveMediaAds
    public var currentTime: TimeInterval {
        return time.value?.doubleValue ?? 0.0
    }
}
