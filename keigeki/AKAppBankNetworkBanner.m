/*!
 @file AKAppBankNetworkBanner.m
 @brief AppBankNetworkの広告バナー
 
 AppBankNetworkの広告バナーを管理するクラスを定義する。
 */

#import "AKAppBankNetworkBanner.h"
#import "AKCommon.h"

/*!
 @brief AppBankNetworkの広告バナー
 
 AppBankNetworkの広告バナーを管理する。
 */
@implementation AKAppBankNetworkBanner

@synthesize delegate = delegate_;
@synthesize nadView = nadView_;

/*!
 @brief インスタンス解放処理
 
 インスタンス解放時の処理を行う。
 メンバを解放する。
 */
- (void)dealloc
{
    AKLog(1, @"start");
    
    // 広告バナーのデリゲートを削除する
    self.nadView.delegate = nil;
    
    // メンバを解放する
    self.delegate = nil;
    self.nadView = nil;
    
    // スーパークラスの処理を実行する
    [super dealloc];
}

/*!
 @brief 広告バナー表示要求
 
 広告バナー表示要求があった時の処理。
 AddBankNetworkの広告バナーを生成する。
 @param adSize 広告サイズ
 @param serverParameter メディエーションで設定したパラメータ
 @param serverLabel メディエーションで設定したラベル
 @param request リクエスト情報
 */
- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(NSString *)serverParameter
                  label:(NSString *)serverLabel
                request:(GADCustomEventRequest *)request
{
    AKLog(1, @"広告バナー要求");
    
    // apiKey
    NSString *kAKAPIKey = @"f7d5cc28b8f5c709cf980e6ffbe5fb50d82e4313";
    // spotID
    NSString *kAKSpotID = @"24847";
    
    // 広告バナーを生成する
    self.nadView = [[[NADView alloc] initWithFrame:CGRectMake(0, 0, adSize.size.width, adSize.size.height)] autorelease];
    
    // apiKeyとspotIDを設定する
    [self.nadView setNendID:kAKAPIKey spotID:kAKSpotID];
    
    // デリゲートを設定する
    self.nadView.delegate = self;
    
    // RootViewControllerを設定する
    self.nadView.rootViewController = [[[UIViewController alloc] init] autorelease];
    
    // 広告を読み込む
    [self.nadView load];
}

/*!
 @brief ロード完了処理
 
 広告読み込み完了時の処理。
 デリゲートに通知を行う。
 @param adView 広告バナー
 */
- (void)nadViewDidFinishLoad:(NADView *)adView
{
    AKLog(1, @"広告読み込み完了");
    
    [self.delegate customEventBanner:self didReceiveAd:adView];
}

@end
