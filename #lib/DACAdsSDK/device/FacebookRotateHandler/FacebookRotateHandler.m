//
//  FacebookRotateHandler.m
//  FacebookRotateHandler
//
//  Copyright © 2016 D.A.Consortium Inc. All rights reserved.
//

#import "FacebookRotateHandler.h"
#import "DACAdsSDK.h"


@interface FacebookRotateAdapter: NSObject
@property (nonatomic, weak) DASMediationView *mediationView;
@property (nonatomic) FBAdView *adView;
@property (nonatomic) void (^completion)(void);
@end


@implementation FacebookRotateAdapter
/**
 初期化。
 */
- (instancetype)init {
    self = [super init];
    if (self) {
        self.mediationView = nil;
        self.adView = nil;
        self.completion = nil;
    }
    
    return self;
}

/**
 解放処理。
 */
- (void)dealloc {
    [self clean];
}

/**
 プロパティの解放処理。
 */
- (void)clean {
    self.completion = nil;
    
    self.adView.delegate = nil;
    [self.adView removeFromSuperview];
    self.adView = nil;
    
    self.mediationView.rotateHandler = nil;
    self.mediationView = nil;
}

@end


/**
 FacebookRotateHandler
 
 注： 
    2回以上連続で読み込みされた場合、再読みに時間がかかるため、その都度ビューの破棄解放処理は行いません。
    読み込みされた回数だけ広告表示の呼び出しがあり、最後の表示が完了次第、FacebookAdのビューを破棄します。
 */
@interface FacebookRotateHandler()
@property (nonatomic) NSString *placementID;
@property (nonatomic) FBAdSize adSize;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic) NSMapTable<DASMediationView *, FacebookRotateAdapter *> *adapters;
@end


@implementation FacebookRotateHandler

#pragma mark - LifeCycle
/**
 初期化。
 */
- (instancetype)init {
    self = [self initWithPlacementID:@"" adSize: kFBAdSize320x50 rootViewController: nil];
    if (self) {
    }
    
    return nil;
}

/**
 facebookの広告の設定の初期化。
 */
- (instancetype)initWithPlacementID:(NSString *)placementID
                             adSize:(FBAdSize)adSize
                 rootViewController:(nullable UIViewController *)viewController {
    self = [super init];
    if (self) {
        self.placementID = placementID;
        self.adSize = adSize;
        self.viewController = viewController;
        self.adapters = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory | NSMapTableObjectPointerPersonality
                                              valueOptions:NSMapTableStrongMemory];
    }
    
    return self;
}

/**
 解放処理。
 */
- (void)dealloc {
    [self.adapters removeAllObjects];
    self.adapters = nil;
    self.viewController = nil;
    self.placementID = nil;
}


#pragma mark - Private Methods
- (FacebookRotateAdapter *)adapterForAdView:(FBAdView *)adView {
    for (FacebookRotateAdapter *adapter in [self.adapters objectEnumerator]) {
        if (adapter.adView == adView) {
            return adapter;
        }
    }
    
    return nil;
}


#pragma mark - DASMediationRotateHandler Delagate
/**
 次の広告がfacebookだった際に、facebook広告のビューを作成します。
 
 - Parameter mediationView: An DASMediationView object sending the message.
 */
- (void)willPreLoadFacebookAd:(DASMediationView *)mediationView {
    FacebookRotateAdapter *adapter = [self.adapters objectForKey:mediationView];
    if (!adapter) {
        adapter = [[FacebookRotateAdapter alloc] init];
        adapter.mediationView = mediationView;
        [self.adapters setObject:adapter forKey:mediationView];
    }
    
    if (!adapter.adView) {
        // facebook広告のビューが破棄されている場合、再生成します。
        FBAdView *adView = [[FBAdView alloc] initWithPlacementID:self.placementID
                                                          adSize:self.adSize
                                              rootViewController:self.viewController];
        adView.delegate = self;
        adView.hidden = YES;
        [self.viewController.view addSubview:adView];
        
        [adView loadAd];

        adapter.adView = adView;
    }
    
    if (adapter.completion) {
        // facebook広告が連続で来た場合、ビューの破棄処理を解放します。
        adapter.completion = nil;
    }
}

/**
 facebook広告を表示します。

 - Parameter mediationView: An DASMediationView object sending the message.
 */
- (void)didDispatchedFacebookAd:(DASMediationView *)mediationView {
    __weak FacebookRotateAdapter *adapter = [self.adapters objectForKey:mediationView];
    if (adapter) {
        // DASMediationViewの座標からFBAdView座標に変換する。superviewが異なる可能性があるため。
        // また、大きさが可変の可能性もあるためsizeはFBAdViewのサイズを使用する。
        UIView *superview = self.viewController.view;
        CGRect frameToAdView = [mediationView convertRect:mediationView.bounds toView:superview];
        frameToAdView.origin = frameToAdView.origin;
        frameToAdView.size   = adapter.adView.bounds.size;
        adapter.adView.frame = frameToAdView;
        
        // 表示する
        adapter.adView.hidden = NO;
        
        if (!adapter.completion) {
            adapter.completion = ^(void) {
                // facebook広告のビューを破棄をします。
                adapter.adView.delegate = nil;
                [adapter.adView removeFromSuperview];
                adapter.adView = nil;
            };
        }
    }
}

/**
 facebook広告から切り替わる際にビューを破棄します。

 - Parameter mediationView: An DASMediationView object sending the message.
 */
- (void)didCompletedFacebookAd: (DASMediationView *)mediationView {
    FacebookRotateAdapter *adapter = [self.adapters objectForKey:mediationView];
    if (adapter) {
        if (adapter.completion) {
            // facebook広告のビューの破棄を実行します。
            adapter.completion();
            adapter.completion = nil;
        }
    }
}

- (void)mediationView:(DASMediationView *)mediationView didChangeIsHidden:(BOOL)isHidden {
    FacebookRotateAdapter *adapter = [self.adapters objectForKey:mediationView];
    if (adapter) {
        adapter.adView.hidden = isHidden;
    }
}

#pragma mark - FBAdViewDelegate
/**
 Sent when an ad has been successfully loaded.
 
 - Parameter adView: An FBAdView object sending the message.
 */
- (void)adViewDidLoad:(FBAdView *)adView {
    // 念の為、自動リフレッシュを無効にする。
    [adView disableAutoRefresh];
}

/**
 Sent after an ad has been clicked by the person.
 
 - Parameter adView: An FBAdView object sending the message.
 */
- (void)adViewDidClick:(FBAdView *)adView {
    FacebookRotateAdapter *adapter = [self adapterForAdView:adView];

    // Clickの実績イベントを発行
    [adapter.mediationView sendRequestParams:(@"Click")];
}

/**
 Sent after an FBAdView fails to load the ad.
 
 - Parameter adView: An FBAdView object sending the message.
 - Parameter error: An error object containing details of the error.
 */
- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error {
    FacebookRotateAdapter *adapter = [self adapterForAdView:adView];
    DASMediationView *targeMediationView = adapter.mediationView;
    
    // ビューなどを破棄します。
    [adapter clean];
    [self.adapters removeObjectForKey:targeMediationView];
    
    // メディエーションにエラーを通知します。
    [targeMediationView skipFbAd];
}

@end
