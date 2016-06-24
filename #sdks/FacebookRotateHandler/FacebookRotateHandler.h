//
//  FacebookRotateHandler.h
//  FacebookRotateHandler
//
//  Copyright (c) 2016年 D.A.Consortium. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBAudienceNetwork/FBAudienceNetwork.h"
#import "DACAdsSDK.h"
#import "DASMediationView.h"


@interface FacebookRotateHandler : NSObject <DASMediationRotateHandler,FBAdViewDelegate>

- (nullable instancetype)initWithPlacementID:(nonnull NSString *)placementID
                                      adSize:(FBAdSize)adSize
                          rootViewController:(nullable UIViewController *)viewController NS_DESIGNATED_INITIALIZER;

@end