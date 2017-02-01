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
var dacsdkmaAdsLoader: DACSDKMAAdsLoader?  = nil
var dacsdkmaAdsManager: DACSDKMAAdsManager? = nil
var dacsdkmaAdController: DACSDKMAAdController? = nil
```

- 適当なタイミングで広告をリクエストします。

```ViewController.swift
let settings: DACSDKMASettings = DACSDKMASettings()
self.dacsdkmaAdsLoader = DACSDKMAAdsLoader(settings: settings)
self.dacsdkmaAdsLoader?.delegate = self

// 広告動画を掲載するViewと、リクエスト先アドサーバのURIをリクエストにセットする
let adContainer: DACSDKMAAdContainer = DACSDKMAAdContainer(view: self.videoView!)
let request: DACSDKMAAdsRequest = DACSDKMAAdsRequest(adTagURI: self.adTagUri, adContainer: adContainer)
self.dacsdkmaAdsLoader?.requestAds(request)
```

### Step 4: delegateを継承します
- "ViewController"に以下の2つの"delegate protocol"を継承し、"delegateメソッド""を追加します。

```ViewController.swift
class ViewController: UIViewController, DACSDKMAAdsLoaderDelegate, DACSDKMAAdsManagerDelegate {

    // VASTレスポンスの処理が終わった時に実行される
    func dacsdkmaAdsLoader(_ loader: DACSDKMAAdsLoader, didLoad adsLoadedData: DACSDKMAAdsLoadedData) {
        self.dacsdkmaAdsManager = adsLoadedData.adsManager
        adsLoadedData.adsManager.delegate = self
        // 広告動画ファイルのダウンロードする
        adsLoadedData.adsManager.load()
        
        self.dacsdkmaAdController = DACSDKMAAdController(adsManager: adsLoadedData.adsManager)
    }
    
    // VASTリクエスト/レスポンスでエラーが呼ばれたときに実行される
    func dacsdkmaAdsLoader(_ loader: DACSDKMAAdsLoader, didFail adError: DACSDKMAAdError) {
        // エラーログを出力し、本編動画を再生する
        NSLog("dacSdkMaAdsLoader: didFail: \(adError.message)")
        self.contentPlayer.play()
    }
    
    // AdsManagerのイベントが発生した時に実行される
    func dacsdkmaAdsManager(_ adsManager: DACSDKMAAdsManager, didReceiveAdEvent adEvent: DACSDKMAAdEvent) {
        if (adEvent.type == DACSDKMAAdEventType.didLoad) {
            // 広告動画ファイルがダウンロードされたら、広告動画を再生する
            adsManager.play()
        }
        else if (adEvent.type == DACSDKMAAdEventType.didAllAdsComplete) {
            // 広告動画が終了したら、広告を消去する
            adsManager.clean()
            self.dacsdkmaAdsManager = nil
            self.dacsdkmaAdController?.clean()
            self.dacsdkmaAdController = nil
        }
    }
    
    // AdsManagerにエラーが発生した時に実行される
    func dacsdkmaAdsManager(_ adsManager: DACSDKMAAdsManager, didReceiveAdError adError: DACSDKMAAdError) {
        // エラーログを出力する。
        NSLog("dacSdkMaAdsManager: didReceiveAdError: \(adError.message)")
    }
    
    func dacsdkmaAdsManagerDidRequestContentPause(_ adsManager: DACSDKMAAdsManager) {
        // 本編動画を一時停止
        self.contentPlayer.pause()
    }
    
    func dacsdkmaAdsManagerDidRequestContentResume(_ adsManager: DACSDKMAAdsManager) {
        // 本編動画を再生再開
        self.contentPlayer.play()
    }
}

```

### Step 5. 動作確認をします
正しく広告が表示されることを確認して下さい。