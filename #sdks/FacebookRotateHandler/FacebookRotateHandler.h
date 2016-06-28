//
//  FacebookRotateHandler.h
//  FacebookRotateHandler
//
//  Copyright © 2016 D.A.Consortium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBAudienceNetwork/FBAudienceNetwork.h"
#import "DASMediationView.h"


@interface FacebookRotateHandler : NSObject <DASMediationRotateHandler,FBAdViewDelegate>


- (nullable instancetype)initWithPlacementID:(nonnull NSString *)placementID
                                      adSize:(FBAdSize)adSize
                          rootViewController:(nullable UIViewController *)viewController NS_DESIGNATED_INITIALIZER;

@end
