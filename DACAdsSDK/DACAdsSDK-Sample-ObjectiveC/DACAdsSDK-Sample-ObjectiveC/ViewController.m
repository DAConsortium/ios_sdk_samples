//
//  ViewController.m
//  DACAdsSDK-Sample-ObjectiveC
//
//  Copyright © 2016 D.A.Consortium Inc. All rights reserved.
//

#import "ViewController.h"
#import "DASMediationView.h"
#import "DACAdsSDK.h"

@interface ViewController () <DASMediationViewDelegate>

@end

@implementation ViewController

const NSInteger placementID = 18859; //mediationのplacementIDを設定します。

- (void)viewDidLoad {
   [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    DASMediationView *mediationView = [[DASMediationView alloc] initWithFrame:CGRectMake(0.f, 20.f, 320.f, 50.f) placementID:placementID];
    mediationView.delegate = self;
    [self.view addSubview:mediationView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//メディエーションビューが表示される直前に呼ばれます。
- (void)DACMediationViewWillAppear:(DASMediationView *)mediationView
{
    NSLog(@"%s: placementID: %td", __PRETTY_FUNCTION__, mediationView.placementID);
}

//メディエーションビューが表示された直後に呼ばれます。
- (void)DACMediationViewDidAppear:(DASMediationView *)mediationView
{
    NSLog(@"%s: placementID: %td", __PRETTY_FUNCTION__, mediationView.placementID);
}

//メディエーションビューが非表示になる直前に呼ばれます。
- (void)DACMediationViewWillDisappear:(DASMediationView *)mediationView
{
    NSLog(@"%s: placementID: %td", __PRETTY_FUNCTION__, mediationView.placementID);
}

//メディエーションビューが非表示になった直後に呼ばれます。
- (void)DACMediationViewDidDisappear:(DASMediationView *)mediationView
{
    NSLog(@"%s: placementID: %td", __PRETTY_FUNCTION__, mediationView.placementID);
}

//メディエーションビュー内に広告がロードされたタイミングで呼ばれます。
- (void)DACMediationViewDidLoadAd:(DASMediationView *)mediationView
{
    NSLog(@"%s: placementID: %td", __PRETTY_FUNCTION__, mediationView.placementID);
}

//メディエーションビュー内の広告がタップされたタイミングで呼ばれます。
- (void)DACMediationViewDidClicked:(DASMediationView *)mediationView
{
    NSLog(@"%s: placementID: %td", __PRETTY_FUNCTION__, mediationView.placementID);
}

//メディエーションビュー内でエラーが発生したタイミングで呼ばれます。
- (void)DACMediationView:(DASMediationView *)mediationView didFailLoadWithError:(NSError *)error
{
    switch (error.code) {
        case DASErrorCodeTagDataNotFound:
            // 広告のタグデータが存在しなかった。
            NSLog(@"AdTag data not found.(placementID: %td)", mediationView.placementID);
            break;
        case DASErrorCodeTagDataRequestFailed:
            // 広告のタグデータ取得に失敗した。
            NSLog(@"AdTag data request failed.(placementID: %td/ reason: %@)", mediationView.placementID, error.localizedDescription);
            break;
        case DASErrorCodeAdRequestFailed:
            // 広告データの取得に失敗した。
            NSLog(@"Ad request failed.(placementID: %td/ reason: %@)", mediationView.placementID, error.localizedDescription);
            break;
        case DASErrorCodeUnknown:
        default:
            // その他エラー
            NSLog(@"Unknown error.(placementID: %td/ reason: %@)", mediationView.placementID, error.localizedDescription);
            break;
    }
}

@end
