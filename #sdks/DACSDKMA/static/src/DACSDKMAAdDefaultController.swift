//
//  DACSDKMAAdDefaultPlayer.swift
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
public class DACSDKMAAdDefaultController: NSObject, DACSDKMAAdControlsViewDelegate {
    
    static private let KVOContext = UnsafeMutablePointer<Void>(nil)
    
    // --------------------------------------------------
    // MARK: properties
    // --------------------------------------------------
    
    /// 動画広告コントローラー・ビュー
    private var adControlsView: DACSDKMAAdDefaultControlsView? = nil
    
    /// 動画広告マネージャー
    private let adsManager: DACSDKMAAdsManager
    
    /// KVO用登録済みチェックフラグ
    private var registeredObserver: Bool = false
    
    /// 動画広告コントローラー・ビューのhidden状態
    public var hidden: Bool {
        set { self.adControlsView?.hidden = newValue }
        get { return self.adControlsView?.hidden ?? true }
    }
    
    // --------------------------------------------------
    // MARK: life cycle
    // --------------------------------------------------
    @available(*, unavailable)
    public override init() {
        fatalError("init() has not been implemented")
    }
    
    /**
    初期化
     */
    public init(adsManager: DACSDKMAAdsManager) {
        self.adsManager = adsManager

        super.init()
        
        self.registerObserver()

        // 生成時は非表示にする
        self.adControlsView?.hidden = true
    }
    
    deinit {
        self.clean()
    }
    
    
    // --------------------------------------------------
    // MARK: methods
    // --------------------------------------------------
    /**
    使用したオブジェクトなどを破棄する。
    */
    public func clean() {
        self.unregisterObserver()
        self.removeAdControlsView()
    }
    
    /**
    インライン化する
    */
    private func toInline() {
        // インライン用ビューコントローラーがある場合、何もしない。
        if nil != self.adControlsView as? DACSDKMAAdDefaultControlsViewForInline { return }
        else if let adControlsViewForFullscreen = self.adControlsView as? DACSDKMAAdDefaultControlsViewForFullscreen {
            adControlsViewForFullscreen.removeFromSuperview()
        }
        
        guard let adContainerView: UIView = self.adsManager.adContainer.view else {
            // 枠が無い場合は削除して、終了。
            self.clean()
            return
        }
        
        // インライン用ビューコントローラーの生成
        let adControlsView: DACSDKMAAdDefaultControlsViewForInline = DACSDKMAAdDefaultControlsViewForInline(frame: adContainerView.bounds)
        adControlsView.delegate = self
        adControlsView.isMute = self.adsManager.isMute
        adControlsView.playbackStatus = self.adsManager.playbackStatus
        adControlsView.playerView.frame = self.adsManager.videoRect
        adControlsView.skipButton.hidden = !self.adsManager.skippable()
        adContainerView.addSubview(adControlsView)
        adContainerView.bringSubviewToFront(adControlsView)
        
        self.adControlsView = adControlsView
    }
    
    /**
     フルスクリーン化する
     */
    private func toFullscreen() {
        // フルスクリーン用ビューコントローラーがある場合、何もしない。
        if nil != self.adControlsView as? DACSDKMAAdDefaultControlsViewForFullscreen { return }
        else if let adControlsViewForInline = self.adControlsView as? DACSDKMAAdDefaultControlsViewForInline {
            adControlsViewForInline.removeFromSuperview()
        }

        guard let fullscreenView: UIView = self.adsManager.fullscreenView else {
            // 枠が無い場合は削除して、終了。
            self.clean()
            return
        }

        // フルスクリーン用ビューコントローラーの生成
        let adControlsView: DACSDKMAAdDefaultControlsViewForFullscreen = DACSDKMAAdDefaultControlsViewForFullscreen(frame: fullscreenView.bounds)
        adControlsView.delegate = self
        adControlsView.isMute = self.adsManager.isMute
        adControlsView.playbackStatus = self.adsManager.playbackStatus
        adControlsView.playerView.frame = self.adsManager.videoRect
        adControlsView.skipButton.hidden = !self.adsManager.skippable()
        fullscreenView.addSubview(adControlsView)
        fullscreenView.bringSubviewToFront(adControlsView)
        
        self.adControlsView = adControlsView
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
        if true == self.registeredObserver { return }
        self.adsManager.addObserver(self, forKeyPath:"isFullscreen", options:[.New, .Initial], context: DACSDKMAAdDefaultController.KVOContext)
        self.adsManager.addObserver(self, forKeyPath:"playableStatus", options:.New, context: DACSDKMAAdDefaultController.KVOContext)
        self.adsManager.addObserver(self, forKeyPath:"playbackStatus", options:.New, context: DACSDKMAAdDefaultController.KVOContext)
        self.adsManager.addObserver(self, forKeyPath:"progress", options:.New, context: DACSDKMAAdDefaultController.KVOContext)
        self.adsManager.addObserver(self, forKeyPath:"progressTime", options:.New, context: DACSDKMAAdDefaultController.KVOContext)
        self.adsManager.addObserver(self, forKeyPath:"skipRemainingTime", options:[.New, .Initial], context: DACSDKMAAdDefaultController.KVOContext)
        self.adsManager.addObserver(self, forKeyPath:"videoRect", options:.New, context: DACSDKMAAdDefaultController.KVOContext)
        self.adsManager.addObserver(self, forKeyPath:"adEvent", options:.New, context: DACSDKMAAdDefaultController.KVOContext)
        
        self.registeredObserver = true
    }
    
    /**
     KVO解除
     */
    private func unregisterObserver() {
        if false == self.registeredObserver { return }
        self.registeredObserver = false
        self.adsManager.removeObserver(self, forKeyPath:"isFullscreen", context: DACSDKMAAdDefaultController.KVOContext)
        self.adsManager.removeObserver(self, forKeyPath:"playableStatus", context: DACSDKMAAdDefaultController.KVOContext)
        self.adsManager.removeObserver(self, forKeyPath:"playbackStatus", context: DACSDKMAAdDefaultController.KVOContext)
        self.adsManager.removeObserver(self, forKeyPath:"progress", context: DACSDKMAAdDefaultController.KVOContext)
        self.adsManager.removeObserver(self, forKeyPath:"progressTime", context: DACSDKMAAdDefaultController.KVOContext)        
        self.adsManager.removeObserver(self, forKeyPath:"skipRemainingTime", context: DACSDKMAAdDefaultController.KVOContext)
        self.adsManager.removeObserver(self, forKeyPath:"videoRect", context: DACSDKMAAdDefaultController.KVOContext)
        self.adsManager.removeObserver(self, forKeyPath:"adEvent", context: DACSDKMAAdDefaultController.KVOContext)
    }
    
    /**
     KVO
     */
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == DACSDKMAAdDefaultController.KVOContext {
            guard let keyPath: String = keyPath else { return }
            switch keyPath {
            case "isFullscreen":
                // 広告の古スクリーン状態が変化した。
                if self.adsManager.isFullscreen {
                    self.toFullscreen()
                }
                else {
                    self.toInline()
                }
                break
            case "playableStatus":
                // 広告の表示状態が変化した。
                if !self.adsManager.playableStatus.isPlayable() {
                    // 一時停止になる場合、元の大きさに戻す。
                    self.adsManager.fullscreen(false)
                }
                break
            case "playbackStatus":
                // 広告の再生状態が変化した。
                self.adControlsView?.playbackStatus = self.adsManager.playbackStatus
                break
            case "progress":
                if 1.0 <= self.adsManager.progress && self.adsManager.isLastAd {
                    // 広告表示が完了した場合、元の大きさに戻す。
                    self.adsManager.fullscreen(false)
                }
                break
            case "progressTime":
                // 広告の再生時間が変更した。
                let remainingTimeStr = String(format: "%2d:%.2d", Int((adsManager.durationTime - adsManager.progressTime) / 60), Int((adsManager.durationTime - adsManager.progressTime) % 60))
                self.adControlsView?.adInfoLabel.text = "Ad \(self.adsManager.currentAdIndex + 1) of \(self.adsManager.totalAdsCount) (\(remainingTimeStr))"
                break
            case "skipRemainingTime":
                // スキップの残り時間が変更した。
                self.adControlsView?.skipButton.hidden = !self.adsManager.skippable()
                break
            case "videoRect":
                // 広告表示プレイヤーのサイズが変更した。
                self.adControlsView?.playerView.frame = self.adsManager.videoRect                
                break
            case "adEvent":
                switch self.adsManager.adEvent.type {
                case DACSDKMAAdEventType.DidAdBreakStart:
                    self.adControlsView?.hidden = false
                    if let adControlsView: DACSDKMAAdDefaultControlsView = self.adControlsView {
                        adControlsView.superview?.bringSubviewToFront(adControlsView)
                    }
                    break
                case DACSDKMAAdEventType.DidAdBreakEnd:
                    if self.adsManager.settings.autoAdHidden {
                        self.adControlsView?.hidden = true
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
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    
    // --------------------------------------------------
    // MARK: delegate of DACSDKMAAdControlsViewDelegate
    // --------------------------------------------------
    public func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickPlayerView view: UIView) {
        self.adsManager.clickVideo()
    }
    
    public func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickVolumeButton button: UIButton) {
        self.adsManager.mute(adControlsView.isMute)
    }
    
    public func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickReplayButton button: UIButton) {
        self.adsManager.replay()
    }
    
    public func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickSkipButton button: UIButton) {
        self.adsManager.skip()
    }
    
    public func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickEnterFullscreenButton button: UIButton) {
        self.removeAdControlsView()
        self.adsManager.fullscreen(true)
    }
    
    public func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickExitFullscreenButton button: UIButton) {
        self.removeAdControlsView()
        self.adsManager.fullscreen(false)
    }
}


// --------------------------------------------------
// MARK: - class
// --------------------------------------------------
/// IMA標準動画広告コントローラー基底クラス
@objc
public class DACSDKMAAdDefaultControlsView: DACSDKMAAdControlsView {
    
    // --------------------------------------------------
    // MARK: life cycle
    // --------------------------------------------------
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 音量ボタン
        self.volumeButton.hidden = true
        self.volumeButton.setImage(DACSDKMAAdImageGenerator.volumeOnButtonIconImage, forState: UIControlState.Normal)
        self.volumeButton.setImage(DACSDKMAAdImageGenerator.volumeOffButtonIconImage, forState: UIControlState.Selected)
        
        // リプレイボタン
        self.replayButton.hidden = true
        self.replayButton.setImage(DACSDKMAAdImageGenerator.playButtonIconImage, forState: UIControlState.Normal)
        
        // フルスクリーン化ボタン
        self.enterFullscreenButton.hidden = true
        self.enterFullscreenButton.setImage(DACSDKMAAdImageGenerator.enterFullscreenButtonIconImage, forState: UIControlState.Normal)
        
        // インライン化ボタン
        self.exitFullscreenButton.hidden = true
        self.exitFullscreenButton.setImage(DACSDKMAAdImageGenerator.exitFullscreenButtonIconImage, forState: UIControlState.Normal)
        
        // PRボタン
        self.prButton.hidden = true
        self.prButton.enabled = false
        self.prButton.setImage(DACSDKMAAdImageGenerator.prIconImage, forState: UIControlState.Normal)
        
        // skipボタン
        self.skipButton.hidden = true
        self.skipButton.setImage(DACSDKMAAdImageGenerator.skipIconImage, forState: UIControlState.Normal)
    }
    
}


// --------------------------------------------------
// MARK: - class
// --------------------------------------------------
/// IMA標準動画広告インライン用コントローラークラス
@objc
public class DACSDKMAAdDefaultControlsViewForInline: DACSDKMAAdDefaultControlsView {
    
    // --------------------------------------------------
    // MARK: life cycle
    // --------------------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.volumeButton.hidden = false
        self.addSubview(self.volumeButton)
        
        self.prButton.hidden = false
        self.addSubview(self.prButton)
        
        self.adInfoLabel.hidden = false
        self.addSubview(self.adInfoLabel)
        
        self.replayButton.hidden = true
        self.addSubview(self.replayButton)
        
        self.enterFullscreenButton.hidden = false
        self.addSubview(self.enterFullscreenButton)
        
        self.skipButton.hidden = true
        self.addSubview(self.skipButton)
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
        
        if self.layoutConstraints.isEmpty {
            
            // AutoLayout設定
            var layoutConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
            
            // 音量ボタン - 左上に表示する
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[volumeButton(iconWidth)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-margin-[volumeButton(iconHeight)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            // PRボタン - 右上に表示する
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:[prButton(iconWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-margin-[prButton(iconHeight)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            // 動画広告情報ラベル - 左下に表示する
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[adInfoLabel(120)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:[adInfoLabel(12)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            // リプレイボタン - 左下に表示する
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[replayButton(iconWidth)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:[replayButton(iconHeight)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            // フルスクリーン化ボタン - 右下に表示する
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:[enterFullscreenButton(iconWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:[enterFullscreenButton(iconHeight)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            // スキップボタン - 右中央に表示する
            let spacerTop = UIView(); spacerTop.hidden = true; spacerTop.translatesAutoresizingMaskIntoConstraints = false
            let spacerBottom = UIView(); spacerBottom.hidden = true; spacerBottom.translatesAutoresizingMaskIntoConstraints = false
            let viewsWithSkipbutton: [String: UIView] = ["skipButton": self.skipButton, "st": spacerTop, "sb": spacerBottom]
            self.addSubview(spacerTop)
            self.addSubview(spacerBottom)
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:[skipButton(iconWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))            
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|[st(>=1)]-(<=0)-[skipButton(iconHeight)]-(<=0)-[sb(st)]|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: self.metrics, views: viewsWithSkipbutton))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:[st]|", options: NSLayoutFormatOptions(), metrics: nil, views: viewsWithSkipbutton))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:[sb]|", options: NSLayoutFormatOptions(), metrics: nil, views: viewsWithSkipbutton))

            self.layoutConstraints = layoutConstraints
        }
        
        dacsdkmaActivateConstraints(self.layoutConstraints, view: self)
    }
    
}



// --------------------------------------------------
// MARK: - class
// --------------------------------------------------
/// IMA標準動画広告フルスクリーン用コントローラークラス
@objc
public class DACSDKMAAdDefaultControlsViewForFullscreen: DACSDKMAAdDefaultControlsView {
    
    // --------------------------------------------------
    // MARK: life cycle
    // --------------------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.volumeButton.hidden = false
        self.addSubview(self.volumeButton)
        
        self.exitFullscreenButton.hidden = false
        self.addSubview(self.exitFullscreenButton)
        
        self.adInfoLabel.hidden = false
        self.addSubview(self.adInfoLabel)
        
        self.replayButton.hidden = true
        self.addSubview(self.replayButton)
        
        self.skipButton.hidden = true
        self.addSubview(self.skipButton)
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
        
        if self.layoutConstraints.isEmpty {
            
            // AutoLayout設定
            var layoutConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
            
            // 音量ボタン - 左上に表示する
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[volumeButton(iconWidth)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-margin-[volumeButton(iconHeight)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            // インライン化ボタン - 右上に表示する
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:[exitFullscreenButton(iconWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-margin-[exitFullscreenButton(iconHeight)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            // 動画広告情報ラベル - 左下に表示する
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[adInfoLabel(120)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:[adInfoLabel(12)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            // リプレイボタン - 左下に表示する
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:|-margin-[replayButton(iconWidth)]", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:[replayButton(iconHeight)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            
            // スキップボタン - 右中央に表示する
            let spacerTop = UIView(); spacerTop.hidden = true; spacerTop.translatesAutoresizingMaskIntoConstraints = false
            let spacerBottom = UIView(); spacerBottom.hidden = true; spacerBottom.translatesAutoresizingMaskIntoConstraints = false
            let viewsWithSkipbutton: [String: UIView] = ["skipButton": self.skipButton, "st": spacerTop, "sb": spacerBottom]
            self.addSubview(spacerTop)
            self.addSubview(spacerBottom)
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:[skipButton(iconWidth)]-margin-|", options: NSLayoutFormatOptions(), metrics: self.metrics, views: self.views))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|[st(>=1)]-(<=0)-[skipButton(iconHeight)]-(<=0)-[sb(st)]|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: self.metrics, views: viewsWithSkipbutton))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:[st]|", options: NSLayoutFormatOptions(), metrics: nil, views: viewsWithSkipbutton))
            layoutConstraints.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("H:[sb]|", options: NSLayoutFormatOptions(), metrics: nil, views: viewsWithSkipbutton))
            
            self.layoutConstraints = layoutConstraints
        }
        
        dacsdkmaActivateConstraints(self.layoutConstraints, view: self)
    }
    
}