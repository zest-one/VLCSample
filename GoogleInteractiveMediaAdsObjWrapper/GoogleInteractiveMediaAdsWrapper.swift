import UIKit
@_implementationOnly import GoogleInteractiveMediaAds

@objc
public class GoogleInteractiveMediaAdsWrapper: NSObject {
    
    class AdsManager: NSObject, IMAAdsManagerDelegate {
        var adsManager: IMAAdsManager?
        let delegate: AdsManagerDelegate
        
        init(adsManager: IMAAdsManager? = nil, delegate: AdsManagerDelegate) {
            self.adsManager = adsManager
            self.delegate = delegate
        }
        
        ///Called when there is an IMAAdEvent.
        func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
            switch event.type {
            case .LOADED:
                adsManager.start()
            case .CLICKED:
                adsManager.resume()
            default: 
                break
            }
        }
        
        ///Called when there was an error playing the ad. Log the error and resume playing content.
        func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
            print("Error loading ads: \(error.message ?? "")")
            delegate.adsManagerDidReceiveError(error.message)
        }
        
        ///Called when an ad has finished or an error occurred during the playback. The implementing code should resume the content playback
        func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
            delegate.adsManagerDidRequestContentPause()
        }
        
        ///Called when an ad is ready to play. The implementing code should pause the content playback and prepare the UI for ad playback.
        func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
            delegate.adsManagerDidRequestContentResume()
        }
    }
    
    class LoaderDelegate: NSObject, IMAAdsLoaderDelegate {
        let managerDelegate: AdsManager
        
        init(adsManagerDelegate: AdsManagerDelegate) {
            managerDelegate = .init(delegate: adsManagerDelegate)
        }
        
        @objc
        public func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
            let adsManager = adsLoadedData.adsManager
            adsManager?.delegate = managerDelegate
            let adsRenderingSettings = IMAAdsRenderingSettings()
            adsRenderingSettings.linkOpenerPresentingController = nil
            adsManager?.initialize(with: adsRenderingSettings)
            
            managerDelegate.adsManager = adsManager
        }
        
        @objc
        public func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
            print("Error loading ads: \(adErrorData.adError.message ?? "")")
            managerDelegate.delegate.adsManagerDidReceiveError(adErrorData.adError.message)
        }
    }
    
    private let loaderDelegate: LoaderDelegate
    private let adsLoader: IMAAdsLoader
    
    public init(adsManagerDelegate: AdsManagerDelegate) {
        print("GoogleInteractiveMediaAdsWrapper initialised")
        
        let delegate = LoaderDelegate(adsManagerDelegate: adsManagerDelegate)
        loaderDelegate = delegate
        adsLoader = .init(settings: nil)
        adsLoader.delegate = delegate
        
        super.init()
    }
    
    @objc
    public func requestAds(
        adTagUrl: String,
        adContainer: UIView,
        viewController: UIViewController,
        player: Any?,
        userContext: Any? = nil
    ) {
        let request = IMAAdsRequest(
            adTagUrl: adTagUrl,
            adDisplayContainer: IMAAdDisplayContainer(
                adContainer: adContainer,
                viewController: viewController,
                companionSlots: nil
            ),
            contentPlayhead: player as? (IMAContentPlayhead & NSObjectProtocol),
            userContext: nil
        )
        
        adsLoader.requestAds(with: request)
    }
    
    @objc
    public func contentComplete() {
        adsLoader.contentComplete()
    }
}

@objc
public protocol AdsManagerDelegate {
    
    func adsManagerDidReceiveError(_ message: String?)
    
    func adsManagerDidRequestContentPause()
    
    func adsManagerDidRequestContentResume()
}
