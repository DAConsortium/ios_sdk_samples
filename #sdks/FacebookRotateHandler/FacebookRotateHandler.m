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
  BOOL facebookAdWillContinue;
}

static NSString *const kFacebookAdTagString = @"<!-- facebook -->";

- (instancetype) init {
    self = [self initWithPlacementID:@"" adSize: kFBAdSize320x50 rootViewController: nil];
    if (self) {
    }
    facebookAdWillContinue = NO;
    return nil;
}

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
    facebookAdWillContinue = NO;
    return self;
}

- (BOOL)DACMediationViewWillRotation: (DASMediationView *)mediationView
{
    self.mediationView = mediationView;
    
    if ([self.mediationView.adTag rangeOfString:kFacebookAdTagString].location != NSNotFound) {
        if (!facebookAdWillContinue){
        [self createFacebookAd];
        }
        return false;
    } else {
        self.mediationView.hidden = NO;
        [self removeFacebookAd];
        return true;
    }
    
    return true;
}

- (void)createFacebookAd
{
    facebookAdWillContinue = YES;
    self.adView = [[FBAdView alloc] initWithPlacementID:_placementID
                                             adSize:_adSize
                                 rootViewController:_viewController];
    self.adView.delegate = self;
    [self.adView loadAd];
    self.adView.frame = self.mediationView.frame;
    [self.viewController.view addSubview:self.adView];
}

- (void)removeFacebookAd
{
    facebookAdWillContinue = NO;
     self.adView.delegate = nil;
    [self.adView removeFromSuperview];
    self.adView = nil;
}

- (void)adViewDidLoad:_adView
{    
    self.mediationView.hidden = YES;
}

- (void)adViewDidClick:_adView
{
    //Clickの実績イベントを発行
    
    [self.mediationView sendRequestParams:(@"Click")];
}

@end
