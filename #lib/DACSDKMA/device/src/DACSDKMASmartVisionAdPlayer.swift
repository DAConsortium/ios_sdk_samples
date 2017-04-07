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
    @objc optional func dacsdkmaSmartVisionAdPlayer(_ smartVisionAdPlayer: DACSDKMASmartVisionAdPlayer, didReceiveAdEvent adEvent: DACSDKMAAdEvent)
    
    /**
     動画の読み込みに失敗、再生中にエラーが発生した際に呼ばれます。
     - parameter smartVisionAdPlayer: エラーが発生したビュー
     - parameter adError: 発生したエラー
     */
    @objc optional func dacsdkmaSmartVisionAdPlayer(_ smartVisionAdPlayer: DACSDKMASmartVisionAdPlayer, didReceiveAdError adError: DACSDKMAAdError)
    
    /**
     リマインダ・バナーが表示された際に呼ばれます。
     - parameter smartVisionAdPlayer: リマインダ・バナーが表示されたビュー
     - parameter view: リマインダ・バナー・ビュー
     */
    @objc optional func dacsdkmaSmartVisionAdPlayer(_ smartVisionAdPlayer: DACSDKMASmartVisionAdPlayer, didShowReminder view: UIView)
}



// --------------------------------------------------
// MARK: - class
// --------------------------------------------------
/// 動画広告プレイヤークラス
@objc
open class DACSDKMASmartVisionAdPlayer: UIView, DACSDKMAAdsLoaderDelegate, DACSDKMAAdsManagerDelegate, DACSDKMAAdControlsViewDelegate {
    
    private static var KVOContext = 0
    
    // --------------------------------------------------
    // MARK: static property
    // --------------------------------------------------
    
    /// コンパニオン画像の倍率(width, heightを等倍以上で返してくる場合に調整する。)
    open static let companionImageScale: CGFloat = 1.0
    
    /// 止め画像のサイズ
    open static let stopCompanionHorizontalSize: CGSize = CGSize(width: 320, height: 180)
    open static let stopCompanionVerticalSize: CGSize = CGSize(width: 360, height: 640)

    /// 動画下部バナーのサイズ
    open static let bottomCompanionSize: CGSize = CGSize(width: 300, height: 82)
    
    /// リマインダ・バナー・サイズ
    open static let reminderCompanionSize: CGSize = CGSize(width: 320, height: 50)

    // --------------------------------------------------
    // MARK: property (configuration)
    // --------------------------------------------------
    /// 動画広告の読み込み後、自動的に再生を開始する場合はtrueにします。falseにした場合、resume()を呼び出すことで開始することが可能です。
    open var autoStart: Bool = true
    
    /// インビューと判定される割合(%)。(0〜100)
    open var inviewPercentage: Int = 50
    
    /// ヘッダーで利用する画像のURIパス
    open var headerImgSrc: String? = nil

    /// インタースティシャルでの表示を行う場合はtrueにします。そうでない場合、インラインで表示されます。
    open var interstitial: Bool = false
    
    /// インタースティシャル表示時の動画広告の表示サイズ割合(%)。(0〜100)
    open var dataAutofit: Int = 75
    
    /// 再生完了後自動クローズする秒数(ms)を設定。 0の場合、自動で閉じない。
    open var videoCloseTime: Int = 2000
    
    /// エラー時や、動画枠を閉じた時などにこのViewを自動的に非表示にするか否か。
    open var autoRemoveFromSuperView: Bool = true
    
    // --------------------------------------------------
    // MARK: property
    // --------------------------------------------------
    /// デリゲート
    open weak var delegate: DACSDKMASmartVisionAdPlayerDelegate? = nil
    
    /// (readonly)
    open private(set) var adsLoader: DACSDKMAAdsLoader? = nil
    
    /// (readonly)
    open private(set) var adsManager: DACSDKMAAdsManager? = nil {
        willSet { self.unregisterObserver() }
        didSet { self.registerObserver() }
    }

    // --------------------------------------------------
    // MARK: private property
    // --------------------------------------------------
    // ----- 動画広告枠 -----
    /// AutoLayout設定
    private var layoutConstraints: [NSLayoutConstraint] = []

    /// 動画広告コンテナ
    private var adContainer: DACSDKMAAdContainer? = nil
    
    /// 動画広告コントローラー
    private var videoAdControlsView: DACSDKMAAdControlsView? = nil
    
    /// 動画ヘッダー
    private var videoHeaderView: UIImageView = UIImageView()

    // ----- 止め画像 -----
    /// 止め画像コントローラー
    private var stopCompanionControlsView: DACSDKMASmartVisionAdStopCompanionControlsView = DACSDKMASmartVisionAdStopCompanionControlsView()

    /// 止め画像スロット
    private var stopCompanionSlot: DACSDKMACompanionSlot? = nil
    
    // ----- 動画下部バナー -----
    /// 動画下部バナービュー
    private var bottomCompanionView: UIView = UIView()
    
    /// 動画下部バナースロット
    private var bottomCompanionSlot: DACSDKMACompanionSlot? = nil
    
    /// AutoLayout時の動画下部バナー左側スペーサー
    private var spacerLeft = UIView()
    
    /// AutoLayout時の動画下部バナー右側スペーサー
    private var spacerRight = UIView()
    
    // ----- リマインダバナー -----
    /// リマインダバナー・ビュー
    private var reminderCompanionView: DACSDKMASmartVisionAdReminderCompanionView = DACSDKMASmartVisionAdReminderCompanionView()
    
    /// リマインダバナー・スロット
    private var reminderCompanionSlot: DACSDKMACompanionSlot? = nil
    
    // ----- 1by1, 2by2 -----
    /// 1by1コンパニオン
    private var oneByOneCompanionSlot: DACSDKMACompanionSlot? = nil
    
    /// 2by2コンパニオン
    private var twoByTwoCompanionSlot: DACSDKMACompanionSlot? = nil

    // ----- KVO -----
    private var isRegisteredObserver: Bool = false

    // ----- その他 -----
    /// 自動クローズ・タイマー
    private var videoCloseTimer: DACSDKMAUtilTimer? = nil
    
    /// 変更前のアドビュー・モード
    private var previousAdViewMode: DACSDKMAAdViewMode = .normal
    
    // --------------------------------------------------
    // MARK: life cycle
    // --------------------------------------------------
    deinit {
        self.delegate = nil
        self.clean()
    }
    
    // --------------------------------------------------
    // MARK: function
    // --------------------------------------------------
    /**
     動画広告の読み込みを開始します。
     - parameter adTagURI: 指定されたURIを設定します。
     */
    open func load(_ adTagURI: String) {
        if nil != self.adsLoader {
            // すでにロード済みの場合、何もしない。
            return
        }
        
        // ----- Setting  -----
        let settings: DACSDKMASettings = DACSDKMASettings()
        settings.adViewMode = self.interstitial ? DACSDKMAAdViewMode.interstitial : DACSDKMAAdViewMode.normal
        settings.isAutoStart = self.autoStart
        settings.isAutoAdHidden = false
        settings.isAutoAdvanceToNextAdBreak = false
        settings.isAutoRemoveCompanion = false
        settings.playableRatio = DACSDKMACGRatio(x: 0.01, y: CGFloat(self.inviewPercentage) / 100.0)
        settings.adSpotViewRatioInInterstitialMode = DACSDKMACGRatio(x: CGFloat(self.dataAutofit) / 100.0, y: CGFloat(self.dataAutofit) / 100.0)
        
        // ----- RequestAds -----
        let adsLoader: DACSDKMAAdsLoader = DACSDKMAAdsLoader(settings: settings)
        adsLoader.delegate = self
        
        self.setup() {
            if let adContainer = self.adContainer {
                let adsRequest: DACSDKMAAdsRequest = DACSDKMAAdsRequest(adTagURI: adTagURI, adContainer: adContainer)
                adsLoader.requestAds(adsRequest)
                self.adsLoader = adsLoader
            }
        }
    }
    
    /**
     動画広告の再生を開始します。読み込みが完了していない場合、完了後に再生を開始します。
     */
    open func resume() {
        self.adsManager?.play()
    }
    
    /**
     動画広告の再生を一時停止します。
     */
    open func pause() {
        self.adsManager?.pause()
    }
    
    /**
     このビューを閉じます。リマインダ・バナーがあれば、それを表示します。ない場合、clean()処理を行います。
     */
    open func close() {
        if nil == self.reminderCompanionSlot?.companion {
            // リマインダーが無い場合は、解放処理を行います。
            self.adsManager?.close()
        }
        else if nil == self.superview && nil == self.window {
            // すでに親ビューから削除されている場合は、解放処理を行います。
            self.adsManager?.close()
        }
        else {
            self.toMinimized()
        }
    }
    
    /**
     このビューを閉じ、動画広告の再生に使用したインスタンスなどを解放します。
     */
    open func clean() {
        // AdsLoaderを解放する。
        self.adsLoader?.delegate = nil
        self.adsLoader = nil
        
        // AdsManagerを解放する。
        self.unregisterObserver()
        self.adsManager?.delegate = nil
        self.adsManager?.clean()
        self.adsManager = nil
        
        // AutoLayoutの解放
        if !self.layoutConstraints.isEmpty {
            NSLayoutConstraint.deactivate(self.layoutConstraints)
            self.layoutConstraints = []
        }
        
        // ビューコントローラーを破棄する
        self.videoAdControlsView?.clean()
        self.videoAdControlsView = nil
        
        // 止め画像を破棄する
        self.stopCompanionControlsView.clean()
        
        // リマインダ・バナーを破棄する
        self.reminderCompanionView.clean()

        // ヘッダーを削除する
        self.videoHeaderView.removeFromSuperview()
        
        // 下部バナーを破棄する
        self.bottomCompanionView.removeFromSuperview()
        self.bottomCompanionSlot?.slot?.removeFromSuperview()
        self.bottomCompanionSlot?.companion?.removeFromSuperview()
        self.spacerLeft.removeFromSuperview()
        self.spacerRight.removeFromSuperview()
        
        // 1by1を削除する。
        self.oneByOneCompanionSlot?.slot?.removeFromSuperview()
        self.oneByOneCompanionSlot?.companion?.removeFromSuperview()
        
        // 2by2を削除する。
        self.twoByTwoCompanionSlot?.slot?.removeFromSuperview()
        self.twoByTwoCompanionSlot?.companion?.removeFromSuperview()
        
        // 動画プレイヤー・コンテナを解放する。
        self.adContainer = nil
        
        // 自身を削除する。
        if self.autoRemoveFromSuperView {
            self.isHidden = true
            self.removeFromSuperview()
        }
    }
    
    // --------------------------------------------------
    // MARK: private fnction
    // --------------------------------------------------
    /**
    使用するための準備をする。
    */
    private func setup(_ completion: (() -> Void)? = nil) {
        // ----- コンパニオン枠設定 -----
        var companionSlots: [DACSDKMACompanionSlot] = [DACSDKMACompanionSlot]()
        
        // 1by1を除外するフィルター
        let oneByOneFilter: (_ size: CGSize) -> Bool = { (size: CGSize) in
            return (1 == size.width && 1 == size.height) ? true : false
        }
        
        // 2by2を除外するフィルター
        let twoByTwoFilter: (_ size: CGSize) -> Bool = { (size: CGSize) in
            return (2 == size.width && 2 == size.height) ? true : false
        }
        
        // 止め画像サイズ、フィルター: 縦型か横型で分ける
        let stopCompanionSize: CGSize
        let stopCompanionFilter: (_ size: CGSize) -> Bool
        if self.frame.width < self.frame.height {
            // 縦長
            stopCompanionSize = CGSize(
                width: type(of: self).stopCompanionVerticalSize.width * type(of: self).companionImageScale,
                height: type(of: self).stopCompanionVerticalSize.height * type(of: self).companionImageScale)
            
            // (幅 9: 高さ 16)のアスペクト比に近くないものは除外する。
            stopCompanionFilter = { (size: CGSize) in
                let ratio: CGFloat = (size.width / size.height)
                return (ratio <= 0.5) || (0.625 <= ratio)
            }
        }
        else {
            // 横長
            stopCompanionSize = CGSize(
                width: type(of: self).stopCompanionHorizontalSize.width * type(of: self).companionImageScale,
                height: type(of: self).stopCompanionHorizontalSize.height * type(of: self).companionImageScale)
            
            // (幅 16: 高さ 9)のアスペクト比に近くないものは除外する。
            stopCompanionFilter = { (size: CGSize) in
                let ratio: CGFloat = (size.width / size.height)
                return (ratio <= 1.60) || (2.0 <= ratio)
            }
        }
        
        // 止め画像
        self.stopCompanionControlsView.delegate = self

        let stopcompanionFilters: [DACSDKMACompanionSlot.ExcludeFilter] = [oneByOneFilter, twoByTwoFilter, stopCompanionFilter]
        let stopCompanionSlot: DACSDKMACompanionSlot = DACSDKMACompanionSlot(
            slot: self.stopCompanionControlsView,
            size: stopCompanionSize,
            excludeFilters: stopcompanionFilters)
        self.stopCompanionSlot = stopCompanionSlot
        companionSlots.append(stopCompanionSlot)
        
        // 動画下部バナー
        self.bottomCompanionView.backgroundColor = UIColor.black
        
        let bottomCompanionSize: CGSize = CGSize(
            width: type(of: self).bottomCompanionSize.width * type(of: self).companionImageScale,
            height: type(of: self).bottomCompanionSize.height * type(of: self).companionImageScale)
        let bottomCompanionSlotFilters: [DACSDKMACompanionSlot.ExcludeFilter] = [oneByOneFilter, twoByTwoFilter, { (size: CGSize) in
            // 幅 300px: 高さ 82pxのアスペクト比に近くないものは除外する。
            let ratio: CGFloat = (size.width / size.height)
            return (ratio <= 3.0) || (4.0 <= ratio)
            }]
        let companionSlotAtBottom: DACSDKMACompanionSlot = DACSDKMACompanionSlot(
            slot: self.bottomCompanionView,
            size: bottomCompanionSize,
            excludeFilters: bottomCompanionSlotFilters)
        self.bottomCompanionSlot = companionSlotAtBottom
        companionSlots.append(companionSlotAtBottom)
        
        // スペーサー
        self.spacerLeft.backgroundColor = UIColor.black
        self.spacerRight.backgroundColor = UIColor.black
        
        // 1by1
        let oneByOneCompanionView: UIView = UIView(frame: CGRect.zero)
        oneByOneCompanionView.isHidden = true
        self.addSubview(oneByOneCompanionView)
        let oneByOneCompanionSlotFilters: [DACSDKMACompanionSlot.ExcludeFilter] = [ { (size: CGSize) in
            // 1by1以外を除外する
            return !oneByOneFilter(size)
            } ]
        let oneByOneCompanionSlot: DACSDKMACompanionSlot  = DACSDKMACompanionSlot(slot: oneByOneCompanionView, size: CGSize(width: 1, height: 1), excludeFilters: oneByOneCompanionSlotFilters)
        self.oneByOneCompanionSlot = oneByOneCompanionSlot
        companionSlots.append(oneByOneCompanionSlot)
        
        // 2by2
        let twoByTwoCompanionView: UIView = UIView(frame: CGRect.zero)
        twoByTwoCompanionView.isHidden = true
        self.addSubview(twoByTwoCompanionView)
        let twoByTwoCompanionSlotFilters: [DACSDKMACompanionSlot.ExcludeFilter] = [ { (size: CGSize) in
            // 2by2以外を除外する
            return !twoByTwoFilter(size)
            } ]
        let twoByTwoCompanionSlot: DACSDKMACompanionSlot  = DACSDKMACompanionSlot(slot: twoByTwoCompanionView, size: CGSize(width: 2, height: 2), excludeFilters: twoByTwoCompanionSlotFilters)
        self.twoByTwoCompanionSlot = twoByTwoCompanionSlot
        companionSlots.append(twoByTwoCompanionSlot)
        
        /// リマインダ・バナー
        self.reminderCompanionView.delegate = self
        
        let reminderCompanionSize: CGSize = CGSize(
            width: type(of: self).reminderCompanionSize.width * type(of: self).companionImageScale,
            height: type(of: self).reminderCompanionSize.height * type(of: self).companionImageScale)
        let reminderCompanionSlotFilters: [DACSDKMACompanionSlot.ExcludeFilter] = [oneByOneFilter, twoByTwoFilter, { (size: CGSize) in
                // バナー・サイズ以外を除外する
                return (size == type(of: self).reminderCompanionSize) ? false : true
            }]
        let reminderCompanionSlot: DACSDKMACompanionSlot = DACSDKMACompanionSlot(
            slot: self.reminderCompanionView,
            size: reminderCompanionSize,
            excludeFilters: reminderCompanionSlotFilters)
        self.reminderCompanionSlot = reminderCompanionSlot
        companionSlots.append(reminderCompanionSlot)

        // 動画広告コンテナの生成・保持
        self.adContainer = DACSDKMAAdContainer(view: self, companionSlots: companionSlots)
        
        // ヘッダー画像: 生成に時間がかかるので非同期にする
        DispatchQueue.main.async {
            defer {
                completion?()
            }

            guard let headerImgUri: String = self.headerImgSrc else { return }
            guard let headerImgUrl: URL = URL(string: headerImgUri) else { return }
            guard let headerImgData: Data = try? Data(contentsOf: headerImgUrl, options: NSData.ReadingOptions.mappedIfSafe) else { return }
            guard let headerImg: UIImage = UIImage(data: headerImgData) else { return }
            let headerImgView: UIImageView = UIImageView(image: headerImg)
            headerImgView.contentMode = UIViewContentMode.scaleToFill // これ以外に設定した場合、Autolayoutが想定通りに動作しない
            headerImgView.translatesAutoresizingMaskIntoConstraints = false
            self.videoHeaderView = headerImgView
        }
    }

    /**
     必要に応じて、動画広告を停止する。
     - Returns: 停止した場合、true。停止しない場合、false。
     */
    @discardableResult
    private func stopIfNeeded() -> Bool {
        guard let adsManager = self.adsManager else { return false }
        var result: Bool = false
        
        defer {
            if result {
                adsManager.stop()
                self.videoAdControlsView?.playbackStatus = DACSDKMAAdVideoPlaybackStates.stopped
            }
        }
        
        // インタースティシャル時は、停止しない。
        if DACSDKMAAdViewMode.interstitial == self.adsManager?.adViewMode { result = false ; return result }
        
        // 止め画像が無い場合、停止しない。以降の処理は行わない。
        if nil == self.stopCompanionSlot?.companion { result = false ; return result }
        
        // 完全に画面外になった場合、停止する。
        if DACSDKMAInViewStates.excluded == adsManager.playableStatus.inViewStatus { result = true ; return result }
        
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
        // 止め画像を非表示
        self.stopCompanionControlsView.isHidden = true
        
        // 動画広告コントローラーを表示
        self.videoAdControlsView?.isHidden = false
        
        // 動画広告を表示
        self.adsManager?.adVideoView?.isHidden = false
    }
    
    /**
     止め画像を表示する。
     */
    private func showCompanionAtStop() {
        // インライン時以外は、何もしない。以降の処理は行わない。
        if DACSDKMAAdViewMode.normal != self.adsManager?.adViewMode { return }
        
        // コンパニオンが無ければ、何もしない。以降の処理は行わない。
        if nil == self.stopCompanionSlot?.companion { return }

        // コンパニオンが表示中の場合、何もしない。以降の処理は行わない。
        if !(self.stopCompanionControlsView.isHidden) { return }

        // 止め画像を表示
        self.stopCompanionControlsView.isHidden = false

        // 動画広告コントローラーを非表示
        self.videoAdControlsView?.isHidden = true
        
        // 動画広告を非表示
        self.adsManager?.adVideoView?.isHidden = true
        
        // 止め画像表示中は動画は停止
        self.adsManager?.stop()
    }
    
    /**
     インライン化する
     */
    private func toInline(_ areAnimationsEnabled: Bool = true, completion: (() -> Swift.Void)? = nil) {
        // アドビュー・モードを変更する
        self.previousAdViewMode = DACSDKMAAdViewMode.normal
        
        // 表示済みの場合、以降の処理は行わない。
        if nil != self.videoAdControlsView as? DACSDKMASmartVisionAdInlineControlsView {
            completion?()
            return
        }

        self.removeAdSubviews()

        guard let adsManager: DACSDKMAAdsManager = self.adsManager else { return }
        guard let adSpotView: UIView = adsManager.adSpotView else { return }
        guard let adVideoView: UIView = adsManager.adVideoView else { return }
        
        // 動画広告コントローラを生成する
        let adControlsView: DACSDKMASmartVisionAdInlineControlsView = DACSDKMASmartVisionAdInlineControlsView()
        self.videoAdControlsView = adControlsView
        
        // インライン化する
        adsManager.changeAdViewMode(DACSDKMAAdViewMode.normal, areAnimationsEnabled: areAnimationsEnabled) { [weak self] (result: Bool) in
            guard let this = self else { return }
            guard result else {
                this.removeAdSubviews()
                return
            }

            adControlsView.frame = adSpotView.bounds
            adControlsView.isMute = adsManager.isMute
            adControlsView.playbackStatus = adsManager.playbackStatus
            adControlsView.delegate = self
            
            if nil == this.oneByOneCompanionSlot?.companion {
                adControlsView.enterFullscreenButton.isHidden = false
                adControlsView.linkButton.isHidden = true
            }
            else {
                adControlsView.enterFullscreenButton.isHidden = true
                adControlsView.linkButton.isHidden = false
            }
            
            // 必要なビューの追加
            adSpotView.addSubview(this.videoHeaderView)
            adSpotView.addSubview(adControlsView)
            adSpotView.addSubview(this.stopCompanionControlsView)
            adSpotView.addSubview(this.bottomCompanionView)
            adSpotView.addSubview(this.spacerLeft)
            adSpotView.addSubview(this.spacerRight)
            
            // 動画広告を表示・下部バナーを表示
            adVideoView.isHidden = false
            this.bottomCompanionView.isHidden = false

            // 止め画像を非表示
            this.stopCompanionControlsView.isHidden = true
            
            // ----- AutoLayout -----
            // AutoLayout 有効
            adVideoView.translatesAutoresizingMaskIntoConstraints = false
            adControlsView.translatesAutoresizingMaskIntoConstraints = false
            this.stopCompanionControlsView.translatesAutoresizingMaskIntoConstraints = false
            this.bottomCompanionView.translatesAutoresizingMaskIntoConstraints = false
            this.spacerLeft.translatesAutoresizingMaskIntoConstraints = false
            this.spacerRight.translatesAutoresizingMaskIntoConstraints = false

            // AutoLayout 解除
            NSLayoutConstraint.deactivate(this.layoutConstraints)
            this.layoutConstraints = []
            
            // 動画枠の下にコンパニオンを表示する。コンパニオンは中央横に配置する。コンパニオンの大きさは固定。
            let views: [String: UIView] = [
                "videoControls" : adControlsView,
                "stopControls"  : this.stopCompanionControlsView,
                "video"         : adVideoView,
                "header"        : this.videoHeaderView,
                "bottom"        : this.bottomCompanionView,
                "sl"            : this.spacerLeft,
                "sr"            : this.spacerRight
            ]
            
            let metrics: [String : Any] = [
                "bottomWidth": this.bottomCompanionSlot?.companionSize.width ?? 0
            ]
            
            var layoutConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
            // 動画コントローラーは広告枠と同じ横幅にする。
            layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[videoControls]|", options: [], metrics: nil, views: views)
            )
            // 止め画像コントローラーは広告枠と同じ横幅にする。
            layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[stopControls]|", options: [], metrics: nil, views: views)
            )
            // ヘッダー画像は広告枠と同じ横幅にする。
            layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[header]|", options: [], metrics: nil, views: views)
            )
            // 動画プレイヤーは広告枠と同じ横幅にする。
            layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[video]|", options: [], metrics: nil, views: views)
            )
            // 下部バナーは横中央に配置する。基本的に設定した下部バナー枠の幅とするが、動画広告枠の幅までを最大とする。
            layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[sl(>=0@250)]-(<=0)-[bottom(<=video@750,bottomWidth@500)]-(<=0)-[sr(sl)]|", options: [], metrics: metrics, views: views)
            )
            
            // 動画コントローラーは広告枠から下部バナーの高さを除いた大きさにする。下部バナーの高さの制約は別途設定する。
            layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[videoControls][bottom]|", options: [], metrics: metrics, views: views)
            )
            // 止め画像コントローラーの高さは広告枠から下部バナーの高さを除いた大きさにする。
            layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[stopControls][bottom]|", options: [], metrics: nil, views: views)
            )
            // 動画広告プレイヤーの高さはヘッダーと下部バナーの高さを除いた大きさにする。
            layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[header][video][bottom]|", options: [], metrics: metrics, views: views)
            )
            layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "V:[sl(bottom)]|", options: [], metrics: nil, views: views)
            )
            layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "V:[sr(bottom)]|", options: [], metrics: nil, views: views)
            )
            
            let bottomCompanionWidth: CGFloat = this.bottomCompanionSlot?.size.width ?? 0
            let bottomCompanionHeight: CGFloat = this.bottomCompanionSlot?.size.height ?? 0
            if 0 < bottomCompanionWidth || 0 < bottomCompanionHeight {
                // 下部バナーのアスペクト比を一定にするため、高さを横幅の変化の割合から求める。
                layoutConstraints.append(
                    NSLayoutConstraint(
                        item: this.bottomCompanionView, attribute: NSLayoutAttribute.height,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: this.bottomCompanionView, attribute: NSLayoutAttribute.width,
                        multiplier: bottomCompanionHeight / bottomCompanionWidth, constant: 1.0)
                )
            }
            else {
                // 下部バナーがない場合、高さを0にする。
                layoutConstraints.append(
                    NSLayoutConstraint(
                        item: this.bottomCompanionView, attribute: NSLayoutAttribute.height,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: nil, attribute: NSLayoutAttribute.height,
                        multiplier: 1.0, constant: 0.0)
                )
                
            }
            
            if let headerImageWidth: CGFloat = this.videoHeaderView.image?.size.width,
                let headerImageHeight: CGFloat = this.videoHeaderView.image?.size.height {
                // ヘッダーのアスペクト比を一定にするため、高さを横幅の変化の割合から求める。
                layoutConstraints.append(
                    NSLayoutConstraint(
                        item: this.videoHeaderView, attribute: NSLayoutAttribute.height,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: this.videoHeaderView, attribute: NSLayoutAttribute.width,
                        multiplier: headerImageHeight / headerImageWidth, constant: 1.0)
                )
            }
            else {
                // ヘッダーがない場合、高さを0にする。
                layoutConstraints.append(
                    NSLayoutConstraint(
                        item: this.videoHeaderView, attribute: NSLayoutAttribute.height,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: nil, attribute: NSLayoutAttribute.height,
                        multiplier: 1.0, constant: 0.0)
                )
                
            }
            
            this.layoutConstraints = layoutConstraints
            NSLayoutConstraint.activate(this.layoutConstraints)
            
            // レイアウトの更新を行う。
            this.layoutIfNeeded()
            
            this.convertVideoRect()
            
            completion?()
        }
    }
    
    /**
     フルスクリーン化する
     */
    private func toFullscreen(_ areAnimationsEnabled: Bool = true, completion: (() -> Swift.Void)? = nil) {
        // 表示済みの場合、以降の処理は行わない。
        if nil != self.videoAdControlsView as? DACSDKMASmartVisionAdFullscreenControlsView {
            completion?()
            return
        }
        
        self.removeAdSubviews()
        
        guard let adsManager: DACSDKMAAdsManager = self.adsManager else { return }
        guard let adSpotView: UIView = adsManager.adSpotView else { return }
        guard let adVideoView: UIView = adsManager.adVideoView else { return }
        
        // フルスクリーン・コントロール・ビューの生成
        let adControlsView: DACSDKMASmartVisionAdFullscreenControlsView = DACSDKMASmartVisionAdFullscreenControlsView()
        self.videoAdControlsView = adControlsView
        
        // フルスクリーン化する
        adsManager.changeAdViewMode(DACSDKMAAdViewMode.maximized, areAnimationsEnabled: areAnimationsEnabled) { [weak self] (result: Bool) in
            guard let this = self else { return }
            guard result else {
                this.removeAdSubviews()
                return
            }
            
            adControlsView.frame = adSpotView.bounds
            adControlsView.isMute = adsManager.isMute
            adControlsView.playbackStatus = adsManager.playbackStatus
            adControlsView.durationLabel.text = String(format: "%2d:%.2d", Int(adsManager.durationTime / 60), Int(adsManager.durationTime.truncatingRemainder(dividingBy: 60)))
            adControlsView.delegate = self
            
            // 必要なビューの追加
            adSpotView.addSubview(this.videoHeaderView)
            adSpotView.addSubview(adControlsView)

            // ----- AutoLayout -----
            // AutoLayout 有効
            adVideoView.translatesAutoresizingMaskIntoConstraints = false

            // AutoLayout 解除
            NSLayoutConstraint.deactivate(this.layoutConstraints)
            this.layoutConstraints = []
            
            var layoutConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
            let views: [String: UIView] = [
                "header": this.videoHeaderView,
                "video": adVideoView,
                ]
            layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[header]|", options: [], metrics: nil, views: views)
            )
            layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[video]|", options: [], metrics: nil, views: views)
            )
            layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[header]-(<=0)-[video]|", options: [], metrics: nil, views: views)
            )
            
            if let headerImageWidth: CGFloat = this.videoHeaderView.image?.size.width,
                let headerImageHeight: CGFloat = this.videoHeaderView.image?.size.height {
                layoutConstraints.append(
                    NSLayoutConstraint(
                        item: this.videoHeaderView, attribute: NSLayoutAttribute.height,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: this.videoHeaderView, attribute: NSLayoutAttribute.width,
                        multiplier: headerImageHeight / headerImageWidth, constant: 1.0)
                )
            }
            else {
                // ヘッダーがない場合、高さを0にする。
                layoutConstraints.append(
                    NSLayoutConstraint(
                        item: this.videoHeaderView, attribute: NSLayoutAttribute.height,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: nil, attribute: NSLayoutAttribute.height,
                        multiplier: 1.0, constant: 0.0)
                )
                
            }

            this.layoutConstraints = layoutConstraints
            NSLayoutConstraint.activate(this.layoutConstraints)
            
            // レイアウトの更新を行う。
            adSpotView.layoutIfNeeded()

            this.convertVideoRect()
            
            completion?()
        }
    }
    
    /**
     インタースティシャル化する
     */
    private func toInterstitial(_ areAnimationsEnabled: Bool = true, completion: (() -> Swift.Void)? = nil) {
        // 表示済みの場合、以降の処理は行わない。
        if nil != self.videoAdControlsView as? DACSDKMASmartVisionAdInterstitialControlsView {
            completion?()
            return
        }
        
        self.removeAdSubviews()
        
        guard let adsManager: DACSDKMAAdsManager = self.adsManager else { return }
        guard let adSpotView: UIView = adsManager.adSpotView else { return }
        guard let adVideoView: UIView = adsManager.adVideoView else { return }

        // インタースティシャル・コントロール・ビューの生成
        let adControlsView: DACSDKMASmartVisionAdInterstitialControlsView = DACSDKMASmartVisionAdInterstitialControlsView()
        self.videoAdControlsView = adControlsView
        
        // インタースティシャル化する
        self.adsManager?.changeAdViewMode(DACSDKMAAdViewMode.interstitial, areAnimationsEnabled: areAnimationsEnabled) { [weak self] (result: Bool) in
            guard let this = self else { return }
            guard result else {
                this.removeAdSubviews()
                return
            }

            adControlsView.frame = adSpotView.bounds
            adControlsView.isMute = adsManager.isMute
            adControlsView.playbackStatus = adsManager.playbackStatus
            adControlsView.delegate = this
            
            // 必要なビューの追加
            adSpotView.addSubview(this.videoHeaderView)
            adSpotView.addSubview(adControlsView)
            
            // ----- AutoLayout -----
            // AutoLayout 有効
            adVideoView.translatesAutoresizingMaskIntoConstraints = false
            
            // AutoLayout 解除
            NSLayoutConstraint.deactivate(this.layoutConstraints)
            this.layoutConstraints = []
            
            let views: [String: UIView] = [
                "header": this.videoHeaderView,
                "video": adVideoView,
                ]
            
            var layoutConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
            layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[header]|", options: [], metrics: nil, views: views)
            )
            layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[video]|", options: [], metrics: nil, views: views)
            )
            layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[header]-(<=0)-[video]|", options: [], metrics: nil, views: views)
            )
            
            if let headerImageWidth: CGFloat = this.videoHeaderView.image?.size.width,
                let headerImageHeight: CGFloat = this.videoHeaderView.image?.size.height {
                layoutConstraints.append(
                    NSLayoutConstraint(
                        item: this.videoHeaderView, attribute: NSLayoutAttribute.height,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: this.videoHeaderView, attribute: NSLayoutAttribute.width,
                        multiplier: headerImageHeight / headerImageWidth, constant: 1.0)
                )
            }
            else {
                // ヘッダーがない場合、高さを0にする。
                layoutConstraints.append(
                    NSLayoutConstraint(
                        item: this.videoHeaderView, attribute: NSLayoutAttribute.height,
                        relatedBy: NSLayoutRelation.equal,
                        toItem: nil, attribute: NSLayoutAttribute.height,
                        multiplier: 1.0, constant: 0.0)
                )
                
            }
            
            this.layoutConstraints = layoutConstraints
            NSLayoutConstraint.activate(this.layoutConstraints)
            
            // レイアウトの更新を行う。
            adSpotView.layoutIfNeeded()
            
            this.convertVideoRect()
            
            completion?()
        }
    }
    
    /**
     動画広告の子ビューを削除する
     */
    private func removeAdSubviews() {
        // AutoLayout解除
        if !self.layoutConstraints.isEmpty {
            NSLayoutConstraint.deactivate(self.layoutConstraints)
            self.layoutConstraints = []
        }

        // 動画広告コントローラーついては、都度破棄する
        self.videoAdControlsView?.clean()
        self.videoAdControlsView = nil
        
        // ヘッダー
        self.videoHeaderView.removeFromSuperview()
        
        // 止め画像
        self.stopCompanionControlsView.removeFromSuperview()
        
        // 下部バナー
        self.bottomCompanionView.removeFromSuperview()
        self.spacerLeft.removeFromSuperview()
        self.spacerRight.removeFromSuperview()

        // リマインダ・バナー・ビュー
        self.reminderCompanionView.isHidden = true
        self.reminderCompanionView.removeFromSuperview()
    }
    
    private func toMinimized(_ areAnimationsEnabled: Bool = true, completion: (() -> Swift.Void)? = nil) {
        // リマインダが表示中の場合、以降の処理は行わない。
        if nil != self.reminderCompanionView.superview {
            completion?()
            return
        }
        
        // アドビュー・モードを変更する
        self.previousAdViewMode = DACSDKMAAdViewMode.minimized

        self.removeAdSubviews()
        
        // リマインダーを追加する。
        self.addSubview(self.reminderCompanionView)
        
        // 最小化する
        self.adsManager?.changeAdViewMode(DACSDKMAAdViewMode.minimized, areAnimationsEnabled: areAnimationsEnabled) { [weak self] (result: Bool) in
            guard let this = self else { return }
            if result {
                // リマインダーを表示する。
                this.reminderCompanionView.isHidden = false
                
                DispatchQueue.main.async { [weak this] in
                    guard let this = this else { return }
                    
                    // デリゲートに通知する。
                    this.delegate?.dacsdkmaSmartVisionAdPlayer?(this, didShowReminder: this.reminderCompanionView)
                }
                
                completion?()
            }
            else {
                this.removeAdSubviews()
            }
        }
    }
    
    private func toRestore(_ completion: (() -> Swift.Void)? = nil) {
        switch self.previousAdViewMode {
        case .minimized:
            self.toMinimized() {
                completion?()
            }
            break
        case .normal:
            self.toInline() { [weak self] in
                self?.showCompanionAtStop()
                completion?()
            }
            break
        case .interstitial:
            self.toInterstitial() {
                completion?()
            }
            break
        case .maximized:
            self.toFullscreen() {
                completion?()
            }
            break
        }
    }
    
    func convertVideoRect() {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            guard let adsManager: DACSDKMAAdsManager = this.adsManager else { return }
            guard let adVideoView: UIView = adsManager.adVideoView else { return }
            
            if let adControlsView: DACSDKMAAdControlsView = this.videoAdControlsView {
                // 動画広告コントローラーのプレイヤーボタン部分の表示位置・サイズを再生中の動画部分と同じにする。
                adControlsView.playerView.frame = adControlsView.convert(adsManager.videoRect, from: adVideoView)
            }
            
            if let companion: UIView = this.stopCompanionSlot?.companion {
                // 止め画像に隙間ができたり、透過しないように背景色を設定する
                companion.backgroundColor = UIColor.black
                
                // 止め画像の表示位置・サイズを再生中の動画部分と同じにする。
                companion.frame = this.stopCompanionControlsView.convert(adsManager.videoRect, from: adVideoView)
            }
        }
    }
    
    // --------------------------------------------------
    // MARK: KVO
    // --------------------------------------------------
    /**
    KVO登録
    */
    private func registerObserver() {
        if true == self.isRegisteredObserver { return }
        guard let adsManager: DACSDKMAAdsManager = self.adsManager else { return }
        adsManager.addObserver(self, forKeyPath:"videoRect", options:.new, context: &DACSDKMASmartVisionAdPlayer.KVOContext)
        adsManager.addObserver(self, forKeyPath:"progressTime", options:.new, context: &DACSDKMASmartVisionAdPlayer.KVOContext)
        self.isRegisteredObserver = true
    }
    
    /**
     KVO解除
     */
    private func unregisterObserver() {
        if false == self.isRegisteredObserver { return }
        guard let adsManager: DACSDKMAAdsManager = self.adsManager else { return }
        adsManager.removeObserver(self, forKeyPath:"videoRect", context: &DACSDKMASmartVisionAdPlayer.KVOContext)
        adsManager.removeObserver(self, forKeyPath:"progressTime", context: &DACSDKMASmartVisionAdPlayer.KVOContext)
        self.isRegisteredObserver = false
    }
    
    /**
     KVO
     */
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &DACSDKMASmartVisionAdPlayer.KVOContext {
            DispatchQueue.main.async { [weak self] in
                guard let keyPath: String = keyPath else { return }
                guard let this = self else { return }
                guard let adsManager: DACSDKMAAdsManager = this.adsManager else { return }
                
                switch keyPath {
                case "videoRect":
                    self?.convertVideoRect()
                    break
                case "progressTime":
                    // 広告の再生時間が変更した。
                    let progressTimeStr = String(format: "%2d:%.2d", Int(adsManager.progressTime / 60), Int(adsManager.progressTime.truncatingRemainder(dividingBy: 60)))
                    this.videoAdControlsView?.progress = Float(adsManager.progress)
                    this.videoAdControlsView?.progressTimeLabel.text = progressTimeStr
                    break
                default:
                    break
                }
            }
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    // --------------------------------------------------
    // MARK: delegate of DACSDKMA
    // --------------------------------------------------
    public func dacsdkmaAdsLoader(_ loader: DACSDKMAAdsLoader, didLoad adsLoadedData: DACSDKMAAdsLoadedData) {
        self.adsManager = adsLoadedData.adsManager
        self.adsManager?.delegate = self
        self.adsManager?.load() { [weak self] (result: Bool) in
            if result {
                if true == self?.interstitial {
                    self?.previousAdViewMode = DACSDKMAAdViewMode.interstitial
                    self?.toInterstitial(false) {
                        self?.videoAdControlsView?.replayButton.isHidden = true
                    }
                }
                else {
                    self?.toInline(false) {
                        self?.videoAdControlsView?.replayButton.isHidden = true
                    }
                }
            }
        }
    }
    
    public func dacsdkmaAdsLoader(_ loader: DACSDKMAAdsLoader, didFail adError: DACSDKMAAdError) {
        // アプリに通知する。
        self.delegate?.dacsdkmaSmartVisionAdPlayer?(self, didReceiveAdError: adError)

        // アプリに通知後、解放処理をします。
        if self.autoRemoveFromSuperView {
            self.clean()
        }
    }
    
    public func dacsdkmaAdsManager(_ adsManager: DACSDKMAAdsManager, didReceiveAdEvent adEvent: DACSDKMAAdEvent) {
        switch adEvent.type {
        case DACSDKMAAdEventType.didClose:
            self.clean()
            break
        case DACSDKMAAdEventType.didAdBreakStart:
            if let adControlsView: DACSDKMAAdControlsView = self.videoAdControlsView {
                adControlsView.isHidden = false
                adControlsView.superview?.bringSubview(toFront: adControlsView)
            }
            self.videoAdControlsView?.playbackStatus = DACSDKMAAdVideoPlaybackStates.playing
            self.hideCompanionAtStop()
            break
        case DACSDKMAAdEventType.didAdBreakEnd:
            self.videoAdControlsView?.playbackStatus = DACSDKMAAdVideoPlaybackStates.stopped
            self.showCompanionAtStop()
            break
        case DACSDKMAAdEventType.didResume, DACSDKMAAdEventType.didRewind:
            self.videoAdControlsView?.playbackStatus = DACSDKMAAdVideoPlaybackStates.playing
            self.hideCompanionAtStop()
            break
        case DACSDKMAAdEventType.didPause:
            if DACSDKMAAdVideoPlaybackStates.playing == self.videoAdControlsView?.playbackStatus {
                // 再生時のみ、ステータス変更をする。停止中から一時停止にはしない。
                self.videoAdControlsView?.playbackStatus = DACSDKMAAdVideoPlaybackStates.pausing
                self.stopIfNeeded()
            }
            break
        case DACSDKMAAdEventType.didStop:
            self.videoAdControlsView?.playbackStatus = DACSDKMAAdVideoPlaybackStates.stopped
            
            // フルスクリーンの場合、前のサイズに変更する。
            self.toRestore()
            
            // 自動クローズ処理
            if 0 < self.videoCloseTime {
                self.videoCloseTimer?.invalidate()
                self.videoCloseTimer = DACSDKMAUtilTimer(timeInterval: TimeInterval(self.videoCloseTime) * 0.001, repeats: false) {
                    [weak self] _ in
                    guard let this = self else { return }
                    if DACSDKMAAdVideoPlaybackStates.stopped == this.videoAdControlsView?.playbackStatus {
                        this.close()
                    }
                    else {
                        this.videoCloseTimer?.invalidate()
                        this.videoCloseTimer = nil
                    }
                }
            }
            break
        default:
            break
        }
        
        // アプリに通知する。
        self.delegate?.dacsdkmaSmartVisionAdPlayer?(self, didReceiveAdEvent: adEvent)
    }
    
    public func dacsdkmaAdsManager(_ adsManager: DACSDKMAAdsManager, didReceiveAdError adError: DACSDKMAAdError) {
        // アプリに通知する。
        self.delegate?.dacsdkmaSmartVisionAdPlayer?(self, didReceiveAdError: adError)

        // アプリに通知後、解放処理をします。
        if self.autoRemoveFromSuperView {
            self.close()
        }
    }
    
    public func dacsdkmaAdsManagerDidRequestContentPause(_ adsManager: DACSDKMAAdsManager) {
        // 現在のところ、特に何もしない。
    }
    
    public func dacsdkmaAdsManagerDidRequestContentResume(_ adsManager: DACSDKMAAdsManager) {
        // 現在のところ、特に何もしない。
    }
    
    
    // --------------------------------------------------
    // MARK: delegate of DACSDKMAAdControlsView
    // --------------------------------------------------
    public func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickPlayerView view: UIView) {
        if true == self.adsManager?.isFullscreen {
            self.adsManager?.clickVideo()
        }
        else {
            if nil == self.oneByOneCompanionSlot?.companion {
                self.adsManager?.clickVideo()
            }
            else {
                self.toFullscreen()
            }
        }
    }
    
    public func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickVolumeButton button: UIButton) {
        self.adsManager?.mute(adControlsView.isMute)
    }
    
    public func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickPlayButton button: UIButton) {
        if adControlsView.isPlaying {
            self.adsManager?.play()
        } else {
            self.adsManager?.pause()
        }
    }
    
    public func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickReplayButton button: UIButton) {
        if DACSDKMAAdViewMode.minimized == self.adsManager?.adViewMode {
            self.toFullscreen() { [weak self] in
                self?.adsManager?.replay()
            }
        }
        else {
            self.adsManager?.replay()
        }
    }
    
    public func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickEnterFullscreenButton button: UIButton) {
        self.toFullscreen()
    }
    
    public func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickExitFullscreenButton button: UIButton) {
        if nil == self.twoByTwoCompanionSlot?.companion {
            self.toRestore()
        }
        else {
            self.adsManager?.clickVideo()
            self.toRestore()
        }
    }
    
    public func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickCloseButton button: UIButton) {
        self.close()
    }
    
    public func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickLinkButton button: UIButton) {
        self.adsManager?.clickVideo()
    }
    
    /// superviewのclip外で描画されている場合、タッチに反応させるためのオーバーライド
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subview: UIView in self.subviews.reversed() {
            if let hitView: UIView = subview.hitTest(subview.convert(point, from: self), with: event) {
                return hitView
            }
        }
        
        return super.hitTest(point, with: event)
    }
}


// --------------------------------------------------
// MARK: - class
// --------------------------------------------------
/// インライン・コントロール・ビュー
@objc
open class DACSDKMASmartVisionAdInlineControlsView: DACSDKMAAdControlsView {
    
    // --------------------------------------------------
    // MARK: life cycle
    // --------------------------------------------------
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.volumeButton)
        self.addSubview(self.replayButton)
        self.addSubview(self.enterFullscreenButton)
        self.addSubview(self.closeButton)
        self.addSubview(self.linkButton)
        
        // ----- AutoLayout -----
        // 音量ボタン - 左上に表示する(停止中は表示しない)
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[volumeButton(iconWidth)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[volumeButton(iconHeight)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        
        // リプレイボタン - 左上に表示する(停止中のみ表示する)
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[replayButton(iconWidth)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[replayButton(iconHeight)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        
        // Xボタン - 右上に表示する
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[closeButton(iconWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[closeButton(iconHeight)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        
        // フルスクリーン化ボタン - 右下に表示する
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[enterFullscreenButton(iconWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[enterFullscreenButton(iconHeight)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        
        // リンクボタン - 右下に表示する
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[linkButton(iconWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[linkButton(iconHeight)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        
        NSLayoutConstraint.activate(self.layoutConstraints)
    }
    
    override open var playbackStatus: DACSDKMAAdVideoPlaybackStates {
        willSet {
            super.playbackStatus = newValue
            switch newValue {
            case DACSDKMAAdVideoPlaybackStates.stopped:
                // 停止中は音量ボタンを表示しない。（リプレイボタンと重なるため。）
                self.volumeButton.isHidden = true
                break
            default:
                self.volumeButton.isHidden = false
                break
            }
        }
    }
}

// --------------------------------------------------
// MARK: - class
// --------------------------------------------------
/// フルスクリーン・コントロール・ビュー
@objc
open class DACSDKMASmartVisionAdFullscreenControlsView: DACSDKMAAdControlsView {
    
    // --------------------------------------------------
    // MARK: life cycle
    // --------------------------------------------------
    override public init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubview(self.volumeButton)
        self.addSubview(self.playButton)
        self.addSubview(self.replayButton)
        self.addSubview(self.exitFullscreenButton)
        self.addSubview(self.linkButton)
        
        self.addSubview(self.durationLabel)
        self.addSubview(self.progressTimeLabel)
        self.addSubview(self.progressView)
        
        // ----- AutoLayout -----
        // 音量ボタン - 左上に表示する
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[volumeButton(iconWidth)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[volumeButton(iconHeight)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        
        // Closeボタン - 右上に表示する
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[exitFullscreenButton(iconWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[exitFullscreenButton(iconHeight)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        
        // 再生・一時停止ボタン - 左下に表示する(停止中は表示されない)
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[playButton(iconWidth)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[playButton(iconHeight)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        
        // リプレイボタン - 左下に表示する(停止中のみ表示される)
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[replayButton(iconWidth)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[replayButton(iconHeight)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        
        // プログレスビューなど
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[playButton]-margin-[progressTimeLabel(50)]-margin-[progressView(>=0)]-margin-[durationLabel(50)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[durationLabel(iconHeight)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[progressTimeLabel(iconHeight)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[progressView(5)]-15-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        
        // リンクボタン - 右下に表示する
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[linkButton(iconWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[linkButton(iconHeight)]-margin-[playButton]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        
        NSLayoutConstraint.activate(self.layoutConstraints)
    }
}

// --------------------------------------------------
// MARK: - class
// --------------------------------------------------
/// インタースティシャル・コントロール・ビュー
@objc
open class DACSDKMASmartVisionAdInterstitialControlsView: DACSDKMAAdControlsView {

    // --------------------------------------------------
    // MARK: life cycle
    // --------------------------------------------------
    override public init(frame: CGRect) {
        super.init(frame: frame)

        // 音量ボタン
        self.addSubview(self.volumeButton)
        
        // 閉じるボタン
        self.addSubview(self.closeButton)
        
        // ----- AutoLayout設定 -----
        // Xボタン - 右上に表示する
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "H:[closeButton(iconWidth)]-margin-|", options: [], metrics: self.metrics, views: self.views))
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-margin-[closeButton(iconHeight)]", options: [], metrics: self.metrics, views: self.views))
        
        // 音量ボタン - 右下に表示する
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "H:[volumeButton(iconWidth)]-margin-|", options: [], metrics: self.metrics, views: self.views))
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "V:[volumeButton(iconHeight)]-margin-|", options: [], metrics: self.metrics, views: self.views))

        NSLayoutConstraint.activate(self.layoutConstraints)
    }
}


// --------------------------------------------------
// MARK: - class
// --------------------------------------------------
/// 止め画像・コントロール・cビュー
@objc
open class DACSDKMASmartVisionAdStopCompanionControlsView: DACSDKMAAdControlsView {
    
    // --------------------------------------------------
    // MARK: life cycle
    // --------------------------------------------------
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.replayButton)
        self.addSubview(self.closeButton)
        self.addSubview(self.linkButton)
        
        // ----- AutoLayout設定 -----
        // リプレイボタン - 左上に表示する(停止中のみ表示される)
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[replayButton(iconWidth)]", options: [], metrics: self.metrics, views: self.views))
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[replayButton(iconHeight)]", options: [], metrics: self.metrics, views: self.views))
        
        // Xボタン - 右上に表示する
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[closeButton(iconWidth)]-margin-|", options: [], metrics: self.metrics, views: self.views))
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[closeButton(iconHeight)]", options: [], metrics: self.metrics, views: self.views))
        
        // リンクボタン - 右下に表示する
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[linkButton(iconWidth)]-margin-|", options: [], metrics: self.metrics, views: self.views))
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[linkButton(iconHeight)]-margin-|", options: [], metrics: self.metrics, views: self.views))
        
        NSLayoutConstraint.activate(self.layoutConstraints)
    }
    
    // --------------------------------------------------
    // MARK: override fnction
    // --------------------------------------------------
    override open func didAddSubview(_ subview: UIView) {
        if !self.views.values.contains(subview) {
            self.bringSubview(toFront: self.replayButton)
            self.bringSubview(toFront: self.closeButton)
            self.bringSubview(toFront: self.linkButton)
        }
    }
}

// --------------------------------------------------
// MARK: - class
// --------------------------------------------------
/// リマインダバナー・ビュー
@objc
open class DACSDKMASmartVisionAdReminderCompanionView: DACSDKMAAdControlsView {
    // --------------------------------------------------
    // MARK: override function
    // --------------------------------------------------
    override open func didAddSubview(_ subview: UIView) {
        if !self.views.values.contains(subview) {
            // リプレイボタンを手前に表示する。
            self.bringSubview(toFront: self.replayButton)
        }
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        // superviewによる制約があるため、一旦AutoLayoutを無効にする。
        NSLayoutConstraint.deactivate(self.layoutConstraints)
        self.layoutConstraints = []
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard let superview: UIView = self.superview else {
            return
        }
        
        // リプレイボタンのみ表示する。
        self.addSubview(self.replayButton)
        
        // ----- AutoLayout設定 -----
        // リプレイボタン - 右下に表示する(停止中のみ表示される)
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[replayButton(iconWidth)]-margin-|", options: [], metrics: self.metrics, views: self.views))
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[replayButton(iconHeight)]-margin-|", options: [], metrics: self.metrics, views: self.views))
        
        // 自身を中央に配置する。リマインダーの大きさは固定。
        let views: [String: UIView] = [
            "superview": superview,
            "self": self,
            ]
        
        let metrics: [String : Any] = [
            "width": DACSDKMASmartVisionAdPlayer.reminderCompanionSize.width,
            "height": DACSDKMASmartVisionAdPlayer.reminderCompanionSize.height,
            ]
        
        // 自身のAutoLayout有効
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "H:[superview]-(<=0)-[self(width)]", options: [.alignAllCenterY], metrics: metrics, views: views)
        )
        self.layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(
            withVisualFormat: "V:[superview]-(<=0)-[self(height)]", options: [.alignAllCenterX], metrics: metrics, views: views)
        )

        NSLayoutConstraint.activate(self.layoutConstraints)
    }
}

