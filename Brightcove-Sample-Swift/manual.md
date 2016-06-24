# DAC Multimedia Ads SDK (iOS)
- - -
本マニュアルはDACMASDKをBrightcove-Player-SDKを使ったSwiftのプロジェクトに組み込む際のマニュアルになります。

## 必要なツール,DACライブラリ
* Xcode : 7.3+
* iOS   : 8.0+
* DACMultimediaAdsSDK(iOS)
 * dynamic/DACSDKMA.framework
 * dynamic/src 
* Brightcove-Player-SDK

## ソースコード組み込み手順
以下はサンプルコードをそのまま使った場合の例になります。 カスタマイズが必要な場合はサンプルコードを参考にして, 変更して下さい。
また、今回の手順ではプリロールかつ自動再生のみ流すことが可能です。

Player-SDKをインストールします。
本サンプル（Brightcove-Sample-Swift.xcodeproj）があるフォルダで以下のコマンドを実行して、Brightcove-Player-SDKをインストールします。 

```
$ pod install
```

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
var dacAdController: DACSDKMAAdDefaultController? = nil
```

- 適当なタイミングで広告をリクエストします。

```ViewController.swift
DACSDKMASettings()
        maSettings.vastMaxRedirects              = 5     // Wrapperをリクエストする最大回数。
        maSettings.vastResourceTimeOutSeconds    = 5.0   // VASTをリクエストした際のタイムアウト値
        maSettings.vastAllResourceTimeOutSeconds = 10.0  // VASTのリクエストを開始してから、すべてのVASTのロードが完了するまでのタイムアウト値
        maSettings.mediaLoadTimeOutSeconds       = 15.0  // メディアを読み込む際のタイムアウト値
        
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
    func dacSdkMaAdsLoader(loader: DACSDKMAAdsLoader, adsLoadedWithData data: DACSDKMAAdsLoadedData) {
        self.dacAdsManager = data.adsManager
        data.adsManager.delegate = self
        // 広告動画ファイルのダウンロードする
        data.adsManager.load()
        
        self.dacAdController = DACSDKMAAdDefaultController(adsManager: self.dacAdsManager!)
    }
    
    /// VASTリクエスト/レスポンスでエラーが呼ばれたときに実行される
    func dacSdkMaAdsLoader(loader: DACSDKMAAdsLoader, failedWithErrorData adErrorData: DACSDKMAAdLoadingErrorData) {
        // エラーログを出力し、本編動画を再生する
        NSLog("dacSdkMaAdsLoader: failedWithErrorData: \(adErrorData.adError.message)")
        self.playbackController.play()
    }
    
    /// AdsManagerのイベントが発生した時に実行される
    func dacSdkAdsManager(adsManager: DACSDKMAAdsManager, didReceiveAdEvent adEvent: DACSDKMAAdEvent) {
        switch adEvent.type {
        case .DidLoad:
            // 広告動画ファイルがダウンロードされたら、広告動画を再生する
            adsManager.play()
            break
        case .DidComplete:
            // 広告動画が終了したら、広告を消去する
            adsManager.clean()
            self.dacAdController?.clean()
            break
        default:
            break
        }
    }
    
    /// AdsManagerにエラーが発生した時に実行される
    func dacSdkAdsManager(adsManager: DACSDKMAAdsManager, didReceiveAdError adError: DACSDKMAAdError) {
        // エラーログを出力し、本編動画を再生する
    }
    
    func dacSdkAdsManagerDidRequestContentPause(adsManager: DACSDKMAAdsManager) {
        // 本編動画を一時停止
        self.playbackController.pause()
    }
    
    func dacSdkAdsManagerDidRequestContentResume(adsManager: DACSDKMAAdsManager) {
        // 本編動画を再生再開
        self.videoView.addSubview(self.playbackController.view)
        self.playbackController.play()
    }
}
```

### Step 6. 動作確認をします
正しく広告が表示されることを確認して下さい。