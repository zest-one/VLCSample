import Foundation

struct VideoPayload {
    let videoUrl: String
    let vttUrl: String
}

extension VideoPayload {
    static let mock1: VideoPayload = .init(
        videoUrl: "https://acdn.ak-stream-videoplatform.sky.it/hls/2024/03/11/907941/master.m3u8",
        vttUrl: "https://videoplatform.sky.it/caption/2024/03/11/907941.vtt"
    )
    
    static let mock: VideoPayload = .init(
        videoUrl: "https://stream.mux.com/HDGj01zK01esWsWf9WJj5t5yuXQZJFF6bo.m3u8",
        vttUrl: ""
    )
    
    static let sky: VideoPayload = .init(
        videoUrl: "https://videoplatform.sky.it/encoded/2024/12/06/971976/971976_240p.mp4",
        vttUrl: "https://videoplatform.sky.it/spritesheet/2024/12/06/971976/971976.vtt"
    )
}

struct VideoData: Identifiable {
    var id: String {
        return videoUrl.absoluteString
    }
    
    let videoUrl: URL
}
