//
//  ViewController.swift
//  DACSDKMA-SampleBasicPlayer-Swift
//
//  Copyright © 2015 D.A.Consortium Inc. All rights reserved.
//

import UIKit
import DACSDKMA

// --------------------------------------------------
// MARK: - 1stView サンプル
// --------------------------------------------------
class ViewController: UIViewController, DACSDKMASmartVisionAdPlayerDelegate {
    
    // リクエスト先アドタグURL
    let adTagUri: String = "http://xp1.zedo.com/jsc/xp2/fns.vast?n=2696&c=47/11&d=17&s=2&v=vast2&pu=__page-url__&ru=__referrer__&pw=__player-width__&ph=__player-height__&z=__random-number__"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1stViewのインスタンスを生成する。
        let dacSDKMABasicVideoPlayer: DACSDKMASmartVisionAdPlayer = DACSDKMASmartVisionAdPlayer(frame: CGRectMake(10, 20, 320, 250))
        dacSDKMABasicVideoPlayer.delegate = self
        dacSDKMABasicVideoPlayer.load(self.adTagUri)
        self.view.addSubview(dacSDKMABasicVideoPlayer)
    }
    
    // SDKからイベントを受け取った
    @objc func dacSdkMaSmartVisionAdPlayer(smartVisionAdPlayer: DACSDKMASmartVisionAdPlayer, DidReceiveAdEvent adEvent: DACSDKMAAdEvent) {
        NSLog("event = \(adEvent.name)")
    }
    
    // SDKからエラーを受け取った
    @objc func dacSdkMaSmartVisionAdPlayer(smartVisionAdPlayer: DACSDKMASmartVisionAdPlayer, DidReceiveAdError adError: DACSDKMAAdError) {
        NSLog("error = \(adError.message)")
    }
}
