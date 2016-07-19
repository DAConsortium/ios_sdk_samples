//
//  ViewController.m
//  DACNativeAdSDK-Sample-ObjectiveC
//
//  Copyright © 2016 D.A.Consortium Inc. All rights reserved.
//

#import "ViewController.h"
#import <DACSDKNativeAd/DACSDKNativeAd-Swift.h>

@interface ViewController ()<UIGestureRecognizerDelegate,DACSDKNativeAdDelegate>

@property (weak, nonatomic) IBOutlet UIView *placeHolderView;
@property (strong) DACSDKNativeAdLoader* loader;
@property (weak) UIView* nativeAdView;

@end

@implementation ViewController

int placementId = 30517;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepareNativeAdLoader];
}

// 広告を表示するためのAdLoaderを呼び出します。
- (void)prepareNativeAdLoader {
    self.loader = [[DACSDKNativeAdLoader alloc] initWithPlacementId: placementId rootViewController: self];
    self.loader.delegate = self;
    [self.loader loadRequest];
}

/* 広告のロードが成功したら呼ばれます。
 ネイティブ広告のViewを作成し、その中で取得したタイトル、文章、画像、広告主名をViewに格納し、表示します。 */
- (void)dacSdkNativeAdLoader:(DACSDKNativeAdLoader * _Nonnull)loader didReceiveNativeAd:(DACSDKNativeContentAd * _Nonnull)nativeContentAd{
    
    DACSDKNativeAdView *contentAdView = [[DACSDKNativeAdView alloc]initWithFrame:CGRectMake(50, 50, 300, 200)];
    [self.view addSubview:contentAdView];
    contentAdView.backgroundColor = [UIColor yellowColor];
    contentAdView.nativeContentAd = nativeContentAd;
    
    
    
    UILabel *titleView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 50)];
    [contentAdView addSubview:titleView];
    
    UILabel *bodyView = [[UILabel alloc]initWithFrame:CGRectMake(150, 50, 150, 100)];
    bodyView.numberOfLines = 0;
    bodyView.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:15];
    [contentAdView addSubview:bodyView];
    
    UILabel *advertiserView = [[UILabel alloc]initWithFrame:CGRectMake(150, 150, 150, 30)];
    [contentAdView addSubview:advertiserView];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame: CGRectMake(0, 50, 150, 100)];
    [contentAdView addSubview:imageView];
    
    titleView.text = nativeContentAd.title;
    bodyView.text = nativeContentAd.desc;
    advertiserView.text = nativeContentAd.advertiser;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:nativeContentAd.imageUrl]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = image;
        });
    });
}

// 広告のロードが失敗した場合に呼ばれます。
- (void)dacSdkNativeAdLoader:(DACSDKNativeAdLoader * _Nonnull)loader didFailAdWithError:(enum DACSDKNativeAdError)error{
    NSLog(@"%ld", (long)error);
}

@end
