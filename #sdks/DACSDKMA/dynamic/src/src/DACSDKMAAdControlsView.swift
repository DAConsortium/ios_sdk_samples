//
//  DACSDKMAAdControlsView.swift
//  DACSDKMA
//
//  Copyright (c) 2015 D.A.Consortium Inc. All rights reserved.
//

import UIKit
import DACSDKMA


// --------------------------------------------------
// MARK: - delegate
// --------------------------------------------------
/// 広告操作ビュークラス・デリゲート
@objc
public protocol DACSDKMAAdControlsViewDelegate: class {
    /**
     動画広告表示領域がクリックされた。
     */
    @objc optional func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickPlayerView view: UIView)
    
    /**
     音量ボタンがクリックされた。
     */
    @objc optional func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickVolumeButton button: UIButton)
    
    /**
     再生・一時停止ボタンがクリックされた。
     */
    @objc optional func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickPlayButton button: UIButton)
    
    /**
     リプレイボタンがクリックされた。
     */
    @objc optional func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickReplayButton button: UIButton)
    
    /**
     フルスクリーン化ボタンがクリックされた。
     */
    @objc optional func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickEnterFullscreenButton button: UIButton)

    /**
     インライン化ボタンがクリックされた。
     */
    @objc optional func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickExitFullscreenButton button: UIButton)
    
    /**
     Xボタンがクリックされた。
     */
    @objc optional func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickCloseButton button: UIButton)
    
    /**
     リンクボタンがクリックされた。
     */
    @objc optional func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickLinkButton button: UIButton)
    
    /**
     スキップボタンがクリックされた。
     */
    @objc optional func dacsdkmaAdControlsView(_ adControlsView: DACSDKMAAdControlsView, didClickSkipButton button: UIButton)
}


// --------------------------------------------------
// MARK: - class
// --------------------------------------------------
/// 広告操作ビュークラス
@objc
open class DACSDKMAAdControlsView: UIView {

    // --------------------------------------------------
    // MARK: static property
    // --------------------------------------------------

    // ----- GUI -----
    /// アイコン/ラベルのデフォルト・マージン
    open static let DefaultMargin: CGFloat = 6.0
    
    /// アイコンのデフォルト・サイズ
    open static let DefaultIconSize: CGSize = CGSize(width: 20.0, height: 20.0)
    
    // --------------------------------------------------
    // MARK: property
    // --------------------------------------------------
    /// デリゲート
    open weak var delegate: DACSDKMAAdControlsViewDelegate? = nil
    
    /// AutoLayout用各種設定値
    open let metrics: [String: Any]
    
    /// AutoLayout用View
    open let views: [String: UIView]
    
    /// AutoLayout用設定
    open var layoutConstraints: [NSLayoutConstraint] = [NSLayoutConstraint]()
    
    /// 動画ビュー領域
    open let playerView: UIButton = UIButton()
        
    /// 再生・一時停止ボタン
    open let playButton: UIButton = UIButton()
    
    /// リプレイボタン
    open let replayButton: UIButton = UIButton()
    
    /// 音量切り替えボタン
    open let volumeButton: UIButton = UIButton()
    
    /// フルスクリーン化ボタン
    open let enterFullscreenButton: UIButton = UIButton()
    
    /// インライン化ボタン
    open let exitFullscreenButton: UIButton = UIButton()
    
    /// 閉じるボタン
    open let closeButton: UIButton = UIButton()
    
    /// リンクボタン
    open let linkButton: UIButton = UIButton()

    /// スキップボタン
    open let skipButton: UIButton = UIButton()
    
    /// PR画像ボタン
    open let prButton: UIButton = UIButton()
    
    /// 動画の再生可能時間ラベル
    open let durationLabel: UILabel = UILabel()
    
    /// 動画の経過時間ラベル
    open let progressTimeLabel: UILabel = UILabel()
    
    /// 再生位置ビュー
    open let progressView: UIProgressView = UIProgressView(progressViewStyle: UIProgressViewStyle.default)
    
    open let adInfoLabel: UILabel = UILabel()
    
    /// 再生位置 (0.f〜1.f)
    open var progress: Float {
        get { return self.progressView.progress }
        set { self.progressView.progress = newValue }
    }
    
    /// 再生中か否か
    open var isPlaying: Bool {
        get { return self.playButton.isSelected }
        set { self.playButton.isSelected = newValue }
    }
    
    /// 静音状態か否か
    open var isMute: Bool {
        get { return self.volumeButton.isSelected }
        set { self.volumeButton.isSelected = newValue }
    }
    
    /// 再生可能状態
    open var playbackStatus: DACSDKMAAdVideoPlaybackStates = DACSDKMAAdVideoPlaybackStates.unknown {
        willSet {
            switch(newValue) {
            case .playing:
                self.playButton.isHidden = false
                self.replayButton.isHidden = true
                self.isPlaying = true
                break
            case .pausing:
                self.playButton.isHidden = false
                self.replayButton.isHidden = true
                self.isPlaying = false
                break
            case .stopped:
                self.playButton.isHidden = true
                self.replayButton.isHidden = false
                self.isPlaying = false
                
                // スキップボタンは非表示とする。
                self.skipButton.isHidden = true                
                break
            case .unknown:
                self.playButton.isHidden = true
                self.replayButton.isHidden = true
                self.isPlaying = false
                break
            }
        }
    }
    
    
    // --------------------------------------------------
    // MARK: life cycle
    // --------------------------------------------------
    @nonobjc
    @available(*, unavailable)    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public init(frame: CGRect) {
        
        self.metrics = [
            "margin": DACSDKMAAdControlsView.DefaultMargin,
            "iconWidth": DACSDKMAAdControlsView.DefaultIconSize.width,
            "iconHeight": DACSDKMAAdControlsView.DefaultIconSize.height,
        ]
        
        self.views = [
            "playButton"            : self.playButton,
            "replayButton"          : self.replayButton,
            "volumeButton"          : self.volumeButton,
            "enterFullscreenButton" : self.enterFullscreenButton,
            "exitFullscreenButton"  : self.exitFullscreenButton,
            "closeButton"           : self.closeButton,
            "linkButton"            : self.linkButton,
            "skipButton"            : self.skipButton,
            "prButton"              : self.prButton,
            "durationLabel"         : self.durationLabel,
            "progressTimeLabel"     : self.progressTimeLabel,
            "progressView"          : self.progressView,
            "adInfoLabel"           : self.adInfoLabel,
        ]
        
        super.init(frame: frame)

        self.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // 動画ビュー領域
        self.playerView.addTarget(self, action:#selector(DACSDKMAAdControlsView.playerViewAction(_:)), for:UIControlEvents.touchUpInside)
        self.addSubview(self.playerView)
        self.sendSubview(toBack: self.playerView)
        
        // 動画広告の情報
        self.adInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        self.adInfoLabel.text = ""
        self.adInfoLabel.textAlignment = NSTextAlignment.left
        self.adInfoLabel.textColor = UIColor.white
        self.adInfoLabel.shadowColor = UIColor.black
        self.adInfoLabel.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.adInfoLabel.font = UIFont.systemFont(ofSize: 12)
        
        // 動画の再生可能時間
        self.durationLabel.translatesAutoresizingMaskIntoConstraints = false
        self.durationLabel.text = "0:00"
        self.durationLabel.textAlignment = NSTextAlignment.left
        self.durationLabel.textColor = UIColor.white
        self.durationLabel.shadowColor = UIColor.black
        self.durationLabel.shadowOffset = CGSize(width: 1.0, height: 1.0)
        
        // 再生時間
        self.progressTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.progressTimeLabel.text = "0:00"
        self.progressTimeLabel.textAlignment = NSTextAlignment.right
        self.progressTimeLabel.textColor = UIColor.white
        self.progressTimeLabel.shadowColor = UIColor.black
        self.progressTimeLabel.shadowOffset = CGSize(width: 1.0, height: 1.0)
        
        // 動画プログレスバー
        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        
        // 最大化ボタン
        self.enterFullscreenButton.translatesAutoresizingMaskIntoConstraints = false
        self.enterFullscreenButton.addTarget(self, action: #selector(DACSDKMAAdControlsView.enterFullscreenAction(_:)), for:UIControlEvents.touchUpInside)
        self.enterFullscreenButton.setImage(DACSDKMAAdImageGenerator.enterFullscreenButtonIconImage, for: .normal)
        
        // 最大化終了ボタン
        self.exitFullscreenButton.translatesAutoresizingMaskIntoConstraints = false
        self.exitFullscreenButton.addTarget(self, action: #selector(DACSDKMAAdControlsView.exitFullscreenAction(_:)), for:UIControlEvents.touchUpInside)        
        self.exitFullscreenButton.setImage(DACSDKMAAdImageGenerator.exitFullscreenButtonIconImage, for: .normal)

        // 閉じるボタン
        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.closeButton.addTarget(self, action: #selector(DACSDKMAAdControlsView.closeAction(_:)), for:UIControlEvents.touchUpInside)
        self.closeButton.setImage(DACSDKMAAdImageGenerator.closeButtonIconImage, for: .normal)

        // 音量切り替えボタン
        self.volumeButton.translatesAutoresizingMaskIntoConstraints = false
        self.volumeButton.addTarget(self, action: #selector(DACSDKMAAdControlsView.volumeAction(_:)), for:UIControlEvents.touchUpInside)
        self.volumeButton.setImage(DACSDKMAAdImageGenerator.volumeOnButtonIconImage, for: .normal)
        self.volumeButton.setImage(DACSDKMAAdImageGenerator.volumeOffButtonIconImage, for: .selected)
        
        // PRボタン
        self.prButton.translatesAutoresizingMaskIntoConstraints = false
        self.prButton.isEnabled = false
        self.prButton.setImage(DACSDKMAAdImageGenerator.prIconImage, for: .normal)

        // リンクボタン
        self.linkButton.translatesAutoresizingMaskIntoConstraints = false
        self.linkButton.addTarget(self, action: #selector(DACSDKMAAdControlsView.linkAction(_:)), for:UIControlEvents.touchUpInside)
        self.linkButton.setImage(DACSDKMAAdImageGenerator.linkButtonIconImage, for: .normal)

        // リプレイボタン
        self.replayButton.translatesAutoresizingMaskIntoConstraints = false
        self.replayButton.addTarget(self, action: #selector(DACSDKMAAdControlsView.replayAction(_:)), for:UIControlEvents.touchUpInside)
        self.replayButton.setImage(DACSDKMAAdImageGenerator.replayButtonIconImage, for: .normal)

        // 再生・一時停止ボタン
        self.playButton.translatesAutoresizingMaskIntoConstraints = false
        self.playButton.addTarget(self, action: #selector(DACSDKMAAdControlsView.playAction(_:)), for:UIControlEvents.touchUpInside)
        self.playButton.setImage(DACSDKMAAdImageGenerator.playButtonIconImage, for: .normal)
        self.playButton.setImage(DACSDKMAAdImageGenerator.pauseButtonIconImage, for: .selected)

        // スキップボタン
        self.skipButton.translatesAutoresizingMaskIntoConstraints = false
        self.skipButton.addTarget(self, action: #selector(DACSDKMAAdControlsView.skipAction(_:)), for:UIControlEvents.touchUpInside)
        self.skipButton.setImage(DACSDKMAAdImageGenerator.skipIconImage, for: .normal)
    }
    
    deinit {
        self.clean()
    }
    
    // --------------------------------------------------
    // MARK: function
    // --------------------------------------------------
    open func clean() {
        self.delegate = nil
        NSLayoutConstraint.deactivate(self.layoutConstraints)
        self.layoutConstraints = []
        self.removeFromSuperview()
        for view: UIView in self.views.values {
            view.removeFromSuperview()
            if let control: UIControl = view as? UIControl {
                control.removeTarget(nil, action: nil, for: .allEvents)
            }
        }
    }
    
    // --------------------------------------------------
    // MARK: override function
    // --------------------------------------------------
    /// 重なっているViewにタッチイベントを通知する。
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView: UIView? = super.hitTest(point, with: event)
        return (hitView == self ? nil : hitView)
    }
    
    // --------------------------------------------------
    // MARK: UIActions
    // --------------------------------------------------

    open func playerViewAction(_ sender: Any) {
        self.delegate?.dacsdkmaAdControlsView?(self, didClickPlayerView: self.playerView)
    }
    
    open func volumeAction(_ sender: Any) {
        self.isMute = !self.isMute
        self.delegate?.dacsdkmaAdControlsView?(self, didClickVolumeButton: self.volumeButton)
    }
    
    open func playAction(_ sender: Any) {
        self.isPlaying = !self.isPlaying
        self.delegate?.dacsdkmaAdControlsView?(self, didClickPlayButton: self.playButton)
    }
    
    open func replayAction(_ sender: Any) {
        self.delegate?.dacsdkmaAdControlsView?(self, didClickReplayButton: self.replayButton)
    }
    
    open func enterFullscreenAction(_ sender: Any) {
        self.delegate?.dacsdkmaAdControlsView?(self, didClickEnterFullscreenButton: self.enterFullscreenButton)
    }
    
    open func exitFullscreenAction(_ sender: Any) {
        self.delegate?.dacsdkmaAdControlsView?(self, didClickExitFullscreenButton: self.exitFullscreenButton)
    }
    
    open func closeAction(_ sender: Any) {
        self.delegate?.dacsdkmaAdControlsView?(self, didClickCloseButton: self.closeButton)
    }
    
    open func linkAction(_ sender: Any) {
        self.delegate?.dacsdkmaAdControlsView?(self, didClickLinkButton: self.linkButton)
    }
    
    open func skipAction(_ sender: Any) {
        self.delegate?.dacsdkmaAdControlsView?(self, didClickSkipButton: self.skipButton)
    }
}
