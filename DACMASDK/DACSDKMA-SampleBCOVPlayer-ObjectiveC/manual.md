# DAC Multimedia Ads SDK (iOS)
- - -
本マニュアルはDACMASDKをBrightcove-Player-SDKを使ったObjective-Cのプロジェクトに組み込む際のマニュアルになります。

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

```ViewController.m
#import "DACSDKMA/DACSDKMA-Swift.h"
```

### Step 4. frameworkを使用するためにBridgeファイルをインポートします
Objective-CのプロジェクトでSwiftのframeworkを使用するため、Bridgeファイルをimportします。

```ViewController.m
import "<#ProductName#>-swift.h"
```

### Step 5: 広告をリクエストします

- "ViewController"に次の変数を追加します。

```ViewController.m
@property(nonatomic, strong) DACSDKMAAdsLoader *dacAdsLoader;
@property(nonatomic, strong) DACSDKMAAdsManager *dacAdsManager;
@property(nonatomic, strong) DACSDKMAAdController *dacAdController;

NSString *const adTagUri = @"https://..."
```

- 適当なタイミングで広告をリクエストします。

```ViewController.m
    DACSDKMASettings *settings = [[DACSDKMASettings alloc] init];
    self.dacAdsLoader = [[DACSDKMAAdsLoader alloc] initWithSettings:settings];
    self.dacAdsLoader.delegate = self;
    
    DACSDKMAAdContainer *adContainer = [[DACSDKMAAdContainer alloc] initWithView:self.videoView companionSlots: nil];
    
    DACSDKMAAdsRequest *request = [[DACSDKMAAdsRequest alloc] initWithAdTagURI:adTagUri adContainer:adContainer contentPlayhead:nil];
    [self.dacAdsLoader requestAds:request];
```

### Step 6: delegateを継承します
- "ViewController"に以下の2つの"delegate protocol"を継承し、"delegateメソッド""を追加します。

```ViewController.m
@interface ViewController() <DACSDKMAAdsLoaderDelegate, DACSDKMAAdsManagerDelegate>

- (void)dacSdkMaAdsLoader:(DACSDKMAAdsLoader *)loader adsLoadedWithData:(DACSDKMAAdsLoadedData *)data {
    self.dacAdsManager = data.adsManager;
    self.dacAdsManager.delegate = self;
    [self.dacAdsManager load];
    
    self.dacAdController = [[DACSDKMAAdDefaultController alloc] initWithAdsManager:self.dacAdsManager];
}

- (void)dacSdkMaAdsLoader:(DACSDKMAAdsLoader *)loader failedWithErrorData:(DACSDKMAAdLoadingErrorData *)adErrorData {
    NSLog(@"Error: dacSdkMaAdsLoader:(loader) failedWithErrorData(adErrorData) = %@", adErrorData.adError.message);
    [self.playbackController play];
}

// DACSDKMAAdEventが発生した際に呼ばれます。
- (void)dacSdkAdsManager:(DACSDKMAAdsManager *)adsManager didReceiveAdEvent:(DACSDKMAAdEvent *)adEvent {
    switch (adEvent.type) {
        case DACSDKMAAdEventTypeDidLoad:
            [self.dacAdsManager play];
            break;
        case DACSDKMAAdEventTypeDidAllAdsComplete:
            [self.dacAdsManager clean];
            self.dacAdsManager = nil;
            [self.dacAdController clean];
            self.dacAdController = nil;
            [self.playbackController play];
            break;
        default:
            break;
    }
}

// DACSDKMAAdErrorが発生した際に呼ばれます。
- (void)dacSdkAdsManager:(DACSDKMAAdsManager *)adsManager didReceiveAdError:(DACSDKMAAdError *)adError {
    NSLog(@"Error: dacSdkAdsManager:(adsManager) didReceiveAdError:(adError) = %@", adError.message);
}

// 動画広告が再生開始、レジュームした際に呼ばれます。アプリのビデオコンテンツに停止を要求します。
- (void)dacSdkAdsManagerDidRequestContentPause:(DACSDKMAAdsManager *)adsManager {
    [self.playbackController pause];
}

// 動画広告が一時停止、正常終了・エラー終了した際に呼ばれます。アプリのビデオコンテンツに再生を要求します。
- (void)dacSdkAdsManagerDidRequestContentResume:(DACSDKMAAdsManager *)adsManager {
    [self.videoView addSubview: self.playbackController.view];
    [self.playbackController play];
}

```

### Step 7. 動作確認をします
正しく広告が表示されることを確認して下さい。
