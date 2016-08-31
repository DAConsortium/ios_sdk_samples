//
//  FacebookRotateHandler.m
//  FacebookRotateHandler
//
//  Copyright © 2016 D.A.Consortium Inc. All rights reserved.
//

#import "FacebookRotateHandler.h"
#import "DACAdsSDK.h"

@interface FacebookRotateHandler()
    @property DASMediationView *mediationView;
    @property FBAdView *adView;
    @property FBAdSize adSize;
    @property NSString *placementID;
    @property (weak) UIViewController *viewController;
@end

@implementation FacebookRotateHandler
{
  BOOL _facebookAdWillContinue;
}

- (instancetype) init {
    self = [self initWithPlacementID:@"" adSize: kFBAdSize320x50 rootViewController: nil];
    if (self) {
    }
    return nil;
}

//facebookの広告の設定の初期化
- (instancetype)initWithPlacementID:(NSString *)placementID
                             adSize:(FBAdSize)adSize
                 rootViewController:(nullable UIViewController *)viewController
{
    self = [super init];
    if (self) {
        self.placementID = placementID;
        self.adSize = adSize;
        self.viewController = viewController;
    }
    return self;
}

//次の広告がfacebookだった際に、facebook広告のビューを作成する
- (void) willPreLoadFacebookAd: (DASMediationView *)mediationView
{
    if(!_facebookAdWillContinue){
     self.mediationView = mediationView;
    
     self.adView = [[FBAdView alloc] initWithPlacementID:_placementID
                                                  adSize:_adSize
                                     rootViewController:_viewController];
     self.adView.delegate = self;
     [self.adView loadAd];
     self.adView.frame = self.mediationView.frame;
     self.adView.hidden = YES;
     [self.viewController.view addSubview:self.adView];
    }
}

//facebook広告を表示する
- (void) didDispatchedFacebookAd: (DASMediationView *)mediationView
{
    self.adView.hidden = NO;
    _facebookAdWillContinue = YES;
}

//facebook広告から切り替わる際にビューを破棄する
- (void) didCompletedFacebookAd: (DASMediationView *)mediationView
{
    self.adView.delegate = nil;
    [self.adView removeFromSuperview];
    self.adView = nil;
    _facebookAdWillContinue = NO;
}

//facebook広告が読まれた際に呼ばれる
- (void)adViewDidLoad:_adView
{
    //とくになし
}

//facebook広告がタップされた際に呼ばれる
- (void)adViewDidClick:_adView
{
    //Clickの実績イベントを発行
    [self.mediationView sendRequestParams:(@"Click")];

    //メディエーションのローテーションを停止する処理の実行
    [self.mediationView didClickedFacebookAd];
}
- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error {
    
    //メディエーションにエラーを通知する処理
    [self.mediationView didFacebookAdError];
    
    //ビューを破棄する
    self.adView.delegate = nil;
    [self.adView removeFromSuperview];
    self.adView = nil;
}

@end
