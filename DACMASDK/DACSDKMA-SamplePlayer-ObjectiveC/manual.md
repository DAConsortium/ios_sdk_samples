# DAC Multimedia Ads SDK (iOS)
- - -
本マニュアルはDACMASDKをObjective-Cで記述されたプロジェクトに組み込む際のマニュアルとなります。

## 必要なツール,DACライブラリ
* Xcode：7.3+
* iOS：8.0+
* DACMultimediaAdsSDK(iOS)
 * dynamic/DACSDKMA.framework
 * dynamic/src
 
※iOS7系のアプリに組み込む場合、dynamicではなくstaticなframeworkをご利用ください。
また、swiftファイルをソースコード内で作成し、ブリッジヘッダーを作成し<# ProductName #>-Swift.hをimportしてください。

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

```ViewController.m
#import <DACSDKMA/DACSDKMA-Swift.h>
```

### Step 3. frameworkを使用するためにBridgeファイルをインポートします
Objective-CのプロジェクトでSwiftのframeworkを使用するため、Bridgeファイルをimportします。

```ViewController.m
import "<#ProductName#>-swift.h"
```

### Step 4: 広告をリクエストします

- "ViewController"に次の変数を追加します。

```ViewController.m
NSString *const adTagUri = @"https://..."; 

@property(nonatomic, strong) DACSDKMAAdsLoader *dacsdkmaAdsLoader;
@property(nonatomic, strong) DACSDKMAAdsManager *dacsdkmaAdsManager;
@property(nonatomic, strong) DACSDKMAAdController *dacsdkmaAdController;
```

- 適当なタイミングで広告をリクエストします。

```ViewController.swift
    DACSDKMASettings *settings = [[DACSDKMASettings alloc] init];
    self.dacsdkmaAdsLoader = [[DACSDKMAAdsLoader alloc] initWithSettings:settings];
    self.dacsdkmaAdsLoader.delegate = self;
    
    DACSDKMAAdContainer *adContainer = [[DACSDKMAAdContainer alloc] initWithView:self.videoView companionSlots:nil];
    DACSDKMAAdsRequest *request = [[DACSDKMAAdsRequest alloc] initWithAdTagURI:adTagUri adContainer: adContainer contentPlayhead: nil];
    [self.dacsdkmaAdsLoader requestAds:request];
```

### Step 5: delegateを継承します
- "ViewController"に以下の2つの"delegate protocol"を継承し、"delegateメソッド"を追加します。

```ViewController.swift
@interface ViewController() <DACSDKMAAdsLoaderDelegate, DACSDKMAAdsManagerDelegate>

// 広告データの読み込みが正常に完了した際に呼ばれます。
- (void)dacsdkmaAdsLoader:(DACSDKMAAdsLoader *)loader didLoad:(DACSDKMAAdsLoadedData *)adsLoadedData {
    self.dacsdkmaAdsManager = adsLoadedData.adsManager;
    self.dacsdkmaAdsManager.delegate = self;
    [self.dacsdkmaAdsManager loadWithCompletion: ^(BOOL result) {
        if (result) {
            self.dacsdkmaAdController = [[DACSDKMAAdController alloc] initWithAdsManager:self.dacsdkmaAdsManager];
        }
    }];
}

// 広告データの読み込みが失敗した際に呼ばれます。
- (void)dacsdkmaAdsLoader:(DACSDKMAAdsLoader *)loader didFail:(DACSDKMAAdError *)adError {
    NSLog(@"Error: dacSdkMaAdsLoader:(loader) didFail(adError) = %@", adError.message);
    [self.contentPlayer play];
}

// DACSDKMAAdEventが発生した際に呼ばれます。
- (void)dacsdkmaAdsManager:(DACSDKMAAdsManager *)adsManager didReceiveAdEvent:(DACSDKMAAdEvent *)adEvent {
    if (adEvent.type == DACSDKMAAdEventTypeDidLoad) {
        [self.dacsdkmaAdsManager play];
    }
    else if (adEvent.type == DACSDKMAAdEventTypeDidAllAdsComplete) {
        [self.dacsdkmaAdsManager clean];
        self.dacsdkmaAdsManager = nil;
        [self.dacsdkmaAdController clean];
        self.dacsdkmaAdController = nil;
    }
}

// DACSDKMAAdErrorが発生した際に呼ばれます。
- (void)dacsdkmaAdsManager:(DACSDKMAAdsManager *)adsManager didReceiveAdError:(DACSDKMAAdError *)adError {
    NSLog(@"Error: dacSdkAdsManager:(adsManager) didReceiveAdError:(adError) = %@", adError.message);
}

// 動画広告が再生開始、レジュームした際に呼ばれます。アプリのビデオコンテンツに停止を要求します。
- (void)dacsdkmaAdsManagerDidRequestContentPause:(DACSDKMAAdsManager *)adsManager {
    [self.contentPlayer pause];
}

// 動画広告が一時停止、正常終了・エラー終了した際に呼ばれます。アプリのビデオコンテンツに再生を要求します。
- (void)dacsdkmaAdsManagerDidRequestContentResume:(DACSDKMAAdsManager *)adsManager {
    [self.contentPlayer play];
}

```

### Step 6. 動作確認をします
正しく広告が表示されることを確認して下さい。