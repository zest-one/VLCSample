//
//  VideoPayload.swift
//  VLCSample
//
//  Created by Alessandro Oliva on 21/03/24.
//

import Foundation

struct VideoPayload {
    let videoUrl: String
    let vttUrl: String
}

extension VideoPayload {
    static let mock: VideoPayload = .init(
        videoUrl: "https://acdn.ak-stream-videoplatform.sky.it/hls/2024/03/11/907941/master.m3u8",
        vttUrl: "https://videoplatform.sky.it/caption/2024/03/11/907941.vtt"
    )
}
