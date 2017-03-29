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

class ViewController: UIViewController, DACSDKMAAdsLoaderDelegate, DACSDKMAAdsManagerDelegate {
    
    // サンプル動画URL
    let contentUrl = "http://vjs.zencdn.net/v/oceans.mp4"
    
    // リクエスト先アドタグURI
    let adTagUri = "https://saxp.zedo.com/asw/fnsr.vast?n=2696&c=25/11&d=17&s=2&v=vast2&pu=__page-url__&ru=__referrer__&pw=__player-width__&ph=__player-height__&z=__random-number__"
    
    var contentPlayer: AVPlayer!
    var videoView: UIView!
    var playButton: UIButton!
    
    var dacsdkmaAdsLoader: DACSDKMAAdsLoader?  = nil
    var dacsdkmaAdsManager: DACSDKMAAdsManager? = nil
    var dacsdkmaAdController: DACSDKMAAdController? = nil
    
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
        let videoViewCGRect:    CGRect      = CGRect(x: 20, y: 20, width: selfViewWidth - 40, height: selfViewHeight - 40)
        self.videoView = UIView(frame: videoViewCGRect)
        self.videoView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.videoView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.view.addSubview(self.videoView)
        
        // 動画ファイルのURLからAVPlayerを作成する
        let contentURL: URL = URL(string: self.contentUrl)!
        let contentAVPlayerItem: AVPlayerItem = AVPlayerItem(url: contentURL)
        self.contentPlayer = AVPlayer(playerItem: contentAVPlayerItem)
        let contentPlayerView = UIAVPlayerView(frame: self.videoView.bounds)
        contentPlayerView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.videoView.addSubview(contentPlayerView)
        
        // AVPlayerをvideoViewのsublayerに追加する
        let playerLayer = contentPlayerView.layer as! AVPlayerLayer
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        playerLayer.player = self.contentPlayer
        self.videoView.layer.addSublayer(playerLayer)
        
        // playButtonをセットする
        self.playButton = UIButton(frame: CGRect(x: 0, y: 0, width: selfViewWidth - 40, height: selfViewHeight - 40))
        self.playButton.setTitle("▶️", for: UIControlState())
        self.playButton.addTarget(self, action: #selector(onPlayButtonTouch(_:)), for: .touchUpInside)
        self.videoView.addSubview(self.playButton)
        self.playButton.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.playButton.layer.zPosition = 10
    }
    
    // VAST広告をリクエストする
    func requestAds() {
        let settings: DACSDKMASettings = DACSDKMASettings()
        settings.vastMaxRedirects              = 5     // Wrapperをリクエストする最大回数。
        settings.vastResourceTimeOutSeconds    = 5.0   // VASTをリクエストした際のタイムアウト値
        settings.vastAllResourceTimeOutSeconds = 10.0  // VASTのリクエストを開始してから、すべてのVASTのロードが完了するまでのタイムアウト値
        settings.mediaLoadTimeOutSeconds       = 15.0  // メディアを読み込む際のタイムアウト値
        
        self.dacsdkmaAdsLoader = DACSDKMAAdsLoader(settings: settings)
        self.dacsdkmaAdsLoader?.delegate = self
        
        //広告動画を掲載するViewとリクエスト先アドサーバのURLをリクエストにセットする
        let adContainer: DACSDKMAAdContainer = DACSDKMAAdContainer(view: self.videoView!)
        let request: DACSDKMAAdsRequest = DACSDKMAAdsRequest(adTagURI: self.adTagUri, adContainer: adContainer)
        self.dacsdkmaAdsLoader?.requestAds(request)
    }
    
    // 再生ボタンをタッチしたときの動作
    func onPlayButtonTouch(_ sender: UIButton) {
        // Prerollで流すとき、本編動画の再生はコメントアウトします
        // contentPlayer!.play()
        self.requestAds()
        self.playButton.isHidden = true
    }
    
    // VASTレスポンスの処理が終わった時に実行される
    func dacsdkmaAdsLoader(_ loader: DACSDKMAAdsLoader, didLoad adsLoadedData: DACSDKMAAdsLoadedData) {
        self.dacsdkmaAdsManager = adsLoadedData.adsManager
        adsLoadedData.adsManager.delegate = self
        // 広告動画ファイルのダウンロードする
        adsLoadedData.adsManager.load()
        
        self.dacsdkmaAdController = DACSDKMAAdController(adsManager: adsLoadedData.adsManager)
    }
    
    // VASTリクエスト/レスポンスでエラーが呼ばれたときに実行される
    func dacsdkmaAdsLoader(_ loader: DACSDKMAAdsLoader, didFail adError: DACSDKMAAdError) {
        // エラーログを出力し、本編動画を再生する
        NSLog("dacSdkMaAdsLoader: didFail: \(adError.message)")
        self.contentPlayer.play()
    }
    
    // AdsManagerのイベントが発生した時に実行される
    func dacsdkmaAdsManager(_ adsManager: DACSDKMAAdsManager, didReceiveAdEvent adEvent: DACSDKMAAdEvent) {
        if (adEvent.type == DACSDKMAAdEventType.didLoad) {
            // 広告動画ファイルがダウンロードされたら、広告動画を再生する
            adsManager.play()
        }
        else if (adEvent.type == DACSDKMAAdEventType.didAllAdsComplete) {
            // 広告動画が終了したら、広告を消去する
            adsManager.clean()
            self.dacsdkmaAdsManager = nil
            self.dacsdkmaAdController?.clean()
            self.dacsdkmaAdController = nil
        }
    }
    
    // AdsManagerにエラーが発生した時に実行される
    func dacsdkmaAdsManager(_ adsManager: DACSDKMAAdsManager, didReceiveAdError adError: DACSDKMAAdError) {
        // エラーログを出力する。
        NSLog("dacSdkMaAdsManager: didReceiveAdError: \(adError.message)")
    }
    
    func dacsdkmaAdsManagerDidRequestContentPause(_ adsManager: DACSDKMAAdsManager) {
        // 本編動画を一時停止
        self.contentPlayer.pause()
    }
    
    func dacsdkmaAdsManagerDidRequestContentResume(_ adsManager: DACSDKMAAdsManager) {
        // 本編動画を再生再開
        self.contentPlayer.play()
    }
}

// レイヤーをAVPlayerLayerにするためのラッパークラス
class UIAVPlayerView: UIView {
    override class var layerClass : AnyClass{
        return AVPlayerLayer.self
    }
}
