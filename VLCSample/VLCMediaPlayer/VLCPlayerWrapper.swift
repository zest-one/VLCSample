import SwiftUI
import MobileVLCKit
import GoogleInteractiveMediaAdsObjWrapper

///A wrapper to use MobileVLCKit media player to play and stop videos

class VLCPlayerWrapper: NSObject, ObservableObject {
    
    let player: VLCMediaPlayer
    let videoUrl: String
    let vttUrl: String
    
    @Environment(\.dismiss) var dismiss
    @Published var isPlaying = false
    @Published var onPreRoll = false
    @Published var error = false
    @Published var progress: Double = 1 / 120
    @Published var time: VLCTime = .init(int: 1_000)
    @Published var length: VLCTime = .init(int: 120_000)
    @Published var vlcAudio: VLCAudio?
    @Published var isMuted: Bool
    private var videoSubTitlesIndex: Int32 = 0
    private let advConfig = AdvertisingConfiguration.adsDisabled
    private var viewController: UIViewController?
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
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
    func play() {
        player.play()
        onPreRoll = false
        isPlaying = true
        
        // payload.map(Tracker.startVideoContent)
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
        
         dismiss()
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
    
    func viewControllerDidUpdate(_ controller: UIViewController) {
        guard viewController == nil else {
            return
        }
        
        viewController = controller
        player.drawable = controller.view
    }
    
    func requestAds() {
        guard let viewController else {
            print("ViewController is nil")
            return
        }
        
        guard let url = advConfig.url else {
            play()
            return
        }
        
        onPreRoll.toggle()
        googleInteractiveMediaAdsWrapper.requestAds(
            adTagUrl: url.absoluteString,
            viewController: viewController,
            player: player
        )
    }
    
    @objc
    func didBecomeActive() {
        googleInteractiveMediaAdsWrapper.resumeAd()
    }
    
    @objc
    func didEnterBackground() {
        pause()
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
        
    }
}

extension VLCPlayerWrapper: AdsManagerDelegate {
    
    func adsManagerDidReceiveError(_ message: String?) {
        play()
    }
    
    func adsManagerDidRequestContentPause() {
        pause()
    }
    
    func adsManagerDidRequestContentResume() {
        play()
    }
}

// MARK: - VLCMediaPlayer | Conformance to IMAContentPlayhead

extension VLCMediaPlayer {
    ///This is required in order to support GoogleInteractiveMediaAds
    public var currentTime: TimeInterval {
        return time.value?.doubleValue ?? 0.0
    }
}
