//
//  DACSDKMAAdControlsView.swift
//  DACSDKMA
//
//  Copyright © 2016 D.A.Consortium Inc. All rights reserved.
//

import UIKit
import DACSDKMA

// --------------------------------------------------
// MARK: - methods
// --------------------------------------------------
/**
 AutoLayoutを有効にする。(iOS7対応)
 */
public func dacsdkmaActivateConstraints(layoutConstraints: [NSLayoutConstraint], view: UIView) {
    // iOS8以降のみターゲットで警告が出る場合、以下の１行のみの記載で対応可能です。それ以外の行は不要です。
    // NSLayoutConstraint.activateConstraints(layoutConstraints)
    
    if #available(iOS 8.0, *) {
        // iOS 8 or later
        NSLayoutConstraint.activateConstraints(layoutConstraints)
    }
    else {
        // iOS 7.1 or earlier
        view.addConstraints(layoutConstraints)
    }
}

/**
 AutoLayoutを無効にする。(iOS7対応)
 */
public func dacsdkmaDeactivateConstraints(layoutConstraints: [NSLayoutConstraint], view: UIView) {
    // iOS8以降のみターゲットで警告が出る場合、以下の１行のみの記載で対応可能です。それ以外の行は不要です。
    // NSLayoutConstraint.deactivateConstraints(layoutConstraints)
    
    if #available(iOS 8.0, *) {
        NSLayoutConstraint.deactivateConstraints(layoutConstraints)
    }
    else {
        // iOS 7.1 or earlier
        view.removeConstraints(layoutConstraints)
    }
}


// --------------------------------------------------
// MARK: - delegate
// --------------------------------------------------
/// 広告操作ビュークラス・デリゲート
@objc
public protocol DACSDKMAAdControlsViewDelegate: class {
    /**
     動画広告表示領域がクリックされた。
     */
    optional func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickPlayerView view: UIView)
    
    /**
     音量ボタンがクリックされた。
     */
    optional func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickVolumeButton button: UIButton)
    
    /**
     再生・一時停止ボタンがクリックされた。
     */
    optional func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickPlayButton button: UIButton)
    
    /**
     リプレイボタンがクリックされた。
     */
    optional func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickReplayButton button: UIButton)
    
    /**
     フルスクリーン化ボタンがクリックされた。
     */
    optional func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickEnterFullscreenButton button: UIButton)

    /**
     インライン化ボタンがクリックされた。
     */
    optional func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickExitFullscreenButton button: UIButton)
    
    /**
     Xボタンがクリックされた。
     */
    optional func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickCloseButton button: UIButton)
    
    /**
     詳細を見るボタンがクリックされた。
     */
    optional func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickDetailButton button: UIButton)
    
    /**
     スキップボタンがクリックされた。
     */
    optional func adControlsView(adControlsView: DACSDKMAAdControlsView, DidClickSkipButton button: UIButton)
}


// --------------------------------------------------
// MARK: - class
// --------------------------------------------------
/// 広告操作ビュークラス
@objc
public class DACSDKMAAdControlsView: UIView {

    // --------------------------------------------------
    // MARK: static properties
    // --------------------------------------------------

    // ----- GUI -----
    /// アイコン/ラベルのデフォルト・マージン
    public static let DefaultMargin: CGFloat = 6.0
    
    /// アイコンのデフォルト・サイズ
    public static let DefaultIconSize: CGSize = CGSizeMake(24.0, 24.0)
    
    /// ラベルのデフォルト・サイズ
    public static let DefaultLabelSize: CGSize = CGSizeMake(82.0, 24.0)
    
    /// Closeボタンのデフォルト・サイズ
    public static let ExitFullscreenLabelSize: CGSize = CGSizeMake(57.0, 24.0)
    

    // --------------------------------------------------
    // MARK: properties
    // --------------------------------------------------
    public var delegate: DACSDKMAAdControlsViewDelegate? = nil
    
    /// AutoLayout用各種設定値
    public let metrics: [String: AnyObject]!
    
    /// AutoLayout用View
    public let views: [String: UIView]!
    
    /// AutoLayout用設定
    public var layoutConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
    
    /// 動画ビュー領域
    public let playerView: UIButton = UIButton()
        
    /// 再生・一時停止ボタン
    public let playButton: UIButton = UIButton()
    
    /// リプレイボタン
    public let replayButton: UIButton = UIButton()
    
    /// 音量切り替えボタン
    public let volumeButton: UIButton = UIButton()
    
    /// フルスクリーン化ボタン
    public let enterFullscreenButton: UIButton = UIButton()
    
    /// インライン化ボタン
    public let exitFullscreenButton: UIButton = UIButton()
    
    /// 閉じるボタン
    public let closeButton: UIButton = UIButton()
    
    /// 詳細を見るボタン
    public let detailButton: UIButton = UIButton()

    /// スキップボタン
    public let skipButton: UIButton = UIButton()
    
    /// PR画像ボタン
    public let prButton: UIButton = UIButton()
    
    /// 動画の再生可能時間ラベル
    public let durationLabel: UILabel = UILabel()
    
    /// 動画の経過時間ラベル
    public let progressTimeLabel: UILabel = UILabel()
    
    /// 再生位置ビュー
    public let progressView: UIProgressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)
    
    public let adInfoLabel: UILabel = UILabel()
    
    /// 再生位置 (0.f〜1.f)
    public var progress: Float {
        get { return self.progressView.progress }
        set { self.progressView.progress = newValue }
    }
    
    /// 再生中か否か
    public var isPlaying: Bool {
        get { return self.playButton.selected }
        set { self.playButton.selected = newValue }
    }
    
    /// 静音状態か否か
    public var isMute: Bool {
        get { return self.volumeButton.selected }
        set { self.volumeButton.selected = newValue }
    }
    
    /// 再生可能状態
    public var playbackStatus: DACSDKMAAdVideoPlaybackStates = DACSDKMAAdVideoPlaybackStates.Unknown {
        willSet {
            switch(newValue) {
            case .Playing:
                self.playButton.hidden = false
                self.replayButton.hidden = true
                self.isPlaying = true
                break
            case .Pausing:
                self.playButton.hidden = false
                self.replayButton.hidden = true
                self.isPlaying = false
                break
            case .Stopped:
                self.playButton.hidden = true
                self.replayButton.hidden = false
                self.isPlaying = false
                
                // スキップボタンは非表示とする。
                self.skipButton.hidden = true                
                break
            case .Unknown:
                self.playButton.hidden = true
                self.replayButton.hidden = true
                self.isPlaying = false
                break
            }
        }
    }
    
    
    // --------------------------------------------------
    // MARK: life cycle
    // --------------------------------------------------

    @available(*, unavailable)    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init(frame: CGRect) {
        
        self.metrics = [
            "margin": DACSDKMAAdControlsView.DefaultMargin,
            "iconWidth": DACSDKMAAdControlsView.DefaultIconSize.width,
            "iconHeight": DACSDKMAAdControlsView.DefaultIconSize.height,
            "labelWidth": DACSDKMAAdControlsView.DefaultLabelSize.width,
            "labelHeight": DACSDKMAAdControlsView.DefaultLabelSize.height,
            "exitFullscreenLabelWidth": DACSDKMAAdControlsView.ExitFullscreenLabelSize.width,
            "exitFullscreenLabelHeight": DACSDKMAAdControlsView.ExitFullscreenLabelSize.height,
        ]
        
        self.views = [
            "playButton"            : self.playButton,
            "replayButton"          : self.replayButton,
            "volumeButton"          : self.volumeButton,
            "enterFullscreenButton" : self.enterFullscreenButton,
            "exitFullscreenButton"  : self.exitFullscreenButton,
            "closeButton"           : self.closeButton,
            "detailButton"          : self.detailButton,
            "skipButton"            : self.skipButton,
            "prButton"              : self.prButton,
            "durationLabel"         : self.durationLabel,
            "progressTimeLabel"     : self.progressTimeLabel,
            "progressView"          : self.progressView,
            "adInfoLabel"           : self.adInfoLabel,
        ]
        
        super.init(frame: frame)

        self.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        // 動画ビュー領域
        self.playerView.addTarget(self, action:#selector(DACSDKMAAdControlsView.playerViewAction(_:)), forControlEvents:UIControlEvents.TouchUpInside)
        self.addSubview(self.playerView)
        self.sendSubviewToBack(self.playerView)
        
        // 動画広告の情報
        self.adInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        self.adInfoLabel.text = ""
        self.adInfoLabel.textAlignment = NSTextAlignment.Left
        self.adInfoLabel.textColor = UIColor.whiteColor()
        self.adInfoLabel.shadowColor = UIColor.blackColor()
        self.adInfoLabel.shadowOffset = CGSizeMake(1.0, 1.0)
        self.adInfoLabel.font = UIFont.systemFontOfSize(12)
        
        // 動画の再生可能時間
        self.durationLabel.translatesAutoresizingMaskIntoConstraints = false
        self.durationLabel.text = "0:00"
        self.durationLabel.textAlignment = NSTextAlignment.Left
        self.durationLabel.textColor = UIColor.whiteColor()
        self.durationLabel.shadowColor = UIColor.blackColor()
        self.durationLabel.shadowOffset = CGSizeMake(1.0, 1.0)
        
        // 再生時間
        self.progressTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.progressTimeLabel.text = "0:00"
        self.progressTimeLabel.textAlignment = NSTextAlignment.Right
        self.progressTimeLabel.textColor = UIColor.whiteColor()
        self.progressTimeLabel.shadowColor = UIColor.blackColor()
        self.progressTimeLabel.shadowOffset = CGSizeMake(1.0, 1.0)
        
        // 動画プログレスバー
        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        
        // 最大化ボタン
        self.enterFullscreenButton.translatesAutoresizingMaskIntoConstraints = false
        self.enterFullscreenButton.addTarget(self, action: #selector(DACSDKMAAdControlsView.enterFullscreenAction(_:)), forControlEvents:UIControlEvents.TouchUpInside)
        
        // 最大化終了ボタン
        self.exitFullscreenButton.translatesAutoresizingMaskIntoConstraints = false
        self.exitFullscreenButton.addTarget(self, action: #selector(DACSDKMAAdControlsView.exitFullscreenAction(_:)), forControlEvents:UIControlEvents.TouchUpInside)
        
        // 閉じるボタン
        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.closeButton.addTarget(self, action: #selector(DACSDKMAAdControlsView.closeAction(_:)), forControlEvents:UIControlEvents.TouchUpInside)
        
        // 音量切り替えボタン
        self.volumeButton.translatesAutoresizingMaskIntoConstraints = false
        self.volumeButton.addTarget(self, action: #selector(DACSDKMAAdControlsView.volumeAction(_:)), forControlEvents:UIControlEvents.TouchUpInside)
        
        // PRボタン
        self.prButton.translatesAutoresizingMaskIntoConstraints = false
        self.prButton.enabled = false
        
        // 詳細ボタン
        self.detailButton.translatesAutoresizingMaskIntoConstraints = false
        self.detailButton.addTarget(self, action: #selector(DACSDKMAAdControlsView.detailAction(_:)), forControlEvents:UIControlEvents.TouchUpInside)
        
        // リプレイボタン
        self.replayButton.translatesAutoresizingMaskIntoConstraints = false
        self.replayButton.addTarget(self, action: #selector(DACSDKMAAdControlsView.replayAction(_:)), forControlEvents:UIControlEvents.TouchUpInside)
        
        // 再生・一時停止ボタン
        self.playButton.translatesAutoresizingMaskIntoConstraints = false
        self.playButton.addTarget(self, action: #selector(DACSDKMAAdControlsView.playAction(_:)), forControlEvents:UIControlEvents.TouchUpInside)
        
        // スキップボタン
        self.skipButton.translatesAutoresizingMaskIntoConstraints = false
        self.skipButton.addTarget(self, action: #selector(DACSDKMAAdControlsView.skipAction(_:)), forControlEvents:UIControlEvents.TouchUpInside)
    }
    
    deinit {
    }
    
    
    // --------------------------------------------------
    // MARK: UIActions
    // --------------------------------------------------

    public func playerViewAction(sender: AnyObject) {
        self.delegate?.adControlsView?(self, DidClickPlayerView: self.playerView)
    }
    
    public func volumeAction(sender: AnyObject) {
        self.isMute = !self.isMute
        self.delegate?.adControlsView?(self, DidClickVolumeButton: self.volumeButton)
    }
    
    public func playAction(sender: AnyObject) {
        self.isPlaying = !self.isPlaying
        self.delegate?.adControlsView?(self, DidClickPlayButton: self.playButton)
    }
    
    public func replayAction(sender: AnyObject) {
        self.delegate?.adControlsView?(self, DidClickReplayButton: self.replayButton)
    }
    
    public func enterFullscreenAction(sender: AnyObject) {
        self.delegate?.adControlsView?(self, DidClickEnterFullscreenButton: self.enterFullscreenButton)
    }
    
    public func exitFullscreenAction(sender: AnyObject) {
        self.delegate?.adControlsView?(self, DidClickExitFullscreenButton: self.exitFullscreenButton)
    }
    
    public func closeAction(sender: AnyObject) {
        self.delegate?.adControlsView?(self, DidClickCloseButton: self.closeButton)
    }
    
    public func detailAction(sender: AnyObject) {
        self.delegate?.adControlsView?(self, DidClickDetailButton: self.detailButton)
    }
    
    public func skipAction(sender: AnyObject) {
        self.delegate?.adControlsView?(self, DidClickSkipButton: self.skipButton)
    }
}
