//
//  DACAdsSDK.h
//  DACAdsSDK
//
//  Copyright (c) 2014年 D.A.Consortium. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark NSError Domain, Code.

FOUNDATION_EXTERN NSString *const DASErrorDomain;

typedef NS_ENUM(NSInteger, DASErrorCode) {
    DASErrorCodeUnknown = 9000,
    DASErrorCodeTagDataNotFound,
    DASErrorCodeTagDataRequestFailed,
    DASErrorCodeAdRequestFailed,
};


#pragma mark - DACAdsSDK class

/*!
 * D.A.C Ads SDK Class
 */
@interface DACAdsSDK : NSObject


#pragma mark - Public methods

/*!
 * SDKの初期化処理をおこないます。
 */
+ (void)prepare;

/*!
 * SDKのバージョンを返します。
 * @return SDK version
 */
+ (NSString *)version;

/*!
 * デバッグモードをセットします。
 *
 * @param isDebug
 */
+ (void)setDebugMode:(BOOL)isDebug;

@end
