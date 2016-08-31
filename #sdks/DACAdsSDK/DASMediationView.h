//
//  DASMediationView.h
//  DACAdsSDK
//
//  Copyright © 2016 D.A.Consortium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DASMediationViewDelegate;
@protocol DASMediationRotateHandler;

#pragma mark - DASMediationView

/*!
 * メディエーション広告表示クラス
 * 
 * InterfaceBuilder/StoryBoard で配置する場合は、必ず placementID をセットして下さい。
 */
@interface DASMediationView : UIView

/*!
 * @property placementID
 */
@property (nonatomic) NSUInteger placementID;

@property (nonatomic) NSString* adTag;

/*!
 * @property デリゲートオブジェクト
 */
@property (nonatomic, weak) id <DASMediationViewDelegate> delegate;
@property (nonatomic, weak) id <DASMediationRotateHandler> rotateHandler;

/*!
 * constructor
 *
 * @param frame
 * @param placementID
 *
 * @return DASMediationView
 */
- (instancetype)initWithFrame:(CGRect)frame placementID:(NSUInteger)placementID;
- (void)sendRequestParams:(NSString *)event;
- (void)didFacebookAdError;
- (void)didClickedFacebookAd;

@end


#pragma mark - DASMediationViewDelegate

/*!
 * メディエーション広告デリゲートプロトコル
 */
@protocol DASMediationViewDelegate <NSObject>

@optional

/*!
 * メディエーションビューが表示される直前に呼ばれます。
 * @param mediationView
 */
- (void)DACMediationViewWillAppear:(DASMediationView *)mediationView;

/*!
 * メディエーションビューが表示された直後に呼ばれます。
 * @param mediationView
 */
- (void)DACMediationViewDidAppear:(DASMediationView *)mediationView;

/*!
 * メディエーションビューが非表示になる直前に呼ばれます。
 * @param mediationView
 */
- (void)DACMediationViewWillDisappear:(DASMediationView *)mediationView;

/*!
 * メディエーションビューが非表示になった直後に呼ばれます。
 * @param mediationView
 */
- (void)DACMediationViewDidDisappear:(DASMediationView *)mediationView;

/*!
 * メディエーションビュー内に広告がロードされたタイミングで呼ばれます。
 * @param mediationView
 */
- (void)DACMediationViewDidLoadAd:(DASMediationView *)mediationView;

/*!
 * メディエーションビュー内の広告がタップされたタイミングで呼ばれます。
 * @param mediationView
 */
- (void)DACMediationViewDidClicked:(DASMediationView *)mediationView;

/*!
 * メディエーションビュー内でエラーが発生したタイミングで呼ばれます。
 *
 * @param mediationView
 * @param error         NSError
 */
- (void)DACMediationView:(DASMediationView *)mediationView didFailLoadWithError:(NSError *)error;

@end

@protocol DASMediationRotateHandler <NSObject>

@optional

- (void) willPreLoadFacebookAd: (DASMediationView *)mediationView;

- (void) didDispatchedFacebookAd: (DASMediationView *)mediationView;

- (void) didCompletedFacebookAd: (DASMediationView *)mediationView;

@end