//
//  ViewController.swift
//  DACAdsSDK-Sample-Swift
//
//  Copyright © 2015年 D.A.Consortium Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController,DASMediationViewDelegate {
    
    let placementID : UInt = 18859 //placementIDを設定します。

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let mediationView :DASMediationView = DASMediationView(frame: CGRectMake(0,20,320,50),placementID:placementID)
        mediationView.delegate = self
        self.view.addSubview(mediationView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //メディエーションビューが表示される直前に呼ばれます。
    func DACMediationViewWillAppear(mediationView: DASMediationView!) {
        
    }
    
    //メディエーションビューが表示された直後に呼ばれます。
    func DACMediationViewDidAppear(mediationView: DASMediationView!) {
        
    }
    
    //メディエーションビューが非表示になる直前に呼ばれます。
    func DACMediationViewWillDisappear(mediationView: DASMediationView!) {
    }
    
    //メディエーションビューが非表示になった直後に呼ばれます。
    func DACMediationViewDidDisappear(mediationView: DASMediationView!) {
    }
    
    //メディエーションビュー内に広告がロードされたタイミングで呼ばれます。
    func DACMediationViewDidLoadAd(mediationView: DASMediationView!) {
        
    }
    
    //メディエーションビュー内の広告がタップされたタイミングで呼ばれます。
    func DACMediationViewDidClicked(mediationView: DASMediationView!) {
    
    }
}

