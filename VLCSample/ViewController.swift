//
//  ViewController.swift
//  VLCSample
//
//  Created by George on 30.09.2020.
//

/*import UIKit
import MobileVLCKit

class ViewController: UIViewController {
    
    @IBOutlet weak var vlcView: UIView!
    
    let videoPlayer = VLCMediaPlayer()
    let videoUrl = "https://acdn.ak-stream-videoplatform.sky.it/hls/2024/03/11/907941/master.m3u8"
    let vttUrl = "https://videoplatform.sky.it/caption/2024/03/11/907941.vtt"
    var enforceSubtitles = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startStream()
        // Do any additional setup after loading the view.
    }

    func startStream(){
        guard let url = URL(string: videoUrl) else {
            return
        }
        
        videoPlayer.drawable = vlcView
        videoPlayer.media = VLCMedia(url: url)
        
        videoPlayer.media.addOption( "-vv")
        videoPlayer.media.addOption( "--network-caching=10000")
        if let vtt = URL(string: vttUrl) {
            videoPlayer
                .addPlaybackSlave(
                    vtt,
                    type: .subtitle,
                    enforce: enforceSubtitles
                )
        }
        videoPlayer.delegate = self
        
        videoPlayer.play()
    }
    
    @IBAction func volumeControlAction(_ sender: UISlider) {
        videoPlayer.audio.volume = Int32(sender.value)
    }
}

extension ViewController: VLCMediaPlayerDelegate{
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        guard let videoPlayer = aNotification.object as? VLCMediaPlayer else {return}
        switch videoPlayer.state{
        case .playing:
            print("VLCMediaPlayerDelegate: PLAYING")
        case .opening:
            print("VLCMediaPlayerDelegate: OPENING")
        case .error:
            print("VLCMediaPlayerDelegate: ERROR")
        case .buffering:
            print("VLCMediaPlayerDelegate: BUFFERING")
        case .stopped:
            print("VLCMediaPlayerDelegate: STOPPED")
        case .paused:
            print("VLCMediaPlayerDelegate: PAUSED")
        case .ended:
            print("VLCMediaPlayerDelegate: ENDED")
        case .esAdded:
            print("VLCMediaPlayerDelegate: ELEMENTARY STREAM ADDED")
        default:
            break
        }
    }
}
*/
