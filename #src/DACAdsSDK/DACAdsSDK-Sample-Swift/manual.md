# DAC Ads SDK for iOS with Swift
- - -
本マニュアルはDACAdsSDKをSwiftで記述されたプロジェクトに組み込む際のマニュアルとなります。


## 必要なツール・ライブラリ
* Xcode：8.2.1+
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


### Step 2. Bridging-Hedderファイルを作成します
Objective-CのライブラリをSwiftのプロジェクトで使用するためにBridging-Hdderファイルを作成します。

1. [File]->[New]->[file]から[Hedder File]を選択し、<#ProductName#>-Bridging-Hedderという名前で保存します。


### Step 3. frameworkをインポートします
1. 作成したBridging-Hedder内にframeworkをインポートします。

	```<#ProductName#>-Bridging-Hedder.h
	#import "DASMediationView.h"
	#import "DACAdsSDK.h"
	```


### Step 4. 広告をリクエストします

1. "ViewController"に次の変数を追加します。  

	```ViewController.swift
	let placementID : UInt = 1 //placementIDを設定します。
	```

2. 適当なタイミングで広告をリクエストします。

	```ViewController.swift
	let mediationView :DASMediationView = DASMediationView(
		frame: CGRectMake(0,20,320,50),   
		placementID:placementID)  		
	mediationView.delegate = self
	self.view.addSubview(mediationView)
	```


### Step 5. イベントを受け取る準備をします
1. 必要に応じて"ViewController"に以下の"DASMediationViewDelegate protocol"を継承し、"delegateメソッド"を追加します。  
  詳細は"DASMediationView.h"をご確認ください。


### Step 6. 動作確認をします
正しく広告が表示されることを確認してください。
