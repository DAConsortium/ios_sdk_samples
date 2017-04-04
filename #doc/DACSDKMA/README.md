## DAC Multimedia Ads SDK

Version 2.0.2

### Overview

DAC Multimedia Ads SDKはアプリへのVAST広告を掲載を容易にするSDKです。

本SDKはHTTPリクエストに対して返されたVASTレスポンスを解釈し、指定されたviewに動画広告を掲載します。


### Supported

- VAST 2.0 の一部
- VAST 3.0 の一部

AdType
- AdPod
- Linear
- Wrapper

MediaFile
- delivery: Progressive
- type: video/mp4

Examples of the UnSupported
- NonLinear


### Requirement

- Xcode 8.3
- iOS 8.0+


### Install

manual.mdをご参照ください。
また同封の SamplePlayer-Swift は動画プレーヤーアプリにPreroll広告を出す例となっております。


### History
* Version 2.0.2 : 2017/04/03
    - 以下のエラーにより、ビルドできない問題を修正。  
        - Missing required modules: 'DACSDKMAModule.Crypto', 'DACSDKMAModule'
* Version 2.0.1 : 2017/03/29
    - BundleVersionを数値とコンマのみで現すように修正。
    - AdViewがどのWindowにも属さなくなった時に自動クリーンする機能を廃止。
* Version 2.0.0 : 2016/12/14
	- Swift3対応。
	- 各メソッド・デリゲート・プロパティ名の修正。
	- アイコンの変更。
	- SmartVisionAdに縦型広告などを追加。
	- フルスクリーン時のClose処理した際にViewの設置場所次第ではオーバーレイの状態が解除できないバグを修正。
	- nilオブジェクトへのアクセスでクラッシュする場合があるバグを修正。
	- 動画ファイル読込時エラーの許容回数が反映されないバグを修正。
	- closeトラッキングが出力されないバグを修正。
	- 自動クローズ有効時バックグラウンドでクローズしないバグを修正。
	- バックグラウンド遷移時に止め画像のレイアウトが崩れるバグを修正。
* Version 1.1.1 : 2016/05/16
	- フリークエンシーコントロール機能の追加。"Pause"と"Resume"のトラッキングを送信するように修正。DidAllAdsCompleteイベントがコンテンツ再開通知後に発火されるように修正。
* Version 1.0.4 : 2016/05/11
	- staticコンパニオンのタップ条件をタッチからタッチアップインサイドに修正。
* Version 1.0.3 : 2016/05/09
	- SVAにて動画スタート時にコンパニオンが一瞬表示されるバグを修正。閉じるボタンをクリックした際に、正常にCloseしないバグを修正。SVAにてバックグラウンドへ遷移時に停止しないバグを修正。
* Version 1.0.1 : 2016/04/26
	- VMAP対応など。
* Version 0.4.3 : 2016/04/08
	- Xcode 4.3対応。
* Version 0.4.2 : 2016/03/08
	- バックグラウンドからの復帰時、プレイヤーがブラックアウトするバグを修正。
* Version 0.4.1 : 2016/03/08
	- コンパニオン画像をクリックした際に、ブラウザが起動しないバグを修正。
* Version 0.4.0 : 2016/03/03
	- スキップ機能の追加。
* Version 0.3.0 : 2016/02/10
	- AdPod対応。
* Version 0.1.0 : 2015/10/07
	- リリース開始。

### Licence

Copyright D.A.Consortium All rights reserved.
