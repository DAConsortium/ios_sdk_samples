//
//  ViewController.swift
//  DACSDKMA-SampleSVAPlayer-Swift
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
    let adTagUri: String = "https://saxp.zedo.com/jsc/xp2/fns.vast?n=2696&c=26/11&d=17&s=2&v=vast2&pu=__page-url__&ru=__referrer__&pw=__player-width__&ph=__player-height__&z=__random-number__"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1stViewのインスタンスを生成する。
        let dacSDKMABasicVideoPlayer: DACSDKMASmartVisionAdPlayer = DACSDKMASmartVisionAdPlayer(frame: CGRect(x: 10, y: 20, width: 320, height: 250))
        dacSDKMABasicVideoPlayer.delegate = self
        dacSDKMABasicVideoPlayer.load(self.adTagUri)
        self.view.addSubview(dacSDKMABasicVideoPlayer)
    }
    
    // SDKからイベントを受け取った
    @objc func dacsdkmaSmartVisionAdPlayer(_ smartVisionAdPlayer: DACSDKMASmartVisionAdPlayer, didReceiveAdEvent adEvent: DACSDKMAAdEvent) {
        NSLog("event = \(adEvent.name)")
    }
    
    // SDKからエラーを受け取った
    @objc func dacsdkmaSmartVisionAdPlayer(_ smartVisionAdPlayer: DACSDKMASmartVisionAdPlayer, didReceiveAdError adError: DACSDKMAAdError) {
        NSLog("error = \(adError.message)")
    }
}
