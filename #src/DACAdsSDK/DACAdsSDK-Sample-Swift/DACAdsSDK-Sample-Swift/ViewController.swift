//
//  ViewController.swift
//  DACAdsSDK-Sample-Swift
//
//  Copyright © 2016 D.A.Consortium Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DASMediationViewDelegate {
    
    let placementID : UInt = 18859 //placementIDを設定します。

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mediationView: DASMediationView = DASMediationView(
            frame: CGRect(x: 0,y: 20,width: 320,height: 50),
            placementID: self.placementID)
        mediationView.delegate = self
        
        self.view.addSubview(mediationView)
    }

    // MARK: - DASMediationViewDelegate
    
    // メディエーションビューが表示される直前に呼ばれます。
    @objc(dacMediationViewWillAppear:)
    func dacMediationViewWillAppear(_ mediationView: DASMediationView!) {
    }
    
    // メディエーションビューが表示された直後に呼ばれます。
    @objc(dacMediationViewDidAppear:)
    func dacMediationViewDidAppear(_ mediationView: DASMediationView!) {
    }
    
    // メディエーションビューが非表示になる直前に呼ばれます。
    @objc(dacMediationViewWillDisappear:)
    func dacMediationViewWillDisappear(_ mediationView: DASMediationView!) {
    }
    
    // メディエーションビューが非表示になった直後に呼ばれます。
    @objc(dacMediationViewDidDisappear:)
    func dacMediationViewDidDisappear(_ mediationView: DASMediationView!) {
    }
    
    // メディエーションビュー内に広告がロードされたタイミングで呼ばれます。
    @objc(dacMediationViewWillLoadAd:)
    func dacMediationViewWillLoadAd(_ mediationView: DASMediationView!) {
    }
    
    // メディエーションビュー内に広告がロードされたタイミングで呼ばれます。
    @objc(dacMediationViewDidLoadAd:)
    func dacMediationViewDidLoadAd(_ mediationView: DASMediationView!) {
    }
    
    // メディエーションビュー内の広告がタップされたタイミングで呼ばれます。
    @objc(dacMediationViewDidClicked:)
    func dacMediationViewDidClicked(_ mediationView: DASMediationView!) {
    }
}

