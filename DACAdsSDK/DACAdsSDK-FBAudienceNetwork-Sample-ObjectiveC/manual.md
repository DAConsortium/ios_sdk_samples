# DAC Ads SDK for iOS + Facebook Audience Network
- - -
本マニュアルはDACAdsSDKをObjective-Cで記述されたプロジェクトに組み込む際のマニュアルとなります。

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

### Step 2 :FacebookAudienceNetworkSDKをプロジェクトに追加します。

本サンプル（DACAdsSDK-FBAudienceNetwork-Sample-ObjectiveC.xcodeproj）があるフォルダで以下のコマンドを実行して、FacebookAudienceNetworkSDKをインストールします。 

```
$ pod install
```

### Step 3 :FacebookRotateHandlerを追加します。
プロジェクトにDACAdsSDKとFacebookSDKを連携させるためのFacebookRotateHandlerを追加します。（Build PhaseにFacebookRotateHandler.mが追加されていることをご確認ください。）


### Step 4: frameworkをインポートします
- 広告を表示する"ViewController"に以下の記述を加えます。

```ViewController.m
#import "DASMediationView.h"
#import "DACAdsSDK.h"
#import "FacebookRotateHandler.h"
```

### Step 5: 広告をリクエストします

- "ViewController"に次の変数を追加します。

```ViewController.m
const NSInteger placementID = 1; //mediationのplacementIDを設定します。
```

- 適当なタイミングで広告をリクエストします。

```ViewController.swift
    DASMediationView *mediationView = [[DASMediationView alloc] initWithFrame:CGRectMake(0.f, 20.f, 320.f, 50.f) placementID:placementID];
    self.facebookAdRotateHandler = [[FacebookRotateHandler alloc]
                                    initWithPlacementID:@"157282864658028_232569667129347"
                                    adSize:kFBAdSizeHeight50Banner
                                    rootViewController:self];
    mediationView.delegate = self;
    mediationView.rotateHandler = self.facebookAdRotateHandler;
    [self.view addSubview:mediationView];
```

### Step 6: delegateを継承します
- 必要に応じて"ViewController"に以下の"delegate protocol"を継承し、"delegateメソッド"を追加します。

```ViewController.swift
@interface ViewController () <DASMediationViewDelegate>

//メディエーションビューが表示される直前に呼ばれます。
- (void)DACMediationViewWillAppear:(DASMediationView *)mediationView
{
    NSLog(@"%s: placementID: %td", __PRETTY_FUNCTION__, mediationView.placementID);
}

//メディエーションビューが表示された直後に呼ばれます。
- (void)DACMediationViewDidAppear:(DASMediationView *)mediationView
{
    NSLog(@"%s: placementID: %td", __PRETTY_FUNCTION__, mediationView.placementID);
}

//メディエーションビューが非表示になる直前に呼ばれます。
- (void)DACMediationViewWillDisappear:(DASMediationView *)mediationView
{
    NSLog(@"%s: placementID: %td", __PRETTY_FUNCTION__, mediationView.placementID);
}

//メディエーションビューが非表示になった直後に呼ばれます。
- (void)DACMediationViewDidDisappear:(DASMediationView *)mediationView
{
    NSLog(@"%s: placementID: %td", __PRETTY_FUNCTION__, mediationView.placementID);
}

//メディエーションビュー内に広告がロードされたタイミングで呼ばれます。
- (void)DACMediationViewDidClicked:(DASMediationView *)mediationView
{
    NSLog(@"%s: placementID: %td", __PRETTY_FUNCTION__, mediationView.placementID);
}

//メディエーションビュー内の広告がタップされたタイミングで呼ばれます。
- (void)DACMediationViewDidLoadAd:(DASMediationView *)mediationView
{
    NSLog(@"%s: placementID: %td", __PRETTY_FUNCTION__, mediationView.placementID);
}

//メディエーションビュー内でエラーが発生したタイミングで呼ばれます。
- (void)DACMediationView:(DASMediationView *)mediationView didFailLoadWithError:(NSError *)error
{
    switch (error.code) {
        case DASErrorCodeTagDataNotFound:
            // 広告のタグデータが存在しなかった。
            NSLog(@"AdTag data not found.(placementID: %td)", mediationView.placementID);
            break;
        case DASErrorCodeTagDataRequestFailed:
            // 広告のタグデータ取得に失敗した。
            NSLog(@"AdTag data request failed.(placementID: %td/ reason: %@)", mediationView.placementID, error.localizedDescription);
            break;
        case DASErrorCodeAdRequestFailed:
            // 広告データの取得に失敗した。
            NSLog(@"Ad request failed.(placementID: %td/ reason: %@)", mediationView.placementID, error.localizedDescription);
            break;
        case DASErrorCodeUnknown:
        default:
            // その他エラー
            NSLog(@"Unknown error.(placementID: %td/ reason: %@)", mediationView.placementID, error.localizedDescription);
            break;
    }
}

```

### Step 7. 動作確認をします
正しく広告が表示されることを確認して下さい。