//
//  DASMediationView.h
//  DACAdsSDK
//
//  Copyright © 2016 D.A.Consortium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DASMediationViewDelegate;
@protocol DASMediationRotateHandler;


#pragma mark - DASAdType
/*!
 * 広告タイプ
 */
typedef NS_ENUM(NSInteger, DASAdType) {
    DASAdTypeNone,
    DASAdTypeWebView,
    DASAdTypeFacebook
};


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

/*!
 * @property デリゲートオブジェクト
 */
@property (nonatomic, weak) id <DASMediationViewDelegate> delegate;
@property (nonatomic, weak) id <DASMediationRotateHandler> rotateHandler;

/// 現在表示されている広告の広告タイプ
@property (nonatomic) DASAdType adType;


/*!
 * constructor
 *
 * @param frame
 * @param placementID
 *
 * @return DASMediationView
 */
- (instancetype)initWithFrame:(CGRect)frame placementID:(NSUInteger)placementID;

/*!
 * resume ad rotation.
 */
- (void)resume;

/*!
 * pause ad rotation.
 */
- (void)pause;

- (void)sendRequestParams:(NSString *)event;
- (void)skipFbAd;
- (void)clickFbAd;

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
- (void)dacMediationViewWillAppear:(DASMediationView *)mediationView;

/*!
 * メディエーションビューが表示された直後に呼ばれます。
 * @param mediationView
 */
- (void)dacMediationViewDidAppear:(DASMediationView *)mediationView;

/*!
 * メディエーションビューが非表示になる直前に呼ばれます。
 * @param mediationView
 */
- (void)dacMediationViewWillDisappear:(DASMediationView *)mediationView;

/*!
 * メディエーションビューが非表示になった直後に呼ばれます。
 * @param mediationView
 */
- (void)dacMediationViewDidDisappear:(DASMediationView *)mediationView;

/*!
 * メディエーションビューに関する広告が切り替わる直前に呼ばれます。
 * @param mediationView
 */
- (void)dacMediationViewWillLoadAd:(DASMediationView *)mediationView;

/*!
 * メディエーションビューに関する広告が切り替わった直後に呼ばれます。
 * @param mediationView
 */
- (void)dacMediationViewDidLoadAd:(DASMediationView *)mediationView;

/*!
 * メディエーションビュー内の広告がタップされたタイミングで呼ばれます。
 * @param mediationView
 */
- (void)dacMediationViewDidClicked:(DASMediationView *)mediationView;

/*!
 * メディエーションビュー内でエラーが発生したタイミングで呼ばれます。
 *
 * @param mediationView
 * @param error         NSError
 */
- (void)dacMediationView:(DASMediationView *)mediationView didFailLoadWithError:(NSError *)error;

@end

@protocol DASMediationRotateHandler <NSObject>

@optional

- (void)willPreLoadFacebookAd:(DASMediationView *)mediationView;

- (void)didDispatchedFacebookAd:(DASMediationView *)mediationView;

- (void)didCompletedFacebookAd:(DASMediationView *)mediationView;

- (void)didPreLoadFacebookAd:(DASMediationView *)mediationView;

- (void)mediationView:(DASMediationView *)mediationView didChangeIsHidden:(BOOL)isHidden;

@end
