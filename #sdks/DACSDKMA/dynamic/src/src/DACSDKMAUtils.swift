//
//  DACSDKMAUtils.swift
//  DACSDKMA
//
//  Copyright (c) 2016 D.A.Consortium Inc. All rights reserved.
//

import Foundation
import UIKit


// --------------------------------------------------
// MARK: - class
// --------------------------------------------------
@objc
open class DACSDKMAUtilTimer: NSObject {
    // --------------------------------------------------
    // MARK: property
    // --------------------------------------------------
    open var timer: Timer? { return self._timer }
    open var isAutoPause: Bool = true
    
    // --------------------------------------------------
    // MARK: functions
    // --------------------------------------------------
    open func resume() {
        if let pauseDate: Date = self.pauseDate, let lastFireDate: Date = self.lastFireDate {
            let pauseTime: TimeInterval = -1 * pauseDate.timeIntervalSinceNow
            self.timer?.fireDate = Date(timeInterval: pauseTime, since: lastFireDate)
            self.pauseDate = nil
            self.lastFireDate = nil
        }
    }
    
    open func pause() {
        if nil == self.lastFireDate {
            self.lastFireDate = self.timer?.fireDate
            self.pauseDate = Date()
            self.timer?.fireDate = Date.distantFuture
        }
    }
    
    open func invalidate() {
        self.timer?.invalidate()
        self._timer = nil
        self.block = nil
        self.pauseDate = nil
        self.lastFireDate = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    // --------------------------------------------------
    // MARK: life cycle
    // --------------------------------------------------
    @available(*, unavailable)
    override private init() {
        fatalError("init() has not been implemented")
    }
    
    public init(timeInterval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Swift.Void) {
        super.init()
        
        self._timer = Timer.scheduledTimer(
            timeInterval: timeInterval,
            target: self,
            selector: #selector(self.update(timer:)),
            userInfo: nil,
            repeats: repeats
        )
        self.repeats = repeats
        self.block = block
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.applicationWillEnterForegroundNotified(notification:)),
            name: NSNotification.Name.UIApplicationWillEnterForeground,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.applicationDidEnterBackgroundNotified(notification:)),
            name: NSNotification.Name.UIApplicationDidEnterBackground,
            object: nil
        )
    }
    
    deinit {
        self.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    // --------------------------------------------------
    // MARK: Timer Update
    // --------------------------------------------------
    @objc
    private func update(timer: Timer) {
        if let block = self.block {
            if !(self.repeats) {
                self.invalidate()
            }
            
            block(timer)
        }
    }
    
    // --------------------------------------------------
    // MARK: NotificationCenter observe
    // --------------------------------------------------
    /// アプリがフォアグラウンドになる。
    @objc
    private func applicationWillEnterForegroundNotified(notification: Notification) {
        if self.isAutoPause {
            self.resume()
        }
    }
    
    /// アプリがバックグラウンドになった。
    @objc
    private func applicationDidEnterBackgroundNotified(notification: Notification) {
        if self.isAutoPause {
            self.pause()
        }
    }
    
    // --------------------------------------------------
    // MARK: private property
    // --------------------------------------------------
    private var _timer: Timer? = nil
    private var repeats: Bool = false
    private var block: ((Timer) -> Swift.Void)? = nil
    private var pauseDate: Date? = nil
    private var lastFireDate: Date? = nil
}
