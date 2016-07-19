//
//  ViewController.swift
//  Sample
//
//  Copyright © 2016 D.A.Consortium Inc. All rights reserved.
//

import UIKit
import DACSDKNativeAd

class ViewController: UIViewController, DACSDKNativeAdDelegate, UIGestureRecognizerDelegate {

    var loader: DACSDKNativeAdLoader? = nil

    let placementId = 30517
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareNativeAdLoader()
    }
    
// 広告を表示するためのAdLoaderを呼び出します。
    private func prepareNativeAdLoader() {
        self.loader = DACSDKNativeAdLoader(
            placementId: self.placementId,
            rootViewController: self)
        
        self.loader?.delegate = self
        self.loader?.loadRequest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
/* 広告のロードが成功したら呼ばれます。
   ネイティブ広告のViewを作成し、その中で取得したタイトル、文章、画像、広告主名をViewに格納し、表示します。 */
    func dacSdkNativeAdLoader(adloader: DACSDKNativeAdLoader, didReceiveNativeAd nativeContentAd: DACSDKNativeContentAd) {
        
        let contentAdView = DACSDKNativeAdView(frame: CGRectMake(50, 50, 300, 200))
        self.view.addSubview(contentAdView)
        contentAdView.backgroundColor = UIColor.yellowColor()
        contentAdView.nativeContentAd = nativeContentAd
        
        let titleView = UILabel(frame: CGRectMake(0, 0, 300, 50))
        contentAdView.addSubview(titleView)
        
        let bodyView = UILabel(frame: CGRectMake(150, 50, 150, 100))
        bodyView.numberOfLines = 0
        bodyView.font = UIFont.systemFontOfSize(15.0)
        contentAdView.addSubview(bodyView)
        
        let advertiserView = UILabel(frame: CGRectMake(150, 150, 150, 30))
        contentAdView.addSubview(advertiserView)
        
        let imageView = UIImageView(frame: CGRectMake(0, 50, 150, 100))
        contentAdView.addSubview(imageView)
        
        titleView.text = nativeContentAd.title
        bodyView.text = nativeContentAd.desc
        advertiserView.text = nativeContentAd.advertiser
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let
                imageUrl = NSURL(string: nativeContentAd.imageUrl ?? ""),
                data = NSData(contentsOfURL: imageUrl),
                image = UIImage(data: data) {
                dispatch_async(dispatch_get_main_queue()) {
                    imageView.image = image
                }
            }
        }
    }
    
// 広告のロードが失敗した場合に呼ばれます。
    func dacSdkNativeAdLoader(adloader: DACSDKNativeAdLoader, didFailAdWithError error: DACSDKNativeAdError) {
        print(error)
    }
}
