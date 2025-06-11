import Foundation
import AVFoundation

struct PlayerAsset: Identifiable {
    let playerItem: AVPlayerItem
    let id: UUID = .init()
}

enum PlayerAssetError: Error {
    case emptyTracks
}

actor AVPlayerAssetGenerator {
    
    private func downloadVTT(from url: URL) async throws -> URL {
        let (tempLocalUrl, _) = try await URLSession.shared.download(from: url)
        
        let fileName = url.lastPathComponent
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        // Remove existing file if needed
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        
        try FileManager.default.moveItem(at: tempLocalUrl, to: destinationURL)
        
        return destinationURL
    }
    
    private func makeComposition(
        videoURL: URL,
        vttURL: URL,
        addSubtitles: Bool
    ) async throws -> AVMutableComposition? {
        let videoAsset = AVURLAsset(url: videoURL)
        let subtitleAsset = AVURLAsset(url: vttURL)
        let duration = try await videoAsset.load(.duration)
        print("Duration: \(duration)")
        
        // Load tracks asynchronously
        let videoTracks = try await videoAsset.load(.tracks)
        let subtitleTracks = try await subtitleAsset.load(.tracks)
        
        let composition = AVMutableComposition()
        
        defer {
            print("VideoTracks: \(videoTracks) SubtitlesTracks: \(subtitleTracks) Tracks: \(composition.tracks)")
        }
        
        // Add video + audio tracks from video asset
        for track in videoTracks {
            let compTrack = composition.addMutableTrack(
                withMediaType: track.mediaType,
                preferredTrackID: kCMPersistentTrackID_Invalid
            )
            
            try compTrack?.insertTimeRange(
                CMTimeRange(start: .zero, duration: duration),
                of: track,
                at: .zero
            )
        }

        // Add subtitle track (usually `mediaType == .text` or `.subtitle`)
        guard addSubtitles, let subtitleTrack = subtitleTracks.first(where: {
            $0.mediaType == .text || $0.mediaType == .subtitle || $0.mediaType == .closedCaption
        }) else {
            print("No compatible subtitle track found in VTT asset")
            return composition.tracks.isEmpty ? nil : composition // Return just video/audio if no subtitles
        }
        
        let subtitlesDuration = try await subtitleAsset.load(.duration)
        print("Subtitles Duration: \(subtitlesDuration)")
        
        let subtitleCompTrack = composition.addMutableTrack(
            withMediaType: subtitleTrack.mediaType,
            preferredTrackID: kCMPersistentTrackID_Invalid
        )

        try subtitleCompTrack?.insertTimeRange(
            CMTimeRange(start: .zero, duration: subtitlesDuration),
            of: subtitleTrack,
            at: .zero
        )
        
        return composition.tracks.isEmpty ? nil : composition
    }
    
    func bundledVTTURL(from absoluteString: String) async throws -> URL {
        guard let url = URL(string: absoluteString) else {
            throw NSError(domain: "Cannot get URL from \(absoluteString)", code: 2, userInfo: nil)
        }
        
        return try await downloadVTT(from: url)
    }

    func getAVPlayerAsset(
        videoUrl: URL,
        vttUrl: URL,
        addSubtitles: Bool = true
    ) async throws -> AVPlayerItem {
        guard let asset = try await makeComposition(
            videoURL: videoUrl,
            vttURL: vttUrl,
            addSubtitles: addSubtitles
        ) else {
            throw PlayerAssetError.emptyTracks
        }
        
        let playerItem = await AVPlayerItem(asset: asset)
        
        return playerItem
    }
}
