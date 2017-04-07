//
//  ViewController.swift
//  Sample
//
//  Copyright © 2016 dac. All rights reserved.
//

import UIKit
import DACSDKNativeAd

class ViewController: UIViewController, DACSDKNativeAdDelegate, UIGestureRecognizerDelegate {
    
    var loader: DACSDKNativeAdLoader? = nil
    
    // placeIDを設定します。
    let placementId = 32738
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareNativeAdLoader()
    }
    
    /// 広告を表示するためのAdLoaderを呼び出します。
    fileprivate func prepareNativeAdLoader() {
        self.loader = DACSDKNativeAdLoader(
            placementId: self.placementId)
        
        self.loader?.delegate = self
        self.loader?.loadRequest()
    }
    
    /// 広告のロードが成功したら呼ばれます。
    /// ネイティブ広告のViewを作成し、その中で取得したタイトル、文章、画像、広告主名をViewに格納し、表示します。
    func dacSdkNativeAdLoader(_ adloader: DACSDKNativeAdLoader, didReceiveNativeAd nativeContentAd: DACSDKNativeContentAd) {
        
        let contentAdView = DACSDKNativeAdView(frame: CGRect(x: 50, y: 50, width: 300, height: 200))
        self.view.addSubview(contentAdView)
        contentAdView.backgroundColor = UIColor.yellow
        contentAdView.nativeContentAd = nativeContentAd
        
        let titleView = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
        contentAdView.addSubview(titleView)
        
        let bodyView = UILabel(frame: CGRect(x: 150, y: 50, width: 150, height: 100))
        bodyView.numberOfLines = 0
        bodyView.font = UIFont.systemFont(ofSize: 15.0)
        contentAdView.addSubview(bodyView)
        
        let advertiserView = UILabel(frame: CGRect(x: 150, y: 150, width: 150, height: 30))
        contentAdView.addSubview(advertiserView)
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 50, width: 150, height: 100))
        contentAdView.addSubview(imageView)
        
        titleView.text = nativeContentAd.title
        bodyView.text = nativeContentAd.desc
        advertiserView.text = nativeContentAd.advertiser
        
        DispatchQueue.global().async {
            if let imageUrl: URL = URL(string: nativeContentAd.imageUrl ?? ""),
                let data: Data = try? Data(contentsOf: imageUrl),
                let image: UIImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }
        }
    }
    
    /// 広告のロードが失敗した場合に呼ばれます。
    func dacSdkNativeAdLoader(_ adloader: DACSDKNativeAdLoader, didFailAdWithError error: NSError) {
        print(error)
    }
}
