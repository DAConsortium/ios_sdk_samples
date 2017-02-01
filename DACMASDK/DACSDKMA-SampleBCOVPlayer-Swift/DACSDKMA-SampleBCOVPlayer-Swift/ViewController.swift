//
//  ViewController.swift
//  DACSDKMA-SamplePlayer-Swift
//
//  Copyright © 2015 D.A.Consortium Inc. All rights reserved.
//

import UIKit
import AVFoundation
// SDKをimportする
import DACSDKMA
import BrightcovePlayerSDK

class ViewController: UIViewController, DACSDKMAAdsLoaderDelegate, DACSDKMAAdsManagerDelegate {
    
    // --------------------------------------------------
    // MARK: BCOVSDK
    let kAccountID: String = "1234567899001"
    var playbackController: BCOVPlaybackController!
    
    // --------------------------------------------------
    // MARK: DACSDK
    // リクエスト先アドタグURI
    let adTagUri = "https://saxp.zedo.com/asw/fnsr.vast?n=2696&c=25/11&d=17&s=2&v=vast2&pu=__page-url__&ru=__referrer__&pw=__player-width__&ph=__player-height__&z=__random-number__"
    var dacAdsLoader: DACSDKMAAdsLoader?  = nil
    var dacAdsManager: DACSDKMAAdsManager? = nil
    var dacAdController: DACSDKMAAdController? = nil
    
    // --------------------------------------------------
    // MARK: 実装
    var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpVideoPlayerUI()
    }
    
    // 動画プレーヤーのUIをセットする
    func setUpVideoPlayerUI() {
        // videoViewをセットする
        let videoViewWidth: CGFloat = self.view.bounds.width - 40
        let videoViewHeight:CGFloat = videoViewWidth * 9.0 / 16.0
        let videoViewRect:  CGRect  = CGRect(x: 20, y: 40, width: videoViewWidth, height: videoViewHeight)
        
        self.videoView = UIView(frame: videoViewRect)
        self.videoView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.view.addSubview(self.videoView)
        
        self.setupBrightcove()
        self.setupMA()
    }
    
    func setupMA(){
        let maSettings: DACSDKMASettings = DACSDKMASettings()
        maSettings.vastMaxRedirects              = 5     // Wrapperをリクエストする最大回数。
        maSettings.vastResourceTimeOutSeconds    = 5.0   // VASTをリクエストした際のタイムアウト値
        maSettings.vastAllResourceTimeOutSeconds = 10.0  // VASTのリクエストを開始してから、すべてのVASTのロードが完了するまでのタイムアウト値
        maSettings.mediaLoadTimeOutSeconds       = 15.0  // メディアを読み込む際のタイムアウト値
        
        self.dacAdsLoader = DACSDKMAAdsLoader(settings: maSettings)
        self.dacAdsLoader!.delegate = self
        
        //広告動画を掲載するViewとリクエスト先アドサーバのURLをリクエストにセットする
        let adContainer: DACSDKMAAdContainer = DACSDKMAAdContainer(view: self.videoView!)
        let request = DACSDKMAAdsRequest(adTagURI: self.adTagUri, adContainer: adContainer)
        self.dacAdsLoader!.requestAds(request)
    }
    
    func setupBrightcove(){
        // 動画ファイルのURLからBrightCovePlayerを作成する
        let manager: BCOVPlayerSDKManager = BCOVPlayerSDKManager.shared()
        self.playbackController = manager.createPlaybackController(viewStrategy: manager.defaultControlsViewStrategy())
        self.playbackController.view.frame = self.videoView.bounds
        
        self.playbackController.analytics.account = kAccountID
        self.playbackController.isAutoAdvance = true
        self.playbackController.isAutoPlay = false
        
        // add the video array to the controller's playback queue
        // create an array of videos
        let videos: [BCOVVideo] = [self.videoWithURL(URL(string: "http://cf9c36303a9981e3e8cc-31a5eb2af178214dc2ca6ce50f208bb5.r97.cf1.rackcdn.com/bigger_badminton_600.mp4")),
            self.videoWithURL(URL(string: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"))]
        self.playbackController.setVideos(videos as NSFastEnumeration!)
    }
    
    func videoWithURL(_ url: URL?) -> BCOVVideo {
        // set the delivery method for BCOVSources that belong to a video
        let source: BCOVSource = BCOVSource(url: url, deliveryMethod: kBCOVSourceDeliveryHLS, properties: nil)
        return BCOVVideo(source: source, cuePoints: BCOVCuePointCollection(array: [AnyObject]()), properties: [AnyHashable: Any]())
    }
    
    
    // --------------------------------------------------
    // MARK: - DACSDKMA Delegate
    // --------------------------------------------------
    /// VASTレスポンスの処理が終わった時に実行される
    func dacsdkmaAdsLoader(_ loader: DACSDKMAAdsLoader, didLoad adsLoadedData: DACSDKMAAdsLoadedData) {
        self.dacAdsManager = adsLoadedData.adsManager
        adsLoadedData.adsManager.delegate = self
        // 広告動画ファイルのダウンロードする
        adsLoadedData.adsManager.load()
        
        self.dacAdController = DACSDKMAAdController(adsManager: adsLoadedData.adsManager)
    }
    
    /// VASTリクエスト/レスポンスでエラーが呼ばれたときに実行される
    func dacsdkmaAdsLoader(_ loader: DACSDKMAAdsLoader, didFail adError: DACSDKMAAdError) {
        // エラーログを出力し、本編動画を再生する
        NSLog("dacSdkMaAdsLoader: didFaile: \(adError.message)")
        self.playbackController.play()
    }
    
    /// AdsManagerのイベントが発生した時に実行される
    func dacsdkmaAdsManager(_ adsManager: DACSDKMAAdsManager, didReceiveAdEvent adEvent: DACSDKMAAdEvent) {
        switch adEvent.type {
        case .didLoad:
            // 広告動画ファイルがダウンロードされたら、広告動画を再生する
            adsManager.play()
            break
        case .didComplete:
            // 広告動画が終了したら、広告を消去する
            adsManager.clean()
            self.dacAdController?.clean()
            break
        default:
            break
        }
    }
    
    /// AdsManagerにエラーが発生した時に実行される
    func dacsdkmaAdsManager(_ adsManager: DACSDKMAAdsManager, didReceiveAdError adError: DACSDKMAAdError) {
        // エラーログを出力し、本編動画を再生する
    }
    
    func dacsdkmaAdsManagerDidRequestContentPause(_ adsManager: DACSDKMAAdsManager) {
        // 本編動画を一時停止
        self.playbackController.pause()
    }
    
    func dacsdkmaAdsManagerDidRequestContentResume(_ adsManager: DACSDKMAAdsManager) {
        // 本編動画を再生再開
        self.videoView.addSubview(self.playbackController.view)
        self.playbackController.play()
    }
}
