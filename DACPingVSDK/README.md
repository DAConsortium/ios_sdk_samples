# DAC PingV SDK(iOS)

## バージョン
+ 1.0.0

## 目次
* [必要条件](#必要条件)
* [概要](#概要)
* [使い方](#使い方)
* [送信データ](#送信データ)
* [改訂履歴](#改訂履歴)
* [著作権](#著作権)

## <div id="必要条件">必要条件</div>

| ファイル名 | Xcode | サポートOS | プログラミング言語 |
|:--|:--|:--|:--|:--|
| dynamic/DACSDKPingV.framework | 8.0 | iOS 8.0 以上 | Swift 3 もしくは Objective-C |

## <div id="概要">概要</div>

* アプリのデータ収集を行い、バックグラウンドに遷移する際にそれらをPOSTリクエストします。

## <div id="使い方">使い方</div>

### 1. Xcodeにframeworkを追加します

* [Project navigator]->[プロジェクト]->[TARGETS]->[General]->[Embedded Binaries]->[+]->[Add Other]をクリックします。  
  "DACSDKPingV.framework"を選択し、[Open]します。

* "DACSDKPingV.framework"がプロジェクト外にある場合は、  
  [Project navigator]->[プロジェクト]->[TARGETS]->[Build Settings]->[Search Paths]->[Framework Search Paths]に、  
  「"DACSDKPingV.framework"が配置されているフォルダ」を追加します。
	* 例) 次のようなフォルダ構成となる場合、  
	  ```"~/Documents/Developer/lib/DACSDKPingV.framework"```  
	  以下の設定になります。  
	  ```FRAMEWORK_SEARCH_PATHS = "~/Documents/Developer/lib/";```  
	  
* "Objective-C"を利用の場合、  
  [Project navigator]->[プロジェクト]->[TARGETS]->[Build Options]-[Embeedded Content Contains Swift Code]を"YES"に設定します。

* 同様に、"DACSDKCore.framework"を追加します。

### 2. ソースコードにframeworkのAPIなどを追加します

#### アプリケーション情報を送信する

アプリ起動箇所(UIApplicationDelegate.application(_:didFinishLaunchingWithOptions:))などに、以下を実装します。

1. PingVフレームワークをインポートします。(必須)
2. (AppDelegateなどで初期化していない場合、)DACSDKPingV.setupメソッドを呼び出します。(必須)
3. アプリケーションのオプション情報を追加します。(任意)  
	詳細はDACSDKPingVApplicationDataCenterクラスのプロパティなどを確認ください。
4. デリゲートの設定をします。(任意)

##### swiftの例

```
// AppDelegate.swift に記載する場合

import UIKit

// --------------------------------------------------
// MARK: 1. PingVフレームワークをインポートします。(必須)
// --------------------------------------------------
import DACSDKPingV

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // --------------------------------------------------
    // MARK: 2. setupメソッドを呼び出します。(必須)
    // --------------------------------------------------
    DACSDKPingV.shared.setup(oid: "OwnerIDを設定してください")

    // --------------------------------------------------
    // MARK: 3. アプリケーションのオプション情報を追加します。(任意)
    // --------------------------------------------------
    DACSDKPingV.shared.applicationDataCenter.page_id = "sample"
    DACSDKPingV.shared.applicationDataCenter.replaceExtras([
      "dev language": "swift",
      "library type": "dynamic-framework",
    ])

    // --------------------------------------------------
    // MARK: 4. デリゲートの設定を設定します。(任意)
    // -------------------------------------------------- 
    DACSDKPingV.sharedInstance.applicationDataCenter.delegate = self    

    return true
  }

  ...
}

// --------------------------------------------------
// MARK: 4. デリゲートの設定を設定します。(任意)
// --------------------------------------------------
extension AppDelegate: DACSDKPingVApplicationDataCenterDelegate {
    func dacSdkPingV(applicationDataCenter: DACSDKPingVApplicationDataCenter, didSendApplicationDataWithError error: Error?) {
        if let error: Error = error {
            print("ping failed: error = \(error).")
        }
        else {
            print("ping succeeded.")
        }
    }
}
```

##### Objective-Cの例

```
// AppDelegate.m に記載する例

#import "AppDelegate.h"

// --------------------------------------------------
// MARK: 1. PingVフレームワークをインポートします。(必須)
// --------------------------------------------------
#import <DACSDKPingV/DACSDKPingV-Swift.h>

// --------------------------------------------------
// MARK: 4. デリゲートの設定をします。(任意)
// --------------------------------------------------
@interface AppDelegate () <DACSDKPingVApplicationDataCenterDelegate>
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // --------------------------------------------------
    // MARK: 2. setupメソッドを呼び出します。(必須)
    // --------------------------------------------------
	[DACSDKPingV.shared setupWithOid:@"OwnerIDを設定してください"];

	// --------------------------------------------------
	// MARK: 3. アプリケーションのオプション情報を追加します。(任意)
   // --------------------------------------------------
	DACSDKPingV.shared.applicationDataCenter.page_id = @"sample";
	[DACSDKPingV.shared.applicationDataCenter replaceExtras:@{
		@"dev language": @"Objective-C",
		@"library type": @"dynamic-framework",
	}];
    
    // --------------------------------------------------
    // MARK: 4. デリゲートの設定を設定します。(任意)
    // -------------------------------------------------- 
	DACSDKPingV.shared.applicationDataCenter.delegate = self;

	return YES;
}

...

// --------------------------------------------------
// MARK: 4. デリゲートの設定を設定します。(任意)
// -------------------------------------------------- 
- (void)dacSdkPingVWithApplicationDataCenter:(DACSDKPingVApplicationDataCenter *)applicationDataCenter didSendApplicationDataWithError:(NSError *)error {
    if (error) {
        NSLog(@"ping failed: error = \(error).");
    }
    else {
        NSLog(@"ping succeeded.");
    }
}

```

## <div id="送信データ">送信データ</div>

### アプリケーション情報

以下のデータをJSON形式でPOSTリクエストします。  
データが設定されていない、取得できない場合、該当する項目は送信されません。

| Property | Type | Setter | Description |
| :-- | :-- | :-- | :-- |
| oid               | string | User(必須) | データオーナーIDハッシュ<br>* nilや空文字が設定された場合はデータ送信時に失敗します。 |
| event_ids         | string | User(任意) | イベント識別子<br>* 複数の場合はカンマ区切り |
| page_id           | string | User(任意) | ページ識別子 |
| location_accuracy | double | User(任意) | 位置情報: 精度 |
| longitude         | string | User(任意) | 位置情報: 経度 |
| latitude          | string | User(任意) | 位置情報: 緯度 |
| extras            | string | User(任意) | その他収集データ<br>* JSON形式 |
| idfa              | string | SDK | Advertising ID<br>* 利用不可の場合、nil扱いになります。 |
| idfa_limited      | int    | SDK | Advertising ID利用可否<br>* (0: 可, 1:不可) |
| td_ip             | string | SDK | IPアドレス<br>* "td_ip"(固定値) |
| language          | string | SDK | 言語設定 |
| locale            | string | SDK | 地域設定 |
| timezone          | string | SDK | タイムゾーン |
| carrier           | string | SDK | キャリア |
| network           | string | SDK | インターネット接続方法<br>・"unknown"<br>・"2G"<br>・"3G"<br>・"4G"<br>・"WiFi" |
| os                | string | SDK | OS<br>* "iOS"(固定値) |
| os_version        | string | SDK | OSバージョン |
| useragent         | string | SDK | ユーザーエージェント<br> * DACSDKPingVが初期化された時点の値になります。 |
| device_model      | string | SDK | 機種名 |
| device_maker      | string | SDK | メーカー<br>* "Apple"(固定値) |
| height            | int    | SDK | 端末の画面サイズ: 縦 |
| width             | int    | SDK | 端末の画面サイズ: 横 |
| bundle_id         | string | SDK | Bundle ID |
| app_name          | string | SDK | アプリ名 |
| app_version       | string | SDK | アプリバージョン<br> * BundleShortVersion(BundleVersion) |
| url_scheme        | string | SDK | URLスキーム |
| usagetime         | int    | SDK | アプリ滞在時間<br>* フォアグラウンド開始～バックグラウンド開始までの時間(ms) |

## <div id="改訂履歴">改訂履歴</div>

| バージョン | 日付 | 詳細 |
| :-- | :-- | :-- |
| 1.0.0 | 2016/10/14 | リリース開始 |

## <div id="著作権">著作権</div>
Copyright (c) 2016 D.A.Consortium Inc. All rights reserved.
