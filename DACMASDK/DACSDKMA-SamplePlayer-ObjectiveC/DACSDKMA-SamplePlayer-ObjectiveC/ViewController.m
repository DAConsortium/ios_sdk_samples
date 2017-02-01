//
//  ViewController.m
//  DACSDKMA-SamplePlayer-ObjectiveC
//
//  Copyright © 2016 D.A.Consortium All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <DACSDKMA/DACSDKMA-Swift.h>
#import "DACSDKMA_SamplePlayer_ObjectiveC-Swift.h"

#import "ViewController.h"

// サンプル動画URL
NSString *const contentUrl = @"http://vjs.zencdn.net/v/oceans.mp4";

// サンプルアドタグURL
NSString *const adTagUri = @"https://saxp.zedo.com/asw/fnsr.vast?n=2696&c=25/11&d=17&s=2&v=vast2&pu=__page-url__&ru=__referrer__&pw=__player-width__&ph=__player-height__&z=__random-number__";


@interface ViewController() <DACSDKMAAdsLoaderDelegate, DACSDKMAAdsManagerDelegate>

// 動画ビュー
@property(nonatomic, strong) UIView *videoView;
// 動画コンテンツプレイヤー
@property(nonatomic, strong) AVPlayer *contentPlayer;
// 動画再生ボタン
@property(nonatomic, strong) UIButton *playButton;

// SDK用変数
@property(nonatomic, strong) DACSDKMAAdsLoader *dacsdkmaAdsLoader;
@property(nonatomic, strong) DACSDKMAAdsManager *dacsdkmaAdsManager;
@property(nonatomic, strong) DACSDKMAAdController *dacsdkmaAdController;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // videoViewをセットする
    self.videoView = [[UIView alloc] initWithFrame: CGRectMake(20, 20, self.view.bounds.size.width - 40, self.view.bounds.size.height - 40)];
    self.videoView.backgroundColor = [UIColor colorWithWhite:0.0 alpha: 0.5];
    self.videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.videoView];
    
    // playButtonをセットする
    self.playButton = [[UIButton alloc] initWithFrame:self.videoView.bounds];
    [self.playButton setTitle:@"▶️" forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(onPlayButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    self.playButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.playButton.layer.zPosition = MAXFLOAT;
    [self.videoView addSubview:self.playButton];
    
    // 動画コンテンツプレイヤーを使うための準備をする。
    [self setUpContentPlayer];
    
    // SDKを使うための準備をする
    [self setupAdsLoader];
}

- (IBAction)onPlayButtonTouch:(id)sender {
    self.playButton.hidden = YES;
    [self requestAds];
}


- (void)setUpContentPlayer {
    self.contentPlayer = [AVPlayer playerWithURL:[NSURL URLWithString:contentUrl]];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.contentPlayer];
    playerLayer.frame = self.videoView.layer.bounds;
    [self.videoView.layer addSublayer:playerLayer];
}

#pragma mark SDK Setup
- (void)setupAdsLoader {
    DACSDKMASettings *settings = [[DACSDKMASettings alloc] init];
    self.dacsdkmaAdsLoader = [[DACSDKMAAdsLoader alloc] initWithSettings:settings];
    self.dacsdkmaAdsLoader.delegate = self;
}

- (void)requestAds {
    DACSDKMAAdContainer *adContainer = [[DACSDKMAAdContainer alloc] initWithView:self.videoView companionSlots:nil];
    DACSDKMAAdsRequest *request = [[DACSDKMAAdsRequest alloc] initWithAdTagURI:adTagUri adContainer: adContainer contentPlayhead: nil];
    [self.dacsdkmaAdsLoader requestAds:request];
}


#pragma mark AdsLoader Delegates
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

#pragma mark AdsManager Delegates
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

@end
