//
//  ViewController.swift
//  DACSDKMA-SamplePlayer-Swift
//
//  Copyright © 2016 D.A.Consortium Inc. All rights reserved.
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
    var dacAdController: DACSDKMAAdDefaultController? = nil
    
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
        let videoViewRect:  CGRect  = CGRectMake(20, 40, videoViewWidth, videoViewHeight)
        
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
        let manager: BCOVPlayerSDKManager = BCOVPlayerSDKManager.sharedManager()
        self.playbackController = manager.createPlaybackControllerWithViewStrategy(manager.defaultControlsViewStrategy())
        self.playbackController.view.frame = self.videoView.bounds
        
        self.playbackController.analytics.account = kAccountID
        self.playbackController.autoAdvance = true
        self.playbackController.autoPlay = false
        
        // add the video array to the controller's playback queue
        // create an array of videos
        let videos: [BCOVVideo] = [self.videoWithURL(NSURL(string: "http://cf9c36303a9981e3e8cc-31a5eb2af178214dc2ca6ce50f208bb5.r97.cf1.rackcdn.com/bigger_badminton_600.mp4")),
            self.videoWithURL(NSURL(string: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"))]
        self.playbackController.setVideos(videos)
    }
    
    func videoWithURL(url: NSURL?) -> BCOVVideo {
        // set the delivery method for BCOVSources that belong to a video
        let source: BCOVSource = BCOVSource(URL: url, deliveryMethod: kBCOVSourceDeliveryHLS, properties: nil)
        return BCOVVideo(source: source, cuePoints: BCOVCuePointCollection(array: [AnyObject]()), properties: [NSObject : AnyObject]())
    }
    
    
    // --------------------------------------------------
    // MARK: - DACSDKMA Delegate
    // --------------------------------------------------
    /// VASTレスポンスの処理が終わった時に実行される
    func dacSdkMaAdsLoader(loader: DACSDKMAAdsLoader, adsLoadedWithData data: DACSDKMAAdsLoadedData) {
        self.dacAdsManager = data.adsManager
        data.adsManager.delegate = self
        // 広告動画ファイルのダウンロードする
        data.adsManager.load()
        
        self.dacAdController = DACSDKMAAdDefaultController(adsManager: self.dacAdsManager!)
    }
    
    /// VASTリクエスト/レスポンスでエラーが呼ばれたときに実行される
    func dacSdkMaAdsLoader(loader: DACSDKMAAdsLoader, failedWithErrorData adErrorData: DACSDKMAAdLoadingErrorData) {
        // エラーログを出力し、本編動画を再生する
        NSLog("dacSdkMaAdsLoader: failedWithErrorData: \(adErrorData.adError.message)")
        self.playbackController.play()
    }
    
    /// AdsManagerのイベントが発生した時に実行される
    func dacSdkAdsManager(adsManager: DACSDKMAAdsManager, didReceiveAdEvent adEvent: DACSDKMAAdEvent) {
        switch adEvent.type {
        case .DidLoad:
            // 広告動画ファイルがダウンロードされたら、広告動画を再生する
            adsManager.play()
            break
        case .DidComplete:
            // 広告動画が終了したら、広告を消去する
            adsManager.clean()
            self.dacAdController?.clean()
            break
        default:
            break
        }
    }
    
    /// AdsManagerにエラーが発生した時に実行される
    func dacSdkAdsManager(adsManager: DACSDKMAAdsManager, didReceiveAdError adError: DACSDKMAAdError) {
        // エラーログを出力し、本編動画を再生する
    }
    
    func dacSdkAdsManagerDidRequestContentPause(adsManager: DACSDKMAAdsManager) {
        // 本編動画を一時停止
        self.playbackController.pause()
    }
    
    func dacSdkAdsManagerDidRequestContentResume(adsManager: DACSDKMAAdsManager) {
        // 本編動画を再生再開
        self.videoView.addSubview(self.playbackController.view)
        self.playbackController.play()
    }
}