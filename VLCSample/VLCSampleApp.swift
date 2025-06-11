import SwiftUI

@main
struct VLCSampleApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                showVLCButton: true,
                showAVPlayerButton: true,
                edge: 150
            )
        }
    }
}
