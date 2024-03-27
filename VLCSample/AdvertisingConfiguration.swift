import Foundation

struct AdvertisingConfiguration {    
    
    static let sky: AdvertisingConfiguration = .init(
        queryItems: skyQueryItems,
        baseUrl: baseUrl
    )
    
    static let test: AdvertisingConfiguration = .init(urlString: testUrl)
    static let adsDisabled: AdvertisingConfiguration = .init()
    
    static let skyQueryItems =  [
        "unviewed_position_start": "1",
        "output": "vast",
        "env": "vp",
        "gdfp_req": "1",
        "impl": "s",
        "sz": "640x480",
        "iu": "/316816995,22629227020/sky.it/test",
        "description_url": "http://xfactor.sky.it/",
        "correlator": String(describing: Date().timeIntervalSince1970)
    ]
    
    static let testUrl = "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_ad_samples&sz=640x480&cust_params=sample_ct%3Dlinear&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator="
    
    static let baseUrl: String = "https://pubads.g.doubleclick.net/gampad/ads"
    
    let url: URL?
    
    private init(queryItems: [String : String], baseUrl: String) {
        var urlComponents = URLComponents(string: baseUrl)
        urlComponents?.queryItems = queryItems.map { URLQueryItem(name: $0, value: $1) }
        
        url = urlComponents?.url
    }
    
    private init(urlString: String) {
        url = URL(string: urlString)
    }
    
    private init() {
        url = nil
    }
}
