import SwiftUI

///A wrapper which allows the MobileVLCKit to be used with SwiftUI

struct VLCMediaPlayerView: UIViewControllerRepresentable {
    @ObservedObject var playerWrapper: VLCPlayerWrapper
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.subviews.forEach {
            $0.removePanGestureRecognizers()
        }
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        playerWrapper.viewControllerDidUpdate(uiViewController)
    }
}
