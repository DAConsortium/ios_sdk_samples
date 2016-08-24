//
//  DACSDKMASmartVisionAdPlayer.swift
//  DACSDKMA
//
//  Copyright (c) 2015 D.A.Consortium Inc. All rights reserved.
//

import UIKit
import DACSDKMA


// --------------------------------------------------
// MARK: - delegate
// --------------------------------------------------
/// 動画広告プレイヤークラス用デリゲート
@objc
public protocol DACSDKMASmartVisionAdPlayerDelegate: class {
    
    /**
     動画の読み込みに成功後、イベントが発生する度に呼ばれます。
     - parameter smartVisionAdPlayer: イベントが発生したビュー
     - parameter adEvent: 発生したイベント
     */
    optional func dacSdkMaSmartVisionAdPlayer(smartVisionAdPlayer: DACSDKMASmartVisionAdPlayer, DidReceiveAdEvent adEvent: DACSDKMAAdEvent)
    
    /**
     動画の読み込みに失敗、再生中にエラーが発生した際に呼ばれます。
     - parameter SmartVisionAdPlayer: エラーが発生したビュー
     - parameter adError: 発生したエラー
     */
    optional func dacSdkMaSmartVisionAdPlayer(smartVisionAdPlayer: DACSDKMASmartVisionAdPlayer, DidReceiveAdError adError: DACSDKMAAdError)
}



// --------------------------------------------------
// MARK: - class
// --------------------------------------------------
/// 動画広告プレイヤークラス
@objc
public class DACSDKMASmartVisionAdPlayer: UIView, DACSDKMAAdsLoaderDelegate, DACSDKMAAdsManagerDelegate, DACSDKMAAdControlsViewDelegate {
    
    private static let KVOContext = UnsafeMutablePointer<Void>(nil)
    
    // --------------------------------------------------
    // MARK: static properties
    // --------------------------------------------------
    
    /// コンパニオン画像の倍率(AdServerが2倍の画像を常に返してくるため)
    private static let companionImageScale: CGFloat = 2.0
    
    /// 止め画像のサイズ
    private static let companionSizeAtStop: CGSize = CGSizeMake(320, 180)
    
    /// 動画下部バナーのサイズ
    private static let companionSizeAtBottom: CGSize = CGSizeMake(300, 82)
    
    
    // --------------------------------------------------
    // MARK: public properties
    // --------------------------------------------------
    
    /// デリゲート
    public weak var delegate: DACSDKMASmartVisionAdPlayerDelegate? = nil
    
    /// (readonly)
    public private(set) var adsLoader: DACSDKMAAdsLoader? = nil
    
    /// (readonly)
    public private(set) var adsManager: DACSDKMAAdsManager? = nil {
        willSet { if nil == newValue { self.unregisterObserver() } }
        didSet { if nil != self.adsManager { self.registerObserver() } }
    }

    /// 動画広告枠(readonly)
    public private(set) var adVideoContainer: DACSDKMAAdContainer!
    
    /// 表示される動画広告のサイズ(readonly)
    public private(set) var adVideoSize: CGSize = CGSizeZero
    
    // --------------------------------------------------
    // MARK: private properties
    // --------------------------------------------------
    // ----- 動画広告枠 -----
    /// AutoLayout設定
    private var layoutConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
    
    /// 動画広告コントローラー
    private var adVideoControlsView: DACSDKMAAdVideoControlsView? = nil
    
    // ----- コンパニオン -----
    /// 止め画像コントローラー
    private var companionAtStopControlsView: DACSDKMACompanionAtStopControlsView? = nil
    
    /// 止め画像
    private var companionSlotAtStop: DACSDKMACompanionSlot!
    
    /// 動画下部バナー
    private var companionSlotAtBottom: DACSDKMACompanionSlot!
    
    /// 1by1コンパニオン
    private var companionSlotFor1By1: DACSDKMACompanionSlot!
    
    /// 2by2コンパニオン
    private var companionSlotFor2By2: DACSDKMACompanionSlot!
    
    // ----- KVO -----
    private var registeredObserver: Bool = false
    
    
    // --------------------------------------------------
    // MARK: life cycle
    // --------------------------------------------------
    deinit {
        self.clean()
    }
    
    
    // --------------------------------------------------
    // MARK: public methods
    // --------------------------------------------------
    
    /**
    動画広告の読み込みを開始します。
    - parameter vastAdTagURI    : 指定されたURIを設定します。
    - parameter enableAutoplay  : 動画広告の読み込み後、自動的に再生を開始する場合はtrueにします。falseにした場合、resume()を呼び出すことで開始することが可能です。
    */
    public func load(adTagURI: String, enableAutoplay: Bool = true) {
        if nil != self.adsLoader {
            // すでにロード済みの場合、何もしない。
            return
        }
        
        // ----- Setting  -----
        let settings: DACSDKMASettings  = DACSDKMASettings(autoStart: enableAutoplay)
        settings.autoAdHidden = false
        settings.autoAdvanceToNextAdBreak = false
        
        // 縦半分見えていれば、インビュー扱い。
        settings.playableRatio = DACSDKMACGRatio(x: 0.01, y: 0.50)
        
        // ----- RequestAds -----
        let adsLoader: DACSDKMAAdsLoader = DACSDKMAAdsLoader(settings: settings)
        adsLoader.delegate = self
        
        self.setup()

        let request = DACSDKMAAdsRequest(adTagURI: adTagURI, adContainer: self.adVideoContainer)
        adsLoader.requestAds(request)
        
        self.adsLoader = adsLoader
    }
    
    /**
     動画広告の再生を開始します。読み込みが完了していない場合、完了後に再生を開始します。
     */
    public func resume() {
        self.adsManager?.play()
    }
    
    /**
     動画広告の再生を一時停止します。
     */
    public func pause() {
        self.adsManager?.pause()
    }
    
    /**
     このビューを閉じ、動画広告の再生に使用したインスタンスなどを解放します。
     */
    public func clean() {
        self.pause()
        
        self.delegate = nil        
        
        self.adsManager?.delegate = nil
        self.adsManager?.clean()
        self.adsManager = nil
        
        self.adsLoader?.delegate = nil
        self.adsLoader = nil
        
        dacsdkmaDeactivateConstraints(self.layoutConstraints, view: self)

        self.companionAtStopControlsView?.removeFromSuperview()
        self.companionAtStopControlsView = nil
        
        self.adVideoControlsView?.removeFromSuperview()
        self.adVideoControlsView = nil
        
        self.companionSlotAtStop?.slot.removeFromSuperview()
        self.companionSlotAtStop?.companion?.removeFromSuperview()
        self.companionSlotAtBottom?.slot.removeFromSuperview()
        self.companionSlotAtBottom?.companion?.removeFromSuperview()        
        self.companionSlotFor1By1?.slot.removeFromSuperview()
        self.companionSlotFor1By1?.companion?.removeFromSuperview()
        self.companionSlotFor2By2?.slot.removeFromSuperview()
        self.companionSlotFor2By2?.companion?.removeFromSuperview()
        
        self.removeFromSuperview()
    }
    
    
    // --------------------------------------------------
    // MARK: private methods
    // --------------------------------------------------
    /**
    使用するための準備をする。
    */
    private func setup() {
        self.backgroundColor = UIColor.blackColor()
        
        // ----- 広告枠設定 -----
        let adVideoContainerView: UIView = UIView(frame: self.bounds)
        adVideoContainerView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        adVideoContainerView.backgroundColor = self.backgroundColor
        self.addSubview(adVideoContainerView)
        
        // ----- コンパニオン枠設定 -----
        var companionSlots: [DACSDKMACompanionSlot] = [DACSDKMACompanionSlot]()
        
        // 1by1は除外する
        let excludeFilterFor1By1: (size: CGSize) -> Bool = { (size: CGSize) in
            return (1 == size.width && 1 == size.height) ? true : false
        }
        
        // 2by2は除外する
        let excludeFilterFor2By2: (size: CGSize) -> Bool = { (size: CGSize) in
            return (2 == size.width && 2 == size.height) ? true : false
        }
        
        // 止め画像
        let companionViewAtStop: UIView = UIView(frame: CGRectMake(0, 0, DACSDKMASmartVisionAdPlayer.companionSizeAtStop.width, DACSDKMASmartVisionAdPlayer.companionSizeAtStop.height))
        companionViewAtStop.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        let companionSlotAtStopExcludeFilters: [DACSDKMACompanionSlot.ExcludeFilter] = [excludeFilterFor1By1, excludeFilterFor2By2, { (size: CGSize) in
            // 幅 16: 高さ 9のアスペクト比に近くないものは除外する。
            let ratio: CGFloat = (size.width / size.height)
            return (ratio <= 1.0) || (2.0 <= ratio)
            }
        ]
        let companionSlotAtStop: DACSDKMACompanionSlot = DACSDKMACompanionSlot(
            slot: companionViewAtStop,
            size: CGSizeMake(DACSDKMASmartVisionAdPlayer.companionSizeAtStop.width * DACSDKMASmartVisionAdPlayer.companionImageScale, DACSDKMASmartVisionAdPlayer.companionSizeAtStop.height * DACSDKMASmartVisionAdPlayer.companionImageScale),
            excludeFilters: companionSlotAtStopExcludeFilters)
        self.companionSlotAtStop = companionSlotAtStop
        companionSlots.append(companionSlotAtStop)
        
        // 動画下部バナー
        let companionViewAtBottom: UIView = UIView(frame: CGRectMake(0, 0, DACSDKMASmartVisionAdPlayer.companionSizeAtBottom.width, DACSDKMASmartVisionAdPlayer.companionSizeAtBottom.height))
        companionViewAtBottom.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        let companionSlotAtBottomExcludeFilters: [DACSDKMACompanionSlot.ExcludeFilter] = [excludeFilterFor1By1, excludeFilterFor2By2, { (size: CGSize) in
            // 幅 300px: 高さ 82pxのアスペクト比に近くないものは除外する。
            let ratio: CGFloat = (size.width / size.height)
            return (ratio <= 3.0) || (6.5 <= ratio)
            }]
        let companionSlotAtBottom: DACSDKMACompanionSlot = DACSDKMACompanionSlot(
            slot: companionViewAtBottom,
            size: CGSizeMake(DACSDKMASmartVisionAdPlayer.companionSizeAtBottom.width * DACSDKMASmartVisionAdPlayer.companionImageScale, DACSDKMASmartVisionAdPlayer.companionSizeAtBottom.height * DACSDKMASmartVisionAdPlayer.companionImageScale),
            excludeFilters: companionSlotAtBottomExcludeFilters)
        self.companionSlotAtBottom = companionSlotAtBottom
        companionSlots.append(companionSlotAtBottom)
        
        // 1by1
        let companionViewFor1By1: UIView = UIView(frame: CGRectZero)
        let companionSlotFor1By1ExcludeFilters: [DACSDKMACompanionSlot.ExcludeFilter] = [ { (size: CGSize) in
            // 1by1以外を除外する
            return !excludeFilterFor1By1(size: size)
            } ]
        let companionSlotFor1By1: DACSDKMACompanionSlot  = DACSDKMACompanionSlot(slot: companionViewFor1By1, size: CGSizeMake(1, 1), excludeFilters: companionSlotFor1By1ExcludeFilters)
        self.companionSlotFor1By1 = companionSlotFor1By1
        companionSlots.append(companionSlotFor1By1)
        
        // 2by2
        let companionViewFor2By2: UIView = UIView(frame: CGRectZero)
        let companionSlotFor2By2ExcludeFilters: [DACSDKMACompanionSlot.ExcludeFilter] = [ { (size: CGSize) in
            // 2by2以外を除外する
            return !excludeFilterFor2By2(size: size)
            } ]
        let companionSlotFor2By2: DACSDKMACompanionSlot  = DACSDKMACompanionSlot(slot: companionViewFor2By2, size: CGSizeMake(2, 2), excludeFilters: companionSlotFor2By2ExcludeFilters)
        self.companionSlotFor2By2 = companionSlotFor2By2
        companionSlots.append(companionSlotFor2By2)
        
        self.adVideoContainer = DACSDKMAAdContainer(view: adVideoContainerView, companionSlots: companionSlots)
    }
    
    /**
     必要に応じて、動画広告を停止する。
     - Returns: 停止した場合、true。停止しない場合、false。
     */
    private func stopIfNeeded() -> Bool {
        guard let adsManager = self.adsManager else { return false }
        var result: Bool = false
        
        defer {
            if result {
                // フルスクリーンの場合、デフォルトサイズに変更する。
                adsManager.fullscreen(false)
                adsManager.stop()
                self.adVideoControlsView?.playbackStatus = DACSDKMAAdVideoPlaybackStates.Stopped
            }
        }
        
        // 止め画像が無い場合、停止しない。以降の処理は行わない。
        if nil == self.companionSlotAtStop.companion { result = false ; return result }
        
        // 完全に画面外になった場合、停止する。
        if DACSDKMAInViewStates.Excluded == adsManager.playableStatus.inViewStatus { result = true ; return result }
        
        // オフスクリーンになった場合、停止する。
        if !(adsManager.playableStatus.isOnScreen) { result = true ; return result }
        
        // 他の広告がフルスクリーンになった場合、停止する。
        if adsManager.playableStatus.isOtherViewInFullscreen { result = true ; return result }
        
        return false
    }
    
    /**
     止め画像を非表示にする。
     */
    private func hideCompanionAtStop() {
        // 止め画像が非表示であれば、何もしない
        if nil == self.companionAtStopControlsView { return }
        
        // コンパニオンを非表示
        self.companionAtStopControlsView?.delegate = nil
        self.companionAtStopControlsView?.removeFromSuperview()
        self.companionAtStopControlsView = nil
        self.companionSlotAtStop.slot.removeFromSuperview()
        
        // 動画広告コントローラーを表示
        self.adVideoControlsView?.hidden = false
    }
    
    /**
     止め画像を表示する。
     */
    private func showCompanionAtStop() {
        // コンパニオンが無ければ、何もしない。
        if nil == self.companionSlotAtStop.companion { return }
        
        guard let adsManager: DACSDKMAAdsManager = self.adsManager else { return }
        
        // フルスクリーンの場合、表示しない。以降の処理は行わない。
        if adsManager.isFullscreen { return }
        
        // コンパニオンの表示
        self.companionSlotAtStop.slot.frame = self.adVideoContainer.view.bounds
        self.companionSlotAtStop.companion?.frame = adsManager.videoRect
        self.bringSubviewToFront(self.companionSlotAtStop.slot)
        
        // 動画広告コントローラーを非表示
        self.adVideoControlsView?.hidden = true
        
        // 止め画像を表示済みであれば、サイズ変更とトップレイヤーへの移動のみ行う。
        if nil != self.companionAtStopControlsView { return }
        
        // 止め画像表示中は動画は停止する。
        adsManager.pause()
        self.adVideoControlsView?.playbackStatus = DACSDKMAAdVideoPlaybackStates.Stopped
        
        // 止め画像の表示
        self.addSubview(self.companionSlotAtStop.slot)
        
        // 止め画像コントローラーを表示
        let companionAtStopControlsView: DACSDKMACompanionAtStopControlsView =  DACSDKMACompanionAtStopControlsView(frame: self.companionSlotAtStop.slot.bounds)
        companionAtStopControlsView.delegate = self
        self.companionSlotAtStop.slot.addSubview(companionAtStopControlsView)
        
        self.companionAtStopControlsView = companionAtStopControlsView
    }
    
    /**
     止め画像を表示を更新する。
     */
    private func updateCompanionAtStop() {
        guard let playbackStatus: DACSDKMAAdVideoPlaybackStates = self.adsManager?.playbackStatus else { return }
        switch playbackStatus {
        case .Playing:
            self.hideCompanionAtStop()
            break
        case .Pausing:
            if self.stopIfNeeded() {
                // 止め画像を表示する
                self.showCompanionAtStop()
            }
            break
        case .Stopped:
            // 止め画像を表示する
            self.showCompanionAtStop()
            break
        default:
            break
        }
    }
    
    /**
     インライン化する
     */
    private func toInline() {
        // 表示済みの場合は何もしない。
        if nil != self.adVideoControlsView as? DACSDKMASmartVisionAdPlayerControlsViewForInline { return }
        
        guard let adsManager = self.adsManager else { return }
        
        // インライン用ビューコントローラーの生成
        let controslView: DACSDKMASmartVisionAdPlayerControlsViewForInline = DACSDKMASmartVisionAdPlayerControlsViewForInline(frame: self.adVideoContainer.view.bounds)
        controslView.isMute = adsManager.isMute
        controslView.playbackStatus = adsManager.playbackStatus
        controslView.delegate = self
        self.adVideoContainer.view.addSubview(controslView)
        
        if nil == self.companionSlotFor1By1.companion {
            controslView.enterFullscreenButton.hidden = false
            controslView.detailButton.hidden = true
        }
        else {
            controslView.enterFullscreenButton.hidden = true
            controslView.detailButton.hidden = false
        }
        self.adVideoControlsView = controslView
        
        // ----- 動画下部バナー -----
        if nil == self.companionSlotAtBottom.companion {
            // 該当するコンパニオンが無い場合は、表示しない。
        }
        else {
            // self.adVideoContainer.view.frameを変更するために、AutoLayoutを一旦無効にする。
            dacsdkmaDeactivateConstraints(self.layoutConstraints, view: self)
            self.adVideoContainer.view.translatesAutoresizingMaskIntoConstraints = true

            // AutoLayoutを有効にする。
            self.adVideoContainer.view.frame = self.bounds
            self.adVideoContainer.view.translatesAutoresizingMaskIntoConstraints = false
            
            self.companionSlotAtBottom.slot.frame.size = CGSizeMake(self.companionSlotAtBottom.size.width / DACSDKMASmartVisionAdPlayer.companionImageScale, self.companionSlotAtBottom.size.height / DACSDKMASmartVisionAdPlayer.companionImageScale)
            self.companionSlotAtBottom.slot.backgroundColor = self.backgroundColor
            self.companionSlotAtBottom.slot.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(self.companionSlotAtBottom.slot)
            
            if self.layoutConstraints.isEmpty {
                // 動画枠の下にコンパニオンを表示する。コンパニオンは中央横に配置する。コンパニオンの大きさは固定。
                let spacerLeft = UIView(); spacerLeft.hidden = true; spacerLeft.translatesAutoresizingMaskIntoConstraints = false
                let spacerRight = UIView(); spacerRight.hidden = true; spacerRight.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(spacerLeft)
                self.addSubview(spacerRight)
                
                let views: [String: UIView] = [
                    "adVideoContainer": self.adVideoContainer.view,
                    "companionSlotAtBottom": self.companionSlotAtBottom.slot,
                    "sl": spacerLeft,
                    "sr": spacerRight
                ]
                
                let metrics: [String : AnyObject] = [
                    "companionWidth": self.companionSlotAtBottom.slot.frame.size.width,
                    "companionHeight": self.companionSlotAtBottom.slot.frame.size.height,
                ]
                
                var layoutConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
                layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:|[adVideoContainer]|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views)
                )
                layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:|[sl(>=1)]-(<=0)-[companionSlotAtBottom(companionWidth)]-(<=0)-[sr(sl)]|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: metrics, views: views)
                )
                layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|[adVideoContainer]-(<=0)-[companionSlotAtBottom(companionHeight)]|", options: NSLayoutFormatOptions(), metrics: metrics, views: views)
                )
                layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:[sl]|", options: NSLayoutFormatOptions(), metrics: nil, views: views)
                )
                layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:[sr]|", options: NSLayoutFormatOptions(), metrics: nil, views: views)
                )
                self.layoutConstraints = layoutConstraints
            }
            
            dacsdkmaActivateConstraints(self.layoutConstraints, view: self)
        }
        
        // レイアウトの更新を行う。
        self.adVideoContainer.view.layoutIfNeeded()
        controslView.playerView.frame = adsManager.videoRect
    }
    
    /**
     フルスクリーン化する
     */
    private func toFullscreen() {
        // 表示済みの場合は何もしない。
        if nil != self.adVideoControlsView as? DACSDKMASmartVisionAdPlayerControlsViewForFullscreen { return }
        
        guard let adsManager: DACSDKMAAdsManager = self.adsManager else { return }
        guard let fullscreenView: UIView = adsManager.fullscreenView else { return }
        
        // フルスクリーン用ビューコントローラーの生成
        let controslView: DACSDKMASmartVisionAdPlayerControlsViewForFullscreen = DACSDKMASmartVisionAdPlayerControlsViewForFullscreen(frame: fullscreenView.bounds)
        controslView.isMute = adsManager.isMute
        controslView.playbackStatus = adsManager.playbackStatus
        controslView.durationLabel.text = String(format: "%2d:%.2d", Int(adsManager.durationTime / 60), Int(adsManager.durationTime % 60))
        controslView.delegate = self
        fullscreenView.addSubview(controslView)
        self.adVideoControlsView = controslView
        
        // レイアウトの更新を行う。
        self.adVideoContainer.view.layoutIfNeeded()
        controslView.playerView.frame = adsManager.videoRect
    }
    
    /**
     動画広告コントローラー・ビューの削除
     */
    private func removeAdControlsView() {
        // AutoLayout解除
        dacsdkmaDeactivateConstraints(self.layoutConstraints, view: self)
        
        // ビューコントローラーの破棄
        self.adVideoControlsView?.delegate = nil
        self.adVideoControlsView?.removeFromSuperview()
        self.adVideoControlsView = nil
        
        // AutoresizingMask有効
        self.adVideoContainer.view.translatesAutoresizingMaskIntoConstraints = true
    }
    
    // --------------------------------------------------
    // MARK: KVO
    // --------------------------------------------------
    /**
    KVO登録
    */
    private func registerObserver() {
        if true == self.registeredObserver { return }
        guard let adsManager: DACSDKMAAdsManager = self.adsManager else { return }
        adsManager.addObserver(self, forKeyPath:"videoRect", options:.New, context: DACSDKMASmartVisionAdPlayer.KVOContext)
        adsManager.addObserver(self, forKeyPath:"progressTime", options:.New, context: DACSDKMASmartVisionAdPlayer.KVOContext)
        self.registeredObserver = true
    }
    
    /**
     KVO解除
     */
    private func unregisterObserver() {
        if false == self.registeredObserver { return }
        self.registeredObserver = false
        guard let adsManager: DACSDKMAAdsManager = self.adsManager else { return }
        adsManager.removeObserver(self, forKeyPath:"videoRect", context: DACSDKMASmartVisionAdPlayer.KVOContext)
        adsManager.removeObserver(self, forKeyPath:"progressTime", context: DACSDKMASmartVisionAdPlayer.KVOContext)
    }
    
    /**
     KVO
     */
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == DACSDKMASmartVisionAdPlayer.KVOContext {
            guard let keyPath: String = keyPath else { return }
            guard let adsManager: DACSDKMAAdsManager = self.adsManager else { return }
            
            dispatch_async(dispatch_get_main_queue()) {
                switch keyPath {
                case "videoRect":
                    // 広告表示プレイヤーのサイズが変更した。
                    self.companionSlotAtStop.companion?.frame = adsManager.videoRect
                    self.adVideoControlsView?.playerView.frame = adsManager.videoRect
                    break
                case "progressTime":
                    // 広告の再生時間が変更した。
                    let progressTimeStr = String(format: "%2d:%.2d", Int(adsManager.progressTime / 60), Int(adsManager.progressTime % 60))
                    self.adVideoControlsView?.progress = Float(adsManager.progress)
                    self.adVideoControlsView?.progressTimeLabel.text = progressTimeStr
                    break
                default:
                    break
                }
            }
        }
        else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    
    // --------------------------------------------------
    // MARK: delegate of DACSDKMA
    // --------------------------------------------------
    public func dacSdkMaAdsLoader(loader: DACSDKMAAdsLoader, adsLoadedWithData data: DACSDKMAAdsLoadedData) {
        let adsManager: DACSDKMAAdsManager = data.adsManager
        adsManager.delegate = self
        adsManager.load()
        
        self.adsManager = adsManager
    }
    
    public func dacSdkMaAdsLoader(loader: DACSDKMAAdsLoader, failedWithErrorData adErrorData: DACSDKMAAdLoadingErrorData) {
        self.adVideoSize = CGSizeZero
        
        // アプリに通知する。
        self.delegate?.dacSdkMaSmartVisionAdPlayer?(self, DidReceiveAdError: adErrorData.adError)
    }
    
    public func dacSdkAdsManager(adsManager: DACSDKMAAdsManager, didReceiveAdEvent adEvent: DACSDKMAAdEvent) {
        switch adEvent.type {
        case DACSDKMAAdEventType.DidLoad:
            self.adVideoSize = adsManager.videoSize
            if nil == self.adVideoControlsView {
                self.toInline()
                self.adVideoControlsView?.hidden = true
            }
            break
        case DACSDKMAAdEventType.WillEnterFullscreen:
            self.removeAdControlsView()
            break
        case DACSDKMAAdEventType.DidEnterFullscreen:
            self.toFullscreen()
            break
        case DACSDKMAAdEventType.WillExitFullscreen:
            self.removeAdControlsView()
            break
        case DACSDKMAAdEventType.DidExitFullscreen:
            self.toInline()
            self.showCompanionAtStop()
            break
        case DACSDKMAAdEventType.DidClose:
            self.clean()
            break
        case DACSDKMAAdEventType.DidAdBreakStart:
            if let adVideoControlsView: DACSDKMAAdVideoControlsView = self.adVideoControlsView {
                adVideoControlsView.hidden = false
                adVideoControlsView.superview?.bringSubviewToFront(adVideoControlsView)
            }
            self.adVideoControlsView?.playbackStatus = DACSDKMAAdVideoPlaybackStates.Playing
            self.hideCompanionAtStop()
            break
        case DACSDKMAAdEventType.DidAdBreakEnd:
            self.adVideoControlsView?.playbackStatus = DACSDKMAAdVideoPlaybackStates.Stopped
            self.showCompanionAtStop()
            break
        case DACSDKMAAdEventType.DidResume:
            self.adVideoControlsView?.playbackStatus = DACSDKMAAdVideoPlaybackStates.Playing
            self.hideCompanionAtStop()
            break
        case DACSDKMAAdEventType.DidPause:
            if DACSDKMAAdVideoPlaybackStates.Playing == self.adVideoControlsView?.playbackStatus {
                // 再生時のみ、ステータス変更をする。停止中から一時停止にはしない。
                self.adVideoControlsView?.playbackStatus = DACSDKMAAdVideoPlaybackStates.Pausing
                self.updateCompanionAtStop()
            }
            break
        case DACSDKMAAdEventType.DidStop:
            self.adVideoControlsView?.playbackStatus = DACSDKMAAdVideoPlaybackStates.Stopped
            self.updateCompanionAtStop()
            break
        default:
            break
        }
        
        // アプリに通知する。
        self.delegate?.dacSdkMaSmartVisionAdPlayer?(self, DidReceiveAdEvent: adEvent)
    }
    
    public func dacSdkAdsManager(adsManager: DACSDKMAAdsManager, didReceiveAdError adError: DACSDKMAAdError) {
        // アプリに通知する。
        self.delegate?.dacSdkMaSmartVisionAdPlayer?(self, DidReceiveAdError: adError)
    }
    
    public func dacSdkAdsManagerDidRequestContentPause(adsManager: DACSDKMAAdsManager) {
        // 現在のところ、特に何もしない。
    }
    
    public func dacSdkAdsManagerDidRequestContentResume(adsManager: DACSDKMAAdsManager) {
        // 現在のところ、特に何もしない。
    }
    
    
    // --------------------------------------------------
    // MARK: delegate of DACSDKMAAdControlsView
    // --------------------------------------------------
    public func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickPlayerView view: UIView) {
        if true == self.adsManager?.isFullscreen {
            self.adsManager?.clickVideo()
        }
        else {
            if nil == self.companionSlotFor1By1.companion {
                self.adsManager?.clickVideo()
            }
            else {
                self.adsManager?.fullscreen(true)
            }
        }
    }
    
    public func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickVolumeButton button: UIButton) {
        self.adsManager?.mute(adControlsView.isMute)
    }
    
    public func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickPlayButton button: UIButton) {
        if adControlsView.isPlaying {
            self.adsManager?.play()
        } else {
            self.adsManager?.pause()
        }
    }
    
    public func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickReplayButton button: UIButton) {
        self.adsManager?.replay()
    }
    
    public func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickEnterFullscreenButton button: UIButton) {
        self.adsManager?.fullscreen(true)
    }
    
    public func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickExitFullscreenButton button: UIButton) {
        if nil == self.companionSlotFor2By2.companion {
            self.adsManager?.fullscreen(false)
        }
        else {
            self.adsManager?.clickVideo()
            self.adsManager?.fullscreen(false)
        }
    }
    
    public func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickCloseButton button: UIButton) {
        self.adsManager?.clean()
    }
    
    public func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickDetailButton button: UIButton) {
        self.adsManager?.clickVideo()
    }
    
}



// --------------------------------------------------
// MARK: - class
// --------------------------------------------------
/// 動画広告コントローラー既定クラス
@objc
public class DACSDKMAAdVideoControlsView: DACSDKMAAdControlsView {
    
    // --------------------------------------------------
    // MARK: life cycle
    // --------------------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 再生・一時停止ボタンの設定
        self.playButton.setImage(DACSDKMAAdImageGenerator.playButtonIconImage, forState: UIControlState.Normal)
        self.playButton.setImage(DACSDKMAAdImageGenerator.pauseButtonIconImage, forState: UIControlState.Selected)

        // リプレイボタンの設定
        self.replayButton.setImage(DACSDKMAAdImageGenerator.replayButtonLabelImage, forState: UIControlState.Normal)
        
        // 音量ボタンの設定
        self.volumeButton.setImage(DACSDKMAAdImageGenerator.volumeOnButtonIconImage, forState: UIControlState.Normal)
        self.volumeButton.setImage(DACSDKMAAdImageGenerator.volumeOffButtonIconImage, forState: UIControlState.Selected)
        
        // Xボタンの設定
        self.closeButton.setImage(DACSDKMAAdImageGenerator.closeButtonIconImage, forState: UIControlState.Normal)
        
        // フルスクリーン化ボタンの設定
        self.enterFullscreenButton.setImage(DACSDKMAAdImageGenerator.enterFullscreenButtonLabelImage, forState: UIControlState.Normal)
        
        // インライン化ボタンの設定
        self.exitFullscreenButton.setImage(DACSDKMAAdImageGenerator.exitFullscreenButtonLabelImage, forState: UIControlState.Normal)
        
        // 詳細を見るボタンの設定
        self.detailButton.setImage(DACSDKMAAdImageGenerator.detailButtonLabelImage, forState: UIControlState.Normal)
    }
}


// --------------------------------------------------
// MARK: - class
// --------------------------------------------------
/// 動画広告コントローラー・インライン用
public class DACSDKMASmartVisionAdPlayerControlsViewForInline: DACSDKMAAdVideoControlsView {
    
    // --------------------------------------------------
    // MARK: life cycle
    // --------------------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.volumeButton)
        self.addSubview(self.replayButton)
        self.addSubview(self.enterFullscreenButton)
        self.addSubview(self.closeButton)
        self.addSubview(self.detailButton)

        self.replayButton.hidden = true
    }
    
    
    // --------------------------------------------------
    // MARK: override methods
    // --------------------------------------------------
    
    override public func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        if nil == newSuperview {
            dacsdkmaDeactivateConstraints(self.layoutConstraints, view: self)
            return
        }
        
        // AutoLayout設定
        if self.layoutConstraints.isEmpty {
            var layoutConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
            
            // 音量ボタン - 左上に表示する(停止中は表示しない)
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[volumeButton(iconWidth)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-margin-[volumeButton(iconHeight)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            // リプレイボタン - 左上に表示する(停止中のみ表示する)
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[replayButton(labelWidth)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-margin-[replayButton(labelHeight)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            // Xボタン - 右上に表示する
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:[closeButton(iconWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-margin-[closeButton(iconHeight)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            // フルスクリーン化ボタン - 右下に表示する
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:[enterFullscreenButton(labelWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:[enterFullscreenButton(labelHeight)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            // 詳細を見るボタン - 右下に表示する
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:[detailButton(labelWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:[detailButton(labelHeight)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            self.layoutConstraints = layoutConstraints
        }
        
        dacsdkmaActivateConstraints(self.layoutConstraints, view: self)
    }
    
    override public var playbackStatus: DACSDKMAAdVideoPlaybackStates {
        willSet(newValue) {
            dispatch_async(dispatch_get_main_queue()) {
                switch newValue {
                case DACSDKMAAdVideoPlaybackStates.Stopped:
                    // 停止中は音量ボタンを表示しない。（リプレイボタンと重なるため。）
                    self.volumeButton.hidden = true
                    break
                default:
                    self.volumeButton.hidden = false
                    break
                }
            }
        }
    }
}


// --------------------------------------------------
// MARK: - class
// --------------------------------------------------
/// 動画広告コントローラー・フルスクリーン用
@objc
public class DACSDKMASmartVisionAdPlayerControlsViewForFullscreen: DACSDKMAAdVideoControlsView {
    
    // --------------------------------------------------
    // MARK: life cycle
    // --------------------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(self.volumeButton)
        self.addSubview(self.playButton)
        self.addSubview(self.replayButton)
        self.addSubview(self.exitFullscreenButton)
        self.addSubview(self.detailButton)
        
        self.addSubview(self.durationLabel)
        self.addSubview(self.progressTimeLabel)
        self.addSubview(self.progressView)
        
        self.replayButton.hidden = true
        
        // リプレイボタンのみ基底クラスで指定した画像から変更。
        self.replayButton.setImage(DACSDKMAAdImageGenerator.playButtonIconImage, forState: UIControlState.Normal)
    }
    
    
    // --------------------------------------------------
    // MARK: override methods
    // --------------------------------------------------
    
    override public func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        if nil == newSuperview {
            dacsdkmaDeactivateConstraints(self.layoutConstraints, view: self)
            return
        }
        
        // AutoLayout設定
        if self.layoutConstraints.isEmpty {
            var layoutConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
            
            // 音量ボタン - 左上に表示する
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[volumeButton(iconWidth)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-margin-[volumeButton(iconHeight)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            // Closeボタン - 右上に表示する
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:[exitFullscreenButton(exitFullscreenLabelWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-margin-[exitFullscreenButton(exitFullscreenLabelHeight)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            // 再生・一時停止ボタン - 左下に表示する(停止中は表示されない)
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[playButton(iconWidth)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:[playButton(iconHeight)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            // リプレイボタン - 左下に表示する(停止中のみ表示される)
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[replayButton(iconWidth)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:[replayButton(iconHeight)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            // プログレスビューなど
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:[playButton]-margin-[progressTimeLabel(50)]-margin-[progressView(>=0)]-margin-[durationLabel(50)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:[durationLabel(labelHeight)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:[progressTimeLabel(labelHeight)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:[progressView(5)]-15-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            // 詳細を見るボタン - 右下に表示する
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:[detailButton(labelWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:[detailButton(labelHeight)]-margin-[playButton]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            self.layoutConstraints = layoutConstraints
        }
        
        dacsdkmaActivateConstraints(self.layoutConstraints, view: self)
    }
    
}

// --------------------------------------------------
// MARK: - class
// --------------------------------------------------
/// 止め画像用コントローラー
@objc
public class DACSDKMACompanionAtStopControlsView: DACSDKMAAdVideoControlsView {
    
    // --------------------------------------------------
    // MARK: life cycle
    // --------------------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.replayButton)
        self.addSubview(self.closeButton)
        self.addSubview(self.detailButton)
    }
    
    
    // --------------------------------------------------
    // MARK: override methods
    // --------------------------------------------------
    
    override public func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        
        if nil == newSuperview {
            dacsdkmaDeactivateConstraints(self.layoutConstraints, view: self)
            return
        }
        
        // AutoLayout設定
        if self.layoutConstraints.isEmpty {
            var layoutConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
            
            // リプレイボタン - 左上に表示する(停止中のみ表示される)
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[replayButton(labelWidth)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-margin-[replayButton(labelHeight)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            // Xボタン - 右上に表示する
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:[closeButton(iconWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-margin-[closeButton(iconHeight)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            // 詳細を見るボタン - 右下に表示する
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:[detailButton(labelWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:[detailButton(labelHeight)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            self.layoutConstraints = layoutConstraints
        }
        
        dacsdkmaActivateConstraints(self.layoutConstraints, view: self)
    }
    
    /// 重なっているViewにタッチイベントを通知する。
    override public func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let hitView: UIView? = super.hitTest(point, withEvent: event)
        return (hitView == self ? nil : hitView)
    }
    
}
