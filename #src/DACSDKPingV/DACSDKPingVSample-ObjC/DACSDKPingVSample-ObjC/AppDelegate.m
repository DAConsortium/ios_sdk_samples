//
//  AppDelegate.m
//  DACSDKPingVSample-ObjC
//
//  Copyright (c) 2016 D.A.Consortium Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <DACSDKPingV/DACSDKPingV-Swift.h>


NSString* ownerID = @"OwnerIDを設定してください";

@interface AppDelegate () <DACSDKPingVApplicationDataCenterDelegate>
@property NSInteger eventCount;
@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"----- applicationDidFinishLaunchingWithOptions -----");
    
    self.eventCount = 0;
    
    // --------------------------------------------------
    // MARK: DACSDKPingV 設定
    // --------------------------------------------------
    // 初期化
    DACSDKPingV.shared.debugMode = NO;
    [DACSDKPingV.shared setupWithOid:ownerID];
    
    DACSDKPingV.shared.applicationDataCenter.autoSend = YES;
    DACSDKPingV.shared.applicationDataCenter.autoRestart = YES;
    
    DACSDKPingV.shared.applicationDataCenter.delegate = self;
    DACSDKPingV.shared.applicationDataCenter.page_id = @"sample";
    [DACSDKPingV.shared.applicationDataCenter replaceExtras:@{
                                               @"dev language": @"Objective-C",
                                               @"library type": @"dynamic-framework",
                                               }];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"----- applicationWillResignActive -----");
    
    // --------------------------------------------------
    // MARK: DACSDKPingV event_ids 設定
    // --------------------------------------------------
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeStyle = NSDateFormatterShortStyle;
    NSString* dateString = [formatter stringFromDate: [NSDate date]];
    DACSDKPingV.shared.applicationDataCenter.event_ids = @[dateString, @"objc", [NSString stringWithFormat:@"%ld", (long)self.eventCount++]];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"----- applicationDidEnterBackground -----");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"----- applicationWillEnterForeground -----");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"----- applicationDidBecomeActive -----");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"----- applicationWillTerminate -----");
}

// --------------------------------------------------
// MARK: DACSDKPingVApplicationDataCenter
// --------------------------------------------------
- (void)dacSdkPingVWithApplicationDataCenter:(DACSDKPingVApplicationDataCenter * _Nonnull)applicationDataCenter didSendApplicationDataWithError:(NSError * _Nullable)error {
    if (error) {
        NSLog(@"ping failed: error = \(error).");
    }
    else {
        NSLog(@"ping succeeded.");
    }
}

@end
