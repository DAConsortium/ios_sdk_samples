# DAC Multimedia Ads SDK (iOS)
- - -
本マニュアルはDACMASDKをBrightcove-Player-SDKを使ったSwiftのプロジェクトに組み込む際のマニュアルになります。

## 必要なツール・DACライブラリ
* Xcode：7.3+
* iOS：8.0+
* DACMultimediaAdsSDK(iOS)
 * dynamic/DACSDKMA.framework
 * dynamic/src 
* Brightcove-Player-SDK

## ソースコード組み込み手順
以下はサンプルコードをそのまま使った場合の例になります。カスタマイズが必要な場合はサンプルコードを参考にして変更して下さい。
また、今回の手順ではプリロールかつ自動再生のみ流すことが可能です。

### Step 1:BrightcovePlayerSDKをフォルダ内に配置します。
本サンプル（DACAdsSDK-FBAudienceNetwork-Sample-ObjectiveC.xcodeproj）があるフォルダ内に、BrightcovePlayerSDKを配置してください。


### Step 2: XcodeプロジェクトにSDKを追加します
Xcode Projectを開きます。  
メインプロジェクトのプロジェクトエディタを起動し、ターゲットをクリックします。
- [General]->[Embedded Binaries]セクションを開き、左下の "+"をクリックします。  
"Add Other..."をクリックし、DACSDKMAフォルダ内dynamic/DACSDKMA.frameworkを選択します。
"Choose options for adding these files"は"Added folders"は"Create groups"を選択し、"Finish" をクリックします。  
"Linked Frameworks and Libraries"にDACSDKMA.frameworkが追加されます。
"Embedded Binaries" にDACSDKMA.frameworkが追加されます。
- [PROJET か 指定したターゲット]->[Build Settings]->[Serch Paths]->[framework Serch Paths]をクリックし、DACSDKMA.frameworkがあるフォルダを追加します。
DACSDKMAフォルダ内srcフォルダをプロジェクトに追加します。（ドラッグ&ドロップで可能です。）"Choose options for adding these files"は"Added folders"は"Create groups"を選択し、"Finish" をクリックします。  

### Step 3: frameworkをインポートします
- 広告を表示する"ViewController"に以下の記述を加えます。

```ViewController.swift
import DACSDKMA
```

### Step 4: 広告をリクエストします

- "ViewController"に次の変数を追加します。

```ViewController.swift
let adTagUri = "https://..."
var dacAdsLoader: DACSDKMAAdsLoader?  = nil
var dacAdsManager: DACSDKMAAdsManager? = nil
var dacAdController: DACSDKMAAdController? = nil
```

- 適当なタイミングで広告をリクエストします。

```ViewController.swift
let maSettings: DACSDKMASettings = DACSDKMASettings()

self.dacAdsLoader = DACSDKMAAdsLoader(settings: maSettings)
self.dacAdsLoader!.delegate = self
        
//広告動画を掲載するViewとリクエスト先アドサーバのURLをリクエストにセットする
let adContainer: DACSDKMAAdContainer = DACSDKMAAdContainer(view: self.videoView!)
let request = DACSDKMAAdsRequest(adTagURI: self.adTagUri, adContainer: adContainer)
self.dacAdsLoader!.requestAds(request)

```

### Step 5: delegateを継承します
- "ViewController"に以下の2つの"delegate protocol"を継承し、"delegateメソッド""を追加します。

```ViewController.swift
class ViewController: UIViewController, DACSDKMAAdsLoaderDelegate, DACSDKMAAdsManagerDelegate {
    /// VASTレスポンスの処理が終わった時に実行される
    func dacsdkmaAdsLoader(_ loader: DACSDKMAAdsLoader, didLoad adsLoadedData: DACSDKMAAdsLoadedData) {
        self.dacAdsManager = adsLoadedData.adsManager
        adsLoadedData.adsManager.delegate = self
        // 広告動画ファイルのダウンロードする
        adsLoadedData.adsManager.load()
        
        self.dacAdController = DACSDKMAAdController(adsManager: adsLoadedData.adsManager)
    }
    
    /// VASTリクエスト/レスポンスでエラーが呼ばれたときに実行される
    func dacsdkmaAdsLoader(_ loader: DACSDKMAAdsLoader, didFail adError: DACSDKMAAdError) {
        // エラーログを出力し、本編動画を再生する
        NSLog("dacSdkMaAdsLoader: didFaile: \(adError.message)")
        self.playbackController.play()
    }
    
    /// AdsManagerのイベントが発生した時に実行される
    func dacsdkmaAdsManager(_ adsManager: DACSDKMAAdsManager, didReceiveAdEvent adEvent: DACSDKMAAdEvent) {
        switch adEvent.type {
        case .didLoad:
            // 広告動画ファイルがダウンロードされたら、広告動画を再生する
            adsManager.play()
            break
        case .didComplete:
            // 広告動画が終了したら、広告を消去する
            adsManager.clean()
            self.dacAdController?.clean()
            break
        default:
            break
        }
    }
    
    /// AdsManagerにエラーが発生した時に実行される
    func dacsdkmaAdsManager(_ adsManager: DACSDKMAAdsManager, didReceiveAdError adError: DACSDKMAAdError) {
        // エラーログを出力し、本編動画を再生する
    }
    
    func dacsdkmaAdsManagerDidRequestContentPause(_ adsManager: DACSDKMAAdsManager) {
        // 本編動画を一時停止
        self.playbackController.pause()
    }
    
    func dacsdkmaAdsManagerDidRequestContentResume(_ adsManager: DACSDKMAAdsManager) {
        // 本編動画を再生再開
        self.videoView.addSubview(self.playbackController.view)
        self.playbackController.play()
    }
}
```

### Step 6. 動作確認をします
正しく広告が表示されることを確認して下さい。
