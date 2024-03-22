import UIKit
import AVKit

class VideoViewController: AVPlayerViewController {

    let coordinator: AVPlayerView.Coordinator
    
    init(coordinator: AVPlayerView.Coordinator) {
        self.coordinator = coordinator
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        player = coordinator.getPlayer()
        view.subviews.forEach {
            $0.removePanGestureRecognizers()
        }
        
        updatesNowPlayingInfoCenter = false
        allowsPictureInPicturePlayback = false
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        if let player {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(contentDidFinishPlaying(_:)),
                name: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem
            )
        }
        
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
        if let player {
            NotificationCenter.default.removeObserver(
                self,
                name: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem
            )
        }
        
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
        
        coordinator.dismiss()
    }
    
    @objc 
    func contentDidFinishPlaying(_ notification: Notification) {
        coordinator.contentDidFinishPlaying()
    }
    
    @objc
    func didBecomeActive() {
        coordinator.didBecomeActive()
    }
    
    @objc
    func didEnterBackground() {
        coordinator.didEnterBackground()
    }
}
