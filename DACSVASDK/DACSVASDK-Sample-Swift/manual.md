# DACSDKMASmartVisionAdPlayer (iOS)
- - -
本マニュアルはDACSDKMASmartVisionAdPlayerを使用して、Swiftで記述されたプロジェクトに広告を表示させる際ののマニュアルとなります。

## 必要なツール・DACライブラリ
* Xcode：7.3+
* iOS：8.0+
* DACMultimediaAdsSDK(iOS)
 * dynamic/DACSDKMA.framework
 * dynamic/src

## ソースコード組み込み手順
以下はサンプルコードをそのまま使った場合の例になります。カスタマイズが必要な場合はサンプルコードを参考にして変更して下さい。
また、今回の手順ではプリロールかつ自動再生のみ流すことが可能です。

### Step 1: XcodeプロジェクトにSDKを追加します
Xcode Projectを開きます。  
メインプロジェクトのプロジェクトエディタを起動し、ターゲットをクリックします。
- [General]->[Embedded Binaries]セクションを開き、左下の "+"をクリックします。  
"Add Other..."をクリックし、DACSDKMAフォルダ内dynamic/DACSDKMA.frameworkを選択します。
"Choose options for adding these files"は"Added folders"は"Create groups"を選択し、"Finish" をクリックします。  
"Linked Frameworks and Libraries"にDACSDKMA.frameworkが追加されます。
"Embedded Binaries" にDACSDKMA.frameworkが追加されます。
- [PROJET か 指定したターゲット]->[Build Settings]->[Serch Paths]->[framework Serch Paths]をクリックし、DACSDKMA.frameworkがあるフォルダを追加します。
DACSDKMAフォルダ内srcフォルダをプロジェクトに追加します。（ドラッグ&ドロップで可能です。）"Choose options for adding these files"は"Added folders"は"Create groups"を選択し、"Finish" をクリックします。  

### Step 2: frameworkをインポートします
- 広告を表示する"ViewController"に以下の記述を加えます。

```ViewController.swift
import DACSDKMA
```

### Step 3: DACSDKMASmartVisionAdPlayerを作成します。

- "ViewController"に次の変数を追加します。

```ViewController.swift
let adTagUri = "https://..."
```

- 適当なタイミングでDACSDKMASmartVisionAdPlayerを作成します。

```ViewController.swift
        let dacSDKMABasicVideoPlayer: DACSDKMASmartVisionAdPlayer = DACSDKMASmartVisionAdPlayer(frame: CGRectMake(10, 20, 320, 250))
        dacSDKMABasicVideoPlayer.delegate = self
        dacSDKMABasicVideoPlayer.load(self.adTagUri)
        self.view.addSubview(dacSDKMABasicVideoPlayer)
```

### Step 4: DACSDKMASmartVisionAdPlayerDelegateを継承します
- "ViewController"に"DACSDKMASmartVisionAdPlayerDelegate"を継承し、"delegateメソッド"を追加します。

```ViewController.swift
class ViewController: UIViewController, DACSDKMASmartVisionAdPlayerDelegate {

    // SDKからイベントを受け取った
    @objc func dacSdkMaSmartVisionAdPlayer(smartVisionAdPlayer: DACSDKMASmartVisionAdPlayer, DidReceiveAdEvent adEvent: DACSDKMAAdEvent) {
        NSLog("event = \(adEvent.name)")
    }
    
    // SDKからエラーを受け取った
    @objc func dacSdkMaSmartVisionAdPlayer(smartVisionAdPlayer: DACSDKMASmartVisionAdPlayer, DidReceiveAdError adError: DACSDKMAAdError) {
        NSLog("error = \(adError.message)")
    }
}
```

### Step 5. 動作確認をします
正しく広告が表示されることを確認して下さい。