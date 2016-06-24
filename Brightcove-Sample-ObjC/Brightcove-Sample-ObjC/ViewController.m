//
//  ViewController.m
//  DACSDKMA-SampleBCOVPlayer-ObjectiveC
//
//  Copyright (c) 2015 D.A.Consortium Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "DACSDKMA/DACSDKMA-Swift.h"
#import "ViewController.h"
#import "BrightCovePlayerSDK/BrightCovePlayerSDK.h"

#import "Brightcove_Sample_ObjC-Swift.h"

@interface ViewController() <DACSDKMAAdsLoaderDelegate, DACSDKMAAdsManagerDelegate>
#pragma mark - BCOVSDK
@property (nonatomic, strong) id<BCOVPlaybackController> playbackController;
@property (nonatomic, weak) IBOutlet UIView *videoContainer;
#pragma mark - DACSDK
@property(nonatomic, strong) DACSDKMAAdsLoader *dacAdsLoader;
@property(nonatomic, strong) DACSDKMAAdsManager *dacAdsManager;
@property(nonatomic, strong) DACSDKMAAdDefaultController *dacAdController;

@end

@implementation ViewController

#pragma mark - BCOVSDK
static NSString * const kAccountID = @"exampleID";

#pragma mark - DACSDK
// リクエスト先タグURI
NSString *const adTagUri = @"https://saxp.zedo.com/asw/fnsr.vast?n=2696&c=25/11&d=17&s=2&v=vast2&pu=__page-url__&ru=__referrer__&pw=__player-width__&ph=__player-height__&z=__random-number__";


#pragma mark - 実装

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpVideoPlayerUI];
}

- (void)setUpVideoPlayerUI {
    CGFloat videoViewWidth = self.view.bounds.size.width - 40;
    CGFloat videoViewHeight = videoViewWidth * 9 / 16;
    CGRect videoViewRect = CGRectMake(20,40,videoViewWidth,videoViewHeight);
    
    self.videoView = [[UIView alloc] initWithFrame:videoViewRect];
    self.videoView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self.view addSubview:(self.videoView)];
    
    [self setupBrightcove];
    [self setupMA];
}

- (void)setupMA {
    DACSDKMASettings *settings = [[DACSDKMASettings alloc] init];
    self.dacAdsLoader = [[DACSDKMAAdsLoader alloc] initWithSettings:settings];
    self.dacAdsLoader.delegate = self;
    
    DACSDKMAAdContainer *adContainer = [[DACSDKMAAdContainer alloc] initWithView:self.videoView companionSlots: nil];
    
    DACSDKMAAdsRequest *request = [[DACSDKMAAdsRequest alloc] initWithAdTagURI:adTagUri adContainer:adContainer contentPlayhead:nil];
    [self.dacAdsLoader requestAds:request];
}

- (void)setupBrightcove {
    BCOVPlayerSDKManager *manager = [BCOVPlayerSDKManager sharedManager];
    
    self.playbackController = [manager createPlaybackControllerWithViewStrategy:[manager defaultControlsViewStrategy]];
    self.playbackController.view.frame = self.videoView.bounds;
    
    self.playbackController.analytics.account = kAccountID;

    self.playbackController.autoAdvance = YES;
    self.playbackController.autoPlay = NO;
    
    NSArray *videos = @[
                        [self videoWithURL:[NSURL URLWithString:@"http://cf9c36303a9981e3e8cc-31a5eb2af178214dc2ca6ce50f208bb5.r97.cf1.rackcdn.com/bigger_badminton_600.mp4"]],
                        [self videoWithURL:[NSURL URLWithString:@"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"]]
                        ];
    [self.playbackController setVideos:videos];
    
}

- (BCOVVideo *)videoWithURL:(NSURL *)url
{
    // set the delivery method for BCOVSources that belong to a video
    BCOVSource *source = [[BCOVSource alloc] initWithURL:url deliveryMethod:kBCOVSourceDeliveryHLS properties:nil];
    return [[BCOVVideo alloc] initWithSource:source cuePoints:[BCOVCuePointCollection collectionWithArray:@[]] properties:@{}];
}

#pragma mark AdsLoader Delegates
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

#pragma mark AdsManager Delegates
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

@end
