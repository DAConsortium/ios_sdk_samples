# DAC Ads SDK for iOS
- - -
本マニュアルはDACAdsSDKをSwiftで記述されたプロジェクトに組み込む際のマニュアルとなります。

## 必要なツール,DACライブラリ
* Xcode : 7.3+
* iOS   : 7.0+
* DACAdsSDK(iOS)

## ソースコード組み込み手順
以下はサンプルコードをそのまま使った場合の例になります。 カスタマイズが必要な場合はサンプルコードを参考にして, 変更して下さい。

### Step 1: XcodeプロジェクトにSDKを追加します
Xcode Projectを開きます。  
プロジェクトにDACAdsSDKフォルダを追加します。（ドラッグ&ドロップで可能です。）"Choose options for adding these files"は"Added folders"は"Create groups"を選択し、"Finish" をクリックします。
メインプロジェクトのプロジェクトエディタを起動し、ターゲットをクリックします。
- [General]->[Linked Frameworks and Libraries]セクションを開き、左下の "+"をクリックします。  
"Add Other..."をクリックし、DACAdsSDKフォルダ内libDACAdsSDKを選択します。
"Linked Frameworks and Libraries"にDACSDKMA.frameworkが追加されます。
- [PROJET か 指定したターゲット]->[Build Settings]->[Serch Paths]->[Library Serch Paths]をクリックし、DACSDKMA.frameworkがあるフォルダを追加します。

### Step 2: Bridging-Hedderファイルを作成します。
Objective-CのライブラリをSwiftのプロジェクトで使用するためにBridging-Hdderファイルを作成します。
[File]->[New]->[file]から[Hedder File]を選択し、<#ProductName#>-Bridging-Hedderという名前で保存します。

### Step 3: frameworkをインポートします
作成したBridging-Hedder内にframeworkをインポートします。

```<#ProductName#>-Bridging-Hedder.h
#import "DASMediationView.h"
#import "DACAdsSDK.h"
```

### Step 4: 広告をリクエストします

- "ViewController"に次の変数を追加します。

```ViewController.swift
    let placementID : UInt = 1 //placementIDを設定しまうs。
```

- 適当なタイミングで広告をリクエストします。

```ViewController.swift
        let mediationView :DASMediationView = DASMediationView(frame: CGRectMake(0,20,320,50),placementID:placementID)
        mediationView.delegate = self
        self.view.addSubview(mediationView)
```

### Step 5: delegateを継承します
- 必要に応じて"ViewController"に以下の"delegate protocol"を継承し、"delegateメソッド"を追加します。

```ViewController.swift
class ViewController: UIViewController,DASMediationViewDelegate {

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
```

### Step 6. 動作確認をします
正しく広告が表示されることを確認して下さい。