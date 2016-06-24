//
//  ViewController.swift
//  DACSDKMA-SampleScrollView-Swift
//
//  Copyright © 2016 D.A.Consortium Inc. All rights reserved.
//

import UIKit
import DACSDKMA

class ViewController: UIViewController, DACSDKMAAdsLoaderDelegate, DACSDKMAAdsManagerDelegate {

    // リクエスト先アドタグURI
    let adTagUri = "https://saxp.zedo.com/asw/fnsr.vast?n=2696&c=25/11&d=17&s=2&v=vast2&pu=__page-url__&ru=__referrer__&pw=__player-width__&ph=__player-height__&z=__random-number__"

    var scrollView: UIScrollView!
    
    // 広告掲載するView
    var adView: UIView!
    
    // SDKで使用する変数を宣言する
    var dacSdkAdsMaSettings: DACSDKMASettings?   = nil
    var dacAdsLoader: DACSDKMAAdsLoader?  = nil
    var dacAdsManager: DACSDKMAAdsManager? = nil
    var dacAdController: DACSDKMAAdDefaultController? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.viewのサイズを取得する
        let selfViewCGRect:     CGRect  = self.view.bounds
        let selfViewWidth:      CGFloat = selfViewCGRect.width
        let selfViewHeight:     CGFloat = selfViewCGRect.height
        
        // scrollViewを設定する
        self.scrollView = UIScrollView(frame: CGRectMake(0, 0, selfViewWidth, selfViewHeight))
        self.scrollView.backgroundColor  = UIColor.blueColor()
        self.scrollView.contentSize      = CGSizeMake(selfViewWidth, selfViewHeight*3)
        
        // adViewを設定する
        self.adView = UIView(frame: CGRectMake(0, selfViewHeight-100, selfViewWidth, 300))
        self.adView.backgroundColor = UIColor.greenColor()
        self.scrollView.addSubview(adView)
        
        // self.viewにscrollViewをaddSubviewする
        self.view.addSubview(scrollView)
        
        self.requestAds()
    }
    
    // VAST広告をリクエストする
    func requestAds() {
        self.dacSdkAdsMaSettings = DACSDKMASettings()
        self.dacAdsLoader =  DACSDKMAAdsLoader(settings: self.dacSdkAdsMaSettings!)
        self.dacAdsLoader?.delegate = self
        
        //広告動画を掲載するViewとリクエスト先アドサーバのURLをリクエストにセットする
        let adContainer: DACSDKMAAdContainer = DACSDKMAAdContainer(view: self.adView!)
        let request: DACSDKMAAdsRequest = DACSDKMAAdsRequest(adTagURI: self.adTagUri, adContainer: adContainer)
        self.dacAdsLoader?.requestAds(request)
    }
    
    // VASTレスポンスの処理が終わった時に実行される
    func dacSdkMaAdsLoader(loader: DACSDKMAAdsLoader, adsLoadedWithData data: DACSDKMAAdsLoadedData) {
        self.dacAdsManager = data.adsManager
        self.dacAdsManager?.delegate = self
        // 広告動画ファイルのダウンロードする
        self.dacAdsManager?.load()
        
        self.dacAdController = DACSDKMAAdDefaultController(adsManager: data.adsManager)
    }
    
    // VASTリクエスト/レスポンスでエラーが呼ばれたときに実行される
    func dacSdkMaAdsLoader(loader: DACSDKMAAdsLoader, failedWithErrorData adErrorData: DACSDKMAAdLoadingErrorData) {
        // エラーログを出力する。
        NSLog("dacSdkMaAdsLoader: failedWithErrorData: \(adErrorData.adError.message)")
    }
    
    // AdsManagerのイベントが発生した時に実行される
    func dacSdkAdsManager(adsManager: DACSDKMAAdsManager, didReceiveAdEvent adEvent: DACSDKMAAdEvent) {
        if adEvent.type == DACSDKMAAdEventType.DidLoad {
            // 広告動画ファイルがダウンロードされたら、広告動画を再生する
            adsManager.play()
        }
        else if adEvent.type == DACSDKMAAdEventType.DidAllAdsComplete{
            adsManager.clean()
            self.dacAdsManager = nil
            self.dacAdController?.clean()
            self.dacAdController = nil
        }
    }
    
    // AdsManagerにエラーが発生した時に実行される
    func dacSdkAdsManager(adsManager: DACSDKMAAdsManager, didReceiveAdError adError: DACSDKMAAdError) {
        // エラーログを出力し、本編動画を再生する
        NSLog("dacSdkMaAdsManager: didReceiveAdError: \(adError.message)")
    }
    
    func dacSdkAdsManagerDidRequestContentPause(adsManager: DACSDKMAAdsManager) {
        // アプリに動画プレーヤーがないので何もしない
    }
    
    func dacSdkAdsManagerDidRequestContentResume(adsManager: DACSDKMAAdsManager) {
        // アプリに動画プレーヤーがないので何もしない
    }
}

