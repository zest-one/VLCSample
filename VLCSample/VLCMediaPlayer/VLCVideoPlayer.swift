import SwiftUI
import MobileVLCKit

/*
Closed captioning
Closed captioning, or CC, is a feature that appears in some videos on YouTube. They describe what's happening in a video so users can understand the content. It can be helpful for users who have trouble hearing or who prefer to read the text instead of listening to it.*/

struct VLCVideoPlayer: View {
    enum SubtitlesOptions: String, Equatable, CaseIterable {
        case cc = "CC"
        case off = "Off"
        case auto = "Auto (Recommended)"
        
        var enforceSubtitles: Bool {
            return self == .auto
        }
    }
    
    enum PlaybackOption: String, Equatable, CaseIterable {
        case twoX = "2,0x"
        case oneFiftyX = "1,5x"
        case oneTwentyFiveX = "1,25x"
        case oneX = "1,0x"
        case zeroFiveX = "0,5x"
    }
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var playerWrapper: VLCPlayerWrapper
    @State private var subtitlesOption: SubtitlesOptions = .auto
    @State private var playbackOption: PlaybackOption = .oneX
    @State private var isShowingPopover = false
    @State private var isShowingControls = false
    @State private var showControlsTask: Task<Void, Never> = Task { }
    private let showingControlsDuration: UInt64 = 1000_000_000
    
    init(videoPayload: VideoPayload) {
        playerWrapper = .init(videoPayload: videoPayload)
    }
    
    var body: some View {
        
        ZStack {
            
            VLCMediaPlayerView(playerWrapper: playerWrapper)
                .overlay(alignment: .center) {
                    if playerWrapper.error {
                        Text("Errore di riproduzione")
                            .foregroundColor(.white)
                            .font(.title2)
                            .task {
                                try? await Task.sleep(nanoseconds: 15_000_000)
                                dismiss()
                            }
                    } else if isShowingControls {
                        if !playerWrapper.isPlaying && !playerWrapper.onPreRoll {
                            Button {
                                playerWrapper.play()
                                isShowingControls.toggle()
                            } label: {
                                Image(systemName: "play.fill")
                                    .font(.largeTitle)
                            }
                            .padding()
                        } else {
                            Button {
                                playerWrapper.pause()
                                showControlsTask.cancel()
                                isShowingControls = true
                            } label: {
                                Image(systemName: "pause.fill")
                                    .font(.largeTitle)
                            }
                            .padding()
                        }
                    }
                }
            
            VStack {
                HStack(spacing: 20) {
                    Button {
                        playerWrapper.stop()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                    }
                    .padding(.leading, 40)
                    
                    Button {
                        print("AirPlay Video")
                    } label: {
                        Image(systemName: "airplayvideo")
                            .font(.title2)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button {
                        if playerWrapper.isMuted {
                            playerWrapper.loud()
                        } else {
                            playerWrapper.mute()
                        }
                    } label: {
                        Image(
                            systemName: playerWrapper.isMuted ? "speaker.fill" : "speaker.slash.fill"
                        )
                        .font(.title2)
                    }
                    .padding(.trailing, 40)
                }
                
                Spacer()
                
                ProgressView(value: playerWrapper.progress) {
                    HStack {
                        Spacer()
                        
                        Menu {
                            Picker(selection: $subtitlesOption) {
                                ForEach(SubtitlesOptions.allCases, id: \.self) {
                                    Text($0.rawValue)
                                        .tag($0)
                                }
                            } label: {
                                Label("Subtitles", systemImage: "captions.bubble")
                                .font(.headline)
                            }
                            
                            Picker(selection: $playbackOption) {
                                ForEach(PlaybackOption.allCases, id: \.self) {
                                    Text($0.rawValue)
                                        .tag($0)
                                }
                            } label: {
                                Label("Playback Speed", systemImage: "gauge.with.dots.needle.67percent")
                                .font(.headline)
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.title3)
                        }
                        .pickerStyle(.menu)
                        .padding(.bottom, 10)
                    }
                } currentValueLabel: {
                    HStack {
                        Text(playerWrapper.time.stringValue)
                        
                        Spacer()
                        
                        Text(playerWrapper.length.stringValue)
                    }
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                }
                .progressViewStyle(.linear)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .opacity(isShowingControls ? 1.0 : 0.0)
        }
        .tint(.white)
        .task {
            try? await Task.sleep(nanoseconds: 5_000_000)
            playerWrapper.requestAds()
        }
        .onValueChange(of: subtitlesOption) { _, newValue in
            print("Change Subtitles Injection")
            playerWrapper.enableSubtitles(newValue.enforceSubtitles)
        }
        .onTapGesture {
            if isShowingControls { return }
            if playerWrapper.onPreRoll { return }
            isShowingControls.toggle()
            showControlsTask.cancel()
            showControlsTask = Task {
                do {
                    try await Task.sleep(nanoseconds: showingControlsDuration)
                    withAnimation(.easeInOut(duration: 1.0)) {
                        isShowingControls.toggle()
                    }
                } catch {
                    print(error)
                }
            }
        }
        .background {
            Color.black.ignoresSafeArea()
        }
    }
}

#Preview {
    VLCVideoPlayer(videoPayload: .sky)
}
