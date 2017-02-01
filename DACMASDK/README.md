## DAC Multimedia Ads SDK

Version 2.0

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

- Xcode 7.3+
- iOS 8.0+


### Install

manual.mdをご参照ください。
また同封の SamplePlayer-Swift は動画プレーヤーアプリにPreroll広告を出す例となっております。

### Caution

version1.3.0からSDK内で使用する広告枠のView、コンテンツプレーヤーのView、コンパニオン広告のViewがweakプロパティに変更されましたのでご注意お願いいたします。


### History
- Version 2.0.0 : 2017/02/1 : Swift3.0.0対応。縦型動画対応。インタースティシャル対応。
- Version 1.3.0 : 2016/09/7 : 動画再生中に帯域不足等が通知された場合にリカバリーする機能の追加。
- Version 1.1.2 : 2016/08/24 : マルチインプレッション対応
- Version 1.1.1 : 2016/05/16 : フリークエンシーコントロール機能の追加。"Pause"と"Resume"のトラッキングを送信するように修正。DidAllAdsCompleteイベントがコンテンツ再開通知後に発火されるように修正。
- Version 1.0.4 : 2016/05/11 : staticコンパニオンのタップ条件をタッチからタッチアップインサイドに修正。
- Version 1.0.3 : 2016/05/09 : SVAにて動画スタート時にコンパニオンが一瞬表示されるバグを修正。閉じるボタンをクリックした際に、正常にCloseしないバグを修正。SVAにてバックグラウンドへ遷移時に停止しないバグを修正。
- Version 1.0.1 : 2016/04/26 : VMAP対応など。
- Version 0.4.3 : 2016/04/08 : Xcode 4.3対応。
- Version 0.4.2 : 2016/03/08 : バックグラウンドからの復帰時、プレイヤーがブラックアウトするバグを修正。
- Version 0.4.1 : 2016/03/08 : コンパニオン画像をクリックした際に、ブラウザが起動しないバグを修正。
- Version 0.4.0 : 2016/03/03 : スキップ機能の追加。
- Version 0.3.0 : 2016/02/10 : AdPod対応。
- Version 0.1.0 : 2015/10/07 : リリース開始。

### Licence

Copyright D.A.Consortium All rights reserved.
