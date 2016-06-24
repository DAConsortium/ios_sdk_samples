# DAC Ads SDK for iOS
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

### Step 2: frameworkをインポートします
- 広告を表示する"ViewController"に以下の記述を加えます。

```ViewController.m
#import "DASMediationView.h"
#import "DACAdsSDK.h"
```

### Step 3: 広告をリクエストします

- "ViewController"に次の変数を追加します。

```ViewController.m
const NSInteger placementID = 1; //mediationのplacementIDを設定します。
```

- 適当なタイミングで広告をリクエストします。

```ViewController.swift
    DASMediationView *mediationView = [[DASMediationView alloc] initWithFrame:CGRectMake(0.f, 20.f, 320.f, 50.f) placementID:placementID];
    mediationView.delegate = self;
    [self.view addSubview:mediationView];
```

### Step 4: delegateを継承します
- 必要に応じて"ViewController"に以下の"delegate protocol"を継承し、"delegateメソッド"を追加します。

```ViewController.swift
@interface ViewController () <DASMediationViewDelegate>

//メディエーションビューが表示される直前に呼ばれます。
- (void)mediationViewWillAppear:(DASMediationView *)mediationView
{
    NSLog(@"%s: placementID: %td", __PRETTY_FUNCTION__, mediationView.placementID);
}

//メディエーションビューが表示された直後に呼ばれます。
- (void)mediationViewDidAppear:(DASMediationView *)mediationView
{
    NSLog(@"%s: placementID: %td", __PRETTY_FUNCTION__, mediationView.placementID);
}

//メディエーションビューが非表示になる直前に呼ばれます。
- (void)mediationViewWillDisappear:(DASMediationView *)mediationView
{
    NSLog(@"%s: placementID: %td", __PRETTY_FUNCTION__, mediationView.placementID);
}

//メディエーションビューが非表示になった直後に呼ばれます。
- (void)mediationViewDidDisappear:(DASMediationView *)mediationView
{
    NSLog(@"%s: placementID: %td", __PRETTY_FUNCTION__, mediationView.placementID);
}

//メディエーションビュー内に広告がロードされたタイミングで呼ばれます。
- (void)mediationViewDidClicked:(DASMediationView *)mediationView
{
    NSLog(@"%s: placementID: %td", __PRETTY_FUNCTION__, mediationView.placementID);
}

//メディエーションビュー内の広告がタップされたタイミングで呼ばれます。
- (void)mediationViewDidLoadAd:(DASMediationView *)mediationView
{
    NSLog(@"%s: placementID: %td", __PRETTY_FUNCTION__, mediationView.placementID);
}

//メディエーションビュー内でエラーが発生したタイミングで呼ばれます。
- (void)mediationView:(DASMediationView *)mediationView didFailLoadWithError:(NSError *)error
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

### Step 5. 動作確認をします
正しく広告が表示されることを確認して下さい。