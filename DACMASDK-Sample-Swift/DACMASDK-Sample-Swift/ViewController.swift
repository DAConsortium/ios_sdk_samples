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

class ViewController: UIViewController, DACSDKMAAdsLoaderDelegate, DACSDKMAAdsManagerDelegate {
    
    // サンプル動画URL
    let contentUrl = "http://vjs.zencdn.net/v/oceans.mp4"
    
    // リクエスト先アドタグURI
    let adTagUri = "https://saxp.zedo.com/asw/fnsr.vast?n=2696&c=25/11&d=17&s=2&v=vast2&pu=__page-url__&ru=__referrer__&pw=__player-width__&ph=__player-height__&z=__random-number__"
    
    var contentPlayer:          AVPlayer!
    var contentAVPlayerItem:    AVPlayerItem!
    var videoView:              UIView!
    var playButton:             UIButton!
    
    var dacSdkAdsMaSettings: DACSDKMASettings? = nil
    var dacAdsLoader: DACSDKMAAdsLoader?  = nil
    var dacAdsManager: DACSDKMAAdsManager? = nil
    var dacAdController: DACSDKMAAdDefaultController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpVideoPlayerUI()
    }
    
    // 動画プレーヤーのUIをセットする
    func setUpVideoPlayerUI() {
        // videoViewをセットする
        let selfViewCGRect:     CGRect      = self.view.bounds
        let selfViewWidth:      CGFloat     = selfViewCGRect.width
        let selfViewHeight:     CGFloat     = selfViewCGRect.height
        let videoViewCGRect:    CGRect      = CGRectMake(20, 20, selfViewWidth - 40, selfViewHeight - 40)
        self.videoView = UIView(frame: videoViewCGRect)
        self.videoView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.videoView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        self.view.addSubview(self.videoView)
        
        // 動画ファイルのURLからAVPlayerを作成する
        let contentURL: NSURL = NSURL(string: self.contentUrl)!
        self.contentAVPlayerItem = AVPlayerItem(URL: contentURL)
        self.contentPlayer = AVPlayer(playerItem: self.contentAVPlayerItem)
        let contentPlayerView = UIAVPlayerView(frame: self.videoView.bounds)
        contentPlayerView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        self.videoView.addSubview(contentPlayerView)
        
        // AVPlayerをvideoViewのsublayerに追加する
        let playerLayer = contentPlayerView.layer as! AVPlayerLayer
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        playerLayer.player = self.contentPlayer
        self.videoView.layer.addSublayer(playerLayer)
        
        // playButtonをセットする
        self.playButton = UIButton(frame: CGRectMake(0, 0, selfViewWidth - 40, selfViewHeight - 40))
        self.playButton.setTitle("▶️", forState: .Normal)
        self.playButton.addTarget(self, action: #selector(onPlayButtonTouch(_:)), forControlEvents: .TouchUpInside)
        self.videoView.addSubview(self.playButton)
        self.playButton.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        self.playButton.layer.zPosition = 10
    }
    
    // VAST広告をリクエストする
    func requestAds() {
        let maSettings: DACSDKMASettings = DACSDKMASettings()
        maSettings.vastMaxRedirects                  = 5     // Wrapperをリクエストする最大回数。
        maSettings.vastResourceTimeOutSeconds    = 5.0   // VASTをリクエストした際のタイムアウト値
        maSettings.vastAllResourceTimeOutSeconds = 10.0  // VASTのリクエストを開始してから、すべてのVASTのロードが完了するまでのタイムアウト値
        maSettings.mediaLoadTimeOutSeconds       = 15.0  // メディアを読み込む際のタイムアウト値
        self.dacSdkAdsMaSettings = maSettings
        self.dacAdsLoader = DACSDKMAAdsLoader(settings: maSettings)
        self.dacAdsLoader!.delegate = self
        
        //広告動画を掲載するViewとリクエスト先アドサーバのURLをリクエストにセットする
        let adContainer: DACSDKMAAdContainer = DACSDKMAAdContainer(view: self.videoView!)
        let request: DACSDKMAAdsRequest = DACSDKMAAdsRequest(adTagURI: self.adTagUri, adContainer: adContainer)
        
        self.dacAdsLoader!.requestAds(request)
    }
    
    // 再生ボタンをタッチしたときの動作
    func onPlayButtonTouch(sender: UIButton) {
        // Prerollで流すとき、本編動画の再生はコメントアウトします
        // contentPlayer!.play()
        self.requestAds()
        self.playButton.hidden = true
    }
    
    // VASTレスポンスの処理が終わった時に実行される
    func dacSdkMaAdsLoader(loader: DACSDKMAAdsLoader, adsLoadedWithData data: DACSDKMAAdsLoadedData) {
        self.dacAdsManager = data.adsManager
        data.adsManager.delegate = self
        // 広告動画ファイルのダウンロードする
        data.adsManager.load()
        
        self.dacAdController = DACSDKMAAdDefaultController(adsManager: data.adsManager)
    }
    
    // VASTリクエスト/レスポンスでエラーが呼ばれたときに実行される
    func dacSdkMaAdsLoader(loader: DACSDKMAAdsLoader, failedWithErrorData adErrorData: DACSDKMAAdLoadingErrorData) {
        // エラーログを出力し、本編動画を再生する
        NSLog("dacSdkMaAdsLoader: failedWithErrorData: \(adErrorData.adError.message)")
        self.contentPlayer.play()
    }
    
    // AdsManagerのイベントが発生した時に実行される
    func dacSdkAdsManager(adsManager: DACSDKMAAdsManager, didReceiveAdEvent adEvent: DACSDKMAAdEvent) {
        if (adEvent.type == DACSDKMAAdEventType.DidLoad) {
            // 広告動画ファイルがダウンロードされたら、広告動画を再生する
            adsManager.play()
        }
        else if (adEvent.type == DACSDKMAAdEventType.DidAllAdsComplete) {
            // 広告動画が終了したら、広告を消去する
            adsManager.clean()
            self.dacAdsManager = nil
            self.dacAdController?.clean()
            self.dacAdController = nil
        }
    }
    
    // AdsManagerにエラーが発生した時に実行される
    func dacSdkAdsManager(adsManager: DACSDKMAAdsManager, didReceiveAdError adError: DACSDKMAAdError) {
        // エラーログを出力する。
        NSLog("dacSdkMaAdsManager: didReceiveAdError: \(adError.message)")
    }
    
    func dacSdkAdsManagerDidRequestContentPause(adsManager: DACSDKMAAdsManager) {
        // 本編動画を一時停止
        self.contentPlayer.pause()
    }
    
    func dacSdkAdsManagerDidRequestContentResume(adsManager: DACSDKMAAdsManager) {
        // 本編動画を再生再開
        self.contentPlayer.play()
    }
}

// レイヤーをAVPlayerLayerにするためのラッパークラス
class UIAVPlayerView: UIView {
    
    required init(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame:CGRect) {
        super.init(frame: frame)
    }
    
    override class func layerClass() -> AnyClass{
        return AVPlayerLayer.self
    }
}