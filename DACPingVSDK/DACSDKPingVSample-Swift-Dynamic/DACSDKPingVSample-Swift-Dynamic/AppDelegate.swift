//
//  AppDelegate.swift
//  DACSDKPingVSample-Swift-Dynamic
//
//  Copyright © 2016 D.A.Consortium Inc. All rights reserved.
//

import UIKit
import DACSDKPingV


let ownerID: String = "OwnerIDを設定してください"
let placementID: Int = 12345


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var eventCount: Int = 0

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        NSLog("----- applicationDidFinishLaunchingWithOptions -----")
        
        // --------------------------------------------------
        // MARK: DACSDKPingV 設定
        // --------------------------------------------------        
        // 初期化
        DACSDKPingV.shared.debugMode = false
        DACSDKPingV.shared.setup(oid: ownerID)
        
        // その他
        DACSDKPingV.shared.applicationDataCenter.autoSend = true
        DACSDKPingV.shared.applicationDataCenter.autoRestart = true
        
        DACSDKPingV.shared.applicationDataCenter.delegate = self
        DACSDKPingV.shared.applicationDataCenter.page_id = "sample"
        _ = DACSDKPingV.shared.applicationDataCenter.replaceExtras([
            "dev language": "swift",
            "library type": "static-framework",
            ])
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        NSLog("----- applicationWillResignActive -----")
        
        // --------------------------------------------------
        // MARK: DACSDKPingV event_ids 設定
        // --------------------------------------------------
        let formatter: DateFormatter = DateFormatter()
        formatter.timeStyle = .short
        let dateString : String = formatter.string(from: Date())
        DACSDKPingV.shared.applicationDataCenter.event_ids = [dateString, "swift", String(self.eventCount)]
        self.eventCount = self.eventCount + 1
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        NSLog("----- applicationDidEnterBackground -----")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        NSLog("----- applicationWillEnterForeground -----")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        NSLog("----- applicationDidBecomeActive -----")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        NSLog("----- applicationWillTerminate -----")
    }
    
}

// --------------------------------------------------
// MARK: DACSDKPingVDelegate
// --------------------------------------------------
extension AppDelegate: DACSDKPingVApplicationDataCenterDelegate {
    func dacSdkPingV(applicationDataCenter: DACSDKPingVApplicationDataCenter, didSendApplicationDataWithError error: Error?) {
        if let error: Error = error {
            NSLog("ping failed: error = \(error).")
        }
        else {
            NSLog("ping succeeded.")
        }
    }
}

