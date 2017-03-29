# DAC Ads SDK for iOS with Objective-C
- - -
本マニュアルはDACAdsSDKをObjective-Cで記述されたプロジェクトに組み込む際のマニュアルとなります。


## 必要なツール・ライブラリ
* Xcode：8.2+
* iOS：8.0+
* DACAdsSDK(iOS)


## ライブラリを使用するための手順
以下はサンプルコードをそのまま使った場合の例になります。
カスタマイズが必要な場合はサンプルコードを参考にして変更してください。


### Step 1. XcodeプロジェクトにSDKを追加します
1. Xcode Projectを開きます。  
2. プロジェクトにDACAdsSDKフォルダを追加します。（ドラッグ&ドロップで可能です。）  
	"Choose options for adding these files"は"Added folders"は"Create groups"を選択し、"Finish" をクリックします。  
3. メインプロジェクトのプロジェクトエディタを起動し、ターゲットをクリックします。
4. [General]->[Linked Frameworks and Libraries]セクションを開き、左下の "+"をクリックします。  
	"Add Other..."をクリックし、DACAdsSDKフォルダ内"libDACAdsSDK"を選択します。  
	"Linked Frameworks and Libraries"に"DACAdsSDK"が追加されます。
5. [PROJET か 指定したターゲット]->[Build Settings]->[Serch Paths]->[Library Serch Paths]をクリックし、DACAdsSDKがあるフォルダを追加します。


### Step 2. Libraryをインポートします
1. 広告を表示する"ViewController"に以下を追記します。

	```ViewController.m
	#import "DASMediationView.h"
	#import "DACAdsSDK.h"
	```


### Step 3. 広告をリクエストします

1. "ViewController"に次の変数を追加します。

	```ViewController.m
	const NSInteger placementID = 1; //mediationのplacementIDを設定します。
	```

2. 適当なタイミングで広告をリクエストします。

	```ViewController.swift
	DASMediationView *mediationView = [[DASMediationView alloc] initWithFrame:CGRectMake(0.f, 20.f, 320.f, 50.f) placementID:placementID];
	mediationView.delegate = self;
	[self.view addSubview:mediationView];
	```


### Step 4. イベントを受け取る準備をします
1. 必要に応じて"ViewController"に以下の"DASMediationViewDelegate protocol"を継承し、"delegateメソッド"を追加します。  
  詳細は"DASMediationView.h"をご確認ください。


### Step 5. 動作確認をします
正しく広告が表示されることを確認してください。
