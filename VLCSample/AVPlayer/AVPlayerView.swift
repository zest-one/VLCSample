import SwiftUI
import AVKit
import GoogleInteractiveMediaAdsObjWrapper

struct AVPlayerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    let player: AVPlayer?
    let videoPayload: VideoPayload
    
    func play() {
        player?.play()
        
        // TODO: Tracking
        /*payload.map(Tracker.startVideoContent)*/
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        guard let player else {
            dismiss()
            
            return
        }
        
        player.rate = 0
        let seconds = Int(round(player.currentTime().seconds))
        print("Will Track Stop Video Content at: \(seconds)")
        
        // TODO: Tracking
        /*
         Tracker.stopVideoContent(videoName: payload.title,
         elapsedSeconds: seconds,
         videoLengthInSeconds: payload.durationInSeconds.intValue)
         */
        
        dismiss()
    }
    
    class Coordinator: NSObject {
        
        private let advConfig: AdvertisingConfiguration
        private let parent: AVPlayerView
        private lazy var googleInteractiveMediaAdsWrapper: GoogleInteractiveMediaAdsWrapper = {
            .init(adsManagerDelegate: self)
        }()
        var didRequestAds: Bool
        
        init(_ parent: AVPlayerView) {
            advConfig = .test
            self.parent = parent
            didRequestAds = false
            
            super.init()
        }
        
        func getPlayer() -> AVPlayer? {
            return parent.player
        }
        
        func dismiss() {
            parent.dismiss()
        }
        
        func requestAds(_ player: AVPlayer, viewController: UIViewController) {
            guard let adTagUrl = advConfig.url else {
                parent.play()
                return
            }
            
            googleInteractiveMediaAdsWrapper.requestAVPlayerAds(
                adTagUrl: adTagUrl.absoluteString,
                viewController: viewController,
                player: player
            )
        }
        
        func contentDidFinishPlaying() {
            googleInteractiveMediaAdsWrapper.contentComplete()
            parent.stop()
        }
        
        func didBecomeActive() {
            googleInteractiveMediaAdsWrapper.resumeAd()
        }
        
        func didEnterBackground() {
            parent.pause()
        }
    }
    
    func makeUIViewController(context: Context) -> some VideoViewController {
        return .init(coordinator: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if context.coordinator.didRequestAds { return }
        guard let player = uiViewController.player else {
            return
        }
        
        context.coordinator.didRequestAds.toggle()
        
        Task {
            do {
                try await Task.sleep(nanoseconds: 5_000_000)
                context.coordinator.requestAds(
                    player,
                    viewController: uiViewController
                )
            } catch {
                player.play()
                print(error)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

extension AVPlayerView.Coordinator: AdsManagerDelegate {
    
    func adsManagerDidReceiveError(_ message: String?) {
        parent.play()
    }
    
    func adsManagerDidRequestContentPause() {
        parent.pause()
    }
    
    func adsManagerDidRequestContentResume() {
        parent.play()
    }
}
