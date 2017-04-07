# DAC Native Ad SDK for iOS 
- - -
本マニュアルはNativeAdsSDKをObjective-Cで記述されたプロジェクトに組み込む際のマニュアルとなります。

## 必要なツール,DACライブラリ
 - Xcode : 7.3+
 - iOS : 8.0+
 - DACNativeAdSDK(dynamic)
 
 ※iOS7系のアプリに組み込む場合、dynamicではなくstaticなframeworkをご利用ください。
 また、swiftファイルをソースコード内で作成し、ブリッジヘッダーを作成し<# ProductName #>-Swift.hをimportしてください。

## ソースコード組み込み手順
以下はサンプルコードをそのまま使った場合の例になります。カスタマイズが必要な場合は、以下のコードを参考にして、変更して下さい。

### Step 1:XcodeプロジェクトにSDKを追加します
Xcode Projectを開きます。 
メインプロジェクトのプロジェクトエディタを起動し、ターゲットをクリックします。
- [General]->[Embedded Binaries]セクションを開き、左下の "+"をクリックします。  
"Add Other..."をクリックし、DACSDKNativeAdフォルダ内dynamic/DACSDKNativeAd.frameworkを選択します。
"Choose options for adding these files"は"Added folders"は"Create groups"を選択し、"Finish" をクリックします。  
"Linked Frameworks and Libraries"にDACSDKNativeAd.frameworkが追加されます。
"Embedded Binaries" にDACSDKNativeAd.frameworkが追加されます。
- [PROJET か 指定したターゲット]->[Build Settings]->[Serch Paths]->[framework Serch Paths]をクリックし、DACSDKNativeAd.frameworkがあるフォルダを追加します。

### Step 2:frameworkをimportします

```ViewController.m
#import <DACSDKNativeAd/DACSDKNativeAd-Swift.h>
```

### Step 3:DACSDKNativeAdLoaderを使用し、ネイティブ広告を呼び出します

```ViewController.swift
    self.loader = [[DACSDKNativeAdLoader alloc] initWithPlacementId: placementId rootViewController: self];
    self.loader.delegate = self;
    [self.loader loadRequest];
```

### Step 4:適切なViewにDACSDKNativeContentAdの値を紐付けます

```ViewController.swift
    titleView.text = nativeContentAd.title;
    bodyView.text = nativeContentAd.desc;
    advertiserView.text = nativeContentAd.advertiser;
    imageView.image = image;
```

### Step 5. 動作確認をします
正しく広告が表示されることを確認して下さい。

