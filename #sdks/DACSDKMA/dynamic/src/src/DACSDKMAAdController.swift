//
//  DACSDKMAAdController.swift
//  DACSDKMA
//
//  Copyright (c) 2016 D.A.Consortium Inc. All rights reserved.
//

import UIKit
import DACSDKMA


// --------------------------------------------------
// MARK: - class
// --------------------------------------------------
/// DACSDKMA標準動画広告コントローラークラス
@objc
open class DACSDKMAAdController: NSObject, DACSDKMAAdControlsViewDelegate {
    
    private static var KVOContext = 0
    
    // --------------------------------------------------
    // MARK: property
    // --------------------------------------------------
    
    /// 動画広告コントローラー・ビュー
    private var adControlsView: DACSDKMAAdControlsView? = nil
    
    /// 動画広告マネージャー
    private let adsManager: DACSDKMAAdsManager
    
    /// KVO用登録済みチェックフラグ
    private var isRegisteredObserver: Bool = false
    
    /// 動画広告コントローラー・ビューのhidden状態
    open var isHidden: Bool = true {
        didSet { self.adControlsView?.isHidden = self.isHidden }
    }
    
    // --------------------------------------------------
    // MARK: life cycle
    // --------------------------------------------------
    @nonobjc
    @available(*, unavailable)
    override private init() {
        fatalError("init() has not been implemented")
    }
    
    /**
    初期化
     */
    public init(adsManager: DACSDKMAAdsManager) {
        self.adsManager = adsManager

        super.init()
        
        self.registerObserver()
    }
    
    deinit {
        self.clean()
    }
    
    
    // --------------------------------------------------
    // MARK: function
    // --------------------------------------------------
    /**
    使用したオブジェクトなどを破棄する。
    */
    open func clean() {
        self.unregisterObserver()
        self.removeAdControlsView()
    }
    
    /**
    インライン化する
    */
    private func toInline() {
        if nil != self.adControlsView as? DACSDKMAInlineAdControlsView {
            // インライン用ビューコントローラーがある場合、何もしない。
            return
        }
        
        self.removeAdControlsView()
        
        // 広告枠ビューが存在しない場合、何もしない。
        guard let adSpotView: UIView = self.adsManager.adSpotView else { return }

        // インライン用ビューコントローラーの生成
        let adControlsView: DACSDKMAInlineAdControlsView = DACSDKMAInlineAdControlsView()
        self.adControlsView = adControlsView
        self.adsManager.changeAdViewMode(DACSDKMAAdViewMode.normal) { [weak self] (result: Bool) in
            guard let this = self else { return }
            if result {
                adControlsView.delegate = this
                adControlsView.isHidden = this.isHidden
                adControlsView.isMute = this.adsManager.isMute
                adControlsView.playbackStatus = this.adsManager.playbackStatus
                adControlsView.playerView.frame = this.adsManager.videoRect
                adControlsView.skipButton.isHidden = !this.adsManager.isSkippable
                adControlsView.frame = adSpotView.bounds
                adSpotView.addSubview(adControlsView)
                adSpotView.bringSubview(toFront: adControlsView)
            }
            else {
                this.removeAdControlsView()
            }
        }
    }
    
    /**
     フルスクリーン化する
     */
    private func toFullscreen() {
        if nil != self.adControlsView as? DACSDKMAFullscreenAdControlsView {
            // フルスクリーン用ビューコントローラーがある場合、何もしない。
            return
        }
        
        self.removeAdControlsView()
        
        // 広告枠ビューが存在しない場合、何もしない。        
        guard let adSpotView: UIView = self.adsManager.adSpotView else { return }

        // フルスクリーン用ビューコントローラーの生成
        let adControlsView: DACSDKMAFullscreenAdControlsView = DACSDKMAFullscreenAdControlsView()
        self.adControlsView = adControlsView
        self.adsManager.changeAdViewMode(DACSDKMAAdViewMode.maximized) { [weak self] (result: Bool) in
            guard let this = self else { return }
            if result {
                adControlsView.delegate = this
                adControlsView.isHidden = this.isHidden
                adControlsView.isMute = this.adsManager.isMute
                adControlsView.playbackStatus = this.adsManager.playbackStatus
                adControlsView.playerView.frame = this.adsManager.videoRect
                adControlsView.skipButton.isHidden = !this.adsManager.isSkippable
                adControlsView.frame = adSpotView.bounds
                adSpotView.addSubview(adControlsView)
                adSpotView.bringSubview(toFront: adControlsView)
            }
            else {
                this.removeAdControlsView()
            }
        }
    }
    
    /**
     動画広告コントローラー・ビューの削除
     */
    private func removeAdControlsView() {
        self.adControlsView?.delegate = nil
        self.adControlsView?.removeFromSuperview()
        self.adControlsView = nil
    }
    
    // --------------------------------------------------
    // MARK: for KVO
    // --------------------------------------------------
    /**
     KVO登録
     */
    private func registerObserver() {
        if true == self.isRegisteredObserver { return }
        self.adsManager.addObserver(self, forKeyPath:"playbackStatus", options:.new, context: &DACSDKMAAdController.KVOContext)
        self.adsManager.addObserver(self, forKeyPath:"progressTime", options:.new, context: &DACSDKMAAdController.KVOContext)
        self.adsManager.addObserver(self, forKeyPath:"skipRemainingTime", options:[.new, .initial], context: &DACSDKMAAdController.KVOContext)
        self.adsManager.addObserver(self, forKeyPath:"videoRect", options:.new, context: &DACSDKMAAdController.KVOContext)
        self.adsManager.addObserver(self, forKeyPath:"adEvent", options:.new, context: &DACSDKMAAdController.KVOContext)
        self.isRegisteredObserver = true
    }
    
    /**
     KVO解除
     */
    private func unregisterObserver() {
        if false == self.isRegisteredObserver { return }
        self.adsManager.removeObserver(self, forKeyPath:"playbackStatus", context: &DACSDKMAAdController.KVOContext)
        self.adsManager.removeObserver(self, forKeyPath:"progressTime", context: &DACSDKMAAdController.KVOContext)
        self.adsManager.removeObserver(self, forKeyPath:"skipRemainingTime", context: &DACSDKMAAdController.KVOContext)
        self.adsManager.removeObserver(self, forKeyPath:"videoRect", context: &DACSDKMAAdController.KVOContext)
        self.adsManager.removeObserver(self, forKeyPath:"adEvent", context: &DACSDKMAAdController.KVOContext)
        self.isRegisteredObserver = false
    }
    
    /**
     KVO
     */
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &DACSDKMAAdController.KVOContext {
            guard let keyPath: String = keyPath else { return }
            switch keyPath {
            case "playbackStatus":
                // 広告の再生状態が変化した。
                self.adControlsView?.playbackStatus = self.adsManager.playbackStatus
                break
            case "progressTime":
                // 広告の再生時間が変更した。
                let remainingTimeStr = String(format: "%2d:%.2d", Int((adsManager.durationTime - adsManager.progressTime) / 60), Int((adsManager.durationTime - adsManager.progressTime).truncatingRemainder(dividingBy: 60)))
                self.adControlsView?.adInfoLabel.text = "Ad \(self.adsManager.currentAdIndex + 1) of \(self.adsManager.totalAdsCount) (\(remainingTimeStr))"
                break
            case "skipRemainingTime":
                // スキップの残り時間が変更した。
                self.adControlsView?.skipButton.isHidden = !self.adsManager.isSkippable
                break
            case "videoRect":
                // 広告表示プレイヤーのサイズが変更した。
                self.adControlsView?.playerView.frame = self.adsManager.videoRect                
                break
            case "adEvent":
                switch self.adsManager.adEvent.type {
                case DACSDKMAAdEventType.didLoad:
                    self.toInline()
                    break
                case DACSDKMAAdEventType.didAdBreakStart:
                    self.isHidden = false
                    if let adControlsView: DACSDKMAAdControlsView = self.adControlsView {
                        adControlsView.superview?.bringSubview(toFront: adControlsView)
                    }
                    break
                case DACSDKMAAdEventType.didAdBreakEnd:
                    if self.adsManager.settings.isAutoAdHidden {
                        self.isHidden = true
                    }
                    break
                case DACSDKMAAdEventType.didStop:
                    // 広告表示が完了した場合、元の大きさに戻す。
                    self.toInline()
                    break
                case DACSDKMAAdEventType.didEnterFullscreen:
                    self.toFullscreen()
                    break
                case DACSDKMAAdEventType.didExitFullscreen:
                    self.toInline()
                    break
                case DACSDKMAAdEventType.didChangePlayableStatus:
                    // 広告の表示状態が変化した。
                    if !self.adsManager.playableStatus.isPlayable() {
                        self.toInline()
                    }
                    break
                default:
                    break
                }
                break
            default:
                break
            }
            
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
    // --------------------------------------------------
    // MARK: delegate of DACSDKMAAdControlsViewDelegate
    // --------------------------------------------------
    public func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickPlayerView view: UIView) {
        self.adsManager.clickVideo()
    }
    
    public func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickVolumeButton button: UIButton) {
        self.adsManager.mute(adControlsView.isMute)
    }
    
    public func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickReplayButton button: UIButton) {
        self.adsManager.replay()
    }
    
    public func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickSkipButton button: UIButton) {
        self.adsManager.skip()
    }
    
    public func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickEnterFullscreenButton button: UIButton) {
        self.toFullscreen()
    }
    
    public func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickExitFullscreenButton button: UIButton) {
        self.toInline()
    }
}


// --------------------------------------------------
// MARK: - class
// --------------------------------------------------
/// IMA標準動画広告インライン用コントローラークラス
@objc
open class DACSDKMAInlineAdControlsView: DACSDKMAAdControlsView {
    
    // --------------------------------------------------
    // MARK: life cycle
    // --------------------------------------------------
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.volumeButton.isHidden = false
        self.addSubview(self.volumeButton)
        
        self.prButton.isHidden = false
        self.addSubview(self.prButton)
        
        self.adInfoLabel.isHidden = false
        self.addSubview(self.adInfoLabel)
        
        self.replayButton.isHidden = true
        self.addSubview(self.replayButton)
        
        self.enterFullscreenButton.isHidden = false
        self.addSubview(self.enterFullscreenButton)
        
        self.skipButton.isHidden = true
        self.addSubview(self.skipButton)
        
        // ----- AutoLayout設定 ------
        var layoutConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
        
        // 音量ボタン - 左上に表示する
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[volumeButton(iconWidth)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[volumeButton(iconHeight)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        
        // PRボタン - 右上に表示する
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[prButton(iconWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[prButton(iconHeight)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        
        // 動画広告情報ラベル - 左下に表示する
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[adInfoLabel(120)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[adInfoLabel(12)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        
        // リプレイボタン - 左下に表示する
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[replayButton(iconWidth)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[replayButton(iconHeight)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        
        // フルスクリーン化ボタン - 右下に表示する
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[enterFullscreenButton(iconWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[enterFullscreenButton(iconHeight)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        
        // スキップボタン - 右中央に表示する
        let spacerTop = UIView(); spacerTop.isHidden = true; spacerTop.translatesAutoresizingMaskIntoConstraints = false
        let spacerBottom = UIView(); spacerBottom.isHidden = true; spacerBottom.translatesAutoresizingMaskIntoConstraints = false
        let viewsWithSkipbutton: [String: UIView] = ["skipButton": self.skipButton, "st": spacerTop, "sb": spacerBottom]
        self.addSubview(spacerTop)
        self.addSubview(spacerBottom)
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[skipButton(iconWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[st(>=1)]-(<=0)-[skipButton(iconHeight)]-(<=0)-[sb(st)]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: self.metrics, views: viewsWithSkipbutton))
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[st]|", options: NSLayoutFormatOptions(), metrics: nil, views: viewsWithSkipbutton))
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[sb]|", options: NSLayoutFormatOptions(), metrics: nil, views: viewsWithSkipbutton))
        
        self.layoutConstraints = layoutConstraints
        NSLayoutConstraint.activate(self.layoutConstraints)
    }
}



// --------------------------------------------------
// MARK: - class
// --------------------------------------------------
/// IMA標準動画広告フルスクリーン用コントローラークラス
@objc
open class DACSDKMAFullscreenAdControlsView: DACSDKMAAdControlsView {
    
    // --------------------------------------------------
    // MARK: life cycle
    // --------------------------------------------------
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.volumeButton.isHidden = false
        self.addSubview(self.volumeButton)
        
        self.exitFullscreenButton.isHidden = false
        self.addSubview(self.exitFullscreenButton)
        
        self.adInfoLabel.isHidden = false
        self.addSubview(self.adInfoLabel)
        
        self.replayButton.isHidden = true
        self.addSubview(self.replayButton)
        
        self.skipButton.isHidden = true
        self.addSubview(self.skipButton)
        
        // ----- AutoLayout設定 -----
        var layoutConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
        
        // 音量ボタン - 左上に表示する
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[volumeButton(iconWidth)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[volumeButton(iconHeight)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        
        // インライン化ボタン - 右上に表示する
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[exitFullscreenButton(iconWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-margin-[exitFullscreenButton(iconHeight)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        
        // 動画広告情報ラベル - 左下に表示する
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[adInfoLabel(120)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[adInfoLabel(12)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        
        // リプレイボタン - 左下に表示する
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-margin-[replayButton(iconWidth)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[replayButton(iconHeight)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        
        // スキップボタン - 右中央に表示する
        let spacerTop = UIView(); spacerTop.isHidden = true; spacerTop.translatesAutoresizingMaskIntoConstraints = false
        let spacerBottom = UIView(); spacerBottom.isHidden = true; spacerBottom.translatesAutoresizingMaskIntoConstraints = false
        let viewsWithSkipbutton: [String: UIView] = ["skipButton": self.skipButton, "st": spacerTop, "sb": spacerBottom]
        self.addSubview(spacerTop)
        self.addSubview(spacerBottom)
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[skipButton(iconWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[st(>=1)]-(<=0)-[skipButton(iconHeight)]-(<=0)-[sb(st)]|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: self.metrics, views: viewsWithSkipbutton))
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[st]|", options: NSLayoutFormatOptions(), metrics: nil, views: viewsWithSkipbutton))
        layoutConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[sb]|", options: NSLayoutFormatOptions(), metrics: nil, views: viewsWithSkipbutton))
        
        self.layoutConstraints = layoutConstraints
        NSLayoutConstraint.activate(self.layoutConstraints)
    }
}
