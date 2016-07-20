# DAC Multimedia Ads SDK (iOS)
- - -
本マニュアルはDACMASDKをSwiftで記述されたプロジェクトに組み込む際のマニュアルとなります。

## 必要なツール・DACライブラリ
* Xcode：7.3+
* iOS：8.0+
* DACMultimediaAdsSDK(iOS)
 * dynamic/DACSDKMA.framework
 * dynamic/src
 
※iOS7系のアプリに組み込む場合、dynamicではなくstaticなframeworkをご利用ください。

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

### Step 3: 広告をリクエストします

- "ViewController"に次の変数を追加します。

```ViewController.swift
let adTagUri = "https://..."
var dacAdsLoader: DACSDKMAAdsLoader?  = nil
var dacAdsManager: DACSDKMAAdsManager? = nil
var dacAdController: DACSDKMAAdDefaultController? = nil
```

- 適当なタイミングで広告をリクエストします。

```ViewController.swift
let dacSettings = DACSDKMASettings()
self.dacAdsLoader = DACSDKMAAdsLoader(settings: dacSettings)
self.dacAdsLoader?.delegate = self

// 広告動画を掲載するViewと、リクエスト先アドサーバのURIをリクエストにセットする
let adContainer = DACSDKMAAdContainer(view: self.videoView!)
let request = DACSDKMAAdsRequest(adTagURI: self.adTagUri, adContainer: adContainer)
self.dacAdsLoader?.requestAds(request)
```

### Step 4: delegateを継承します
- "ViewController"に以下の2つの"delegate protocol"を継承し、"delegateメソッド""を追加します。

```ViewController.swift
class ViewController: UIViewController, DACSDKMAAdsLoaderDelegate, DACSDKMAAdsManagerDelegate {

    // VASTレスポンスの処理が終わった時に実行される
    func dacSdkMaAdsLoader(loader: DACSDKMAAdsLoader, adsLoadedWithData data: DACSDKMAAdsLoadedData) {
        self.dacAdsManager = data.adsManager
        data.adsManager.delegate = self
        // 広告動画ファイルのダウンロードする
        data.adsManager.load()
        
        self.dacAdController = DACSDKMAAdDefaultController(adsManager: data.adsManager)
    }
    
    // VASTリクエスト/レスポンスでエラーが呼ばれたときに実行される
    func dacSdkMaAdsLoader(loader: DACSDKMAAdsLoader, failedWithErrorData adErrorData: DACSDKMAAdLoadingErrorData) {
        // エラーログを出力し、本編動画を再生する
        NSLog("dacSdkMaAdsLoader: failedWithErrorData: \(adErrorData.adError.message)")
        self.contentPlayer.play()
    }
    
    // AdsManagerのイベントが発生した時に実行される
    func dacSdkAdsManager(adsManager: DACSDKMAAdsManager, didReceiveAdEvent adEvent: DACSDKMAAdEvent) {
        if (adEvent.type == DACSDKMAAdEventType.DidLoad) {
            // 広告動画ファイルがダウンロードされたら、広告動画を再生する
            adsManager.play()
        }
        else if (adEvent.type == DACSDKMAAdEventType.DidAllAdsComplete) {
            // 広告動画が終了したら、広告を消去する
            adsManager.clean()
            self.dacAdsManager = nil
            self.dacAdController?.clean()
            self.dacAdController = nil
        }
    }
    
    // AdsManagerにエラーが発生した時に実行される
    func dacSdkAdsManager(adsManager: DACSDKMAAdsManager, didReceiveAdError adError: DACSDKMAAdError) {
        // エラーログを出力する。
        NSLog("dacSdkMaAdsManager: didReceiveAdError: \(adError.message)")
    }
    
    func dacSdkAdsManagerDidRequestContentPause(adsManager: DACSDKMAAdsManager) {
        // 本編動画を一時停止
        self.contentPlayer.pause()
    }
    
    func dacSdkAdsManagerDidRequestContentResume(adsManager: DACSDKMAAdsManager) {
        // 本編動画を再生再開
        self.contentPlayer.play()
    }
}

```

### Step 5. 動作確認をします
正しく広告が表示されることを確認して下さい。