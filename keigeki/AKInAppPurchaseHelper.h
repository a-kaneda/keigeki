/*!
 @file AKInAppPurchaseHelper.h
 @brief アプリ内課金管理
 
 アプリ内課金を管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

// アプリ内課金管理クラス
@interface AKInAppPurchaseHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    /// 広告解除有無
    BOOL isRemoveAd_;
    /// コンティニュー有無
    BOOL isEnableContinue_;
}

/// 広告解除有無
@property (nonatomic, readonly)BOOL isRemoveAd;
/// 2周目有無
@property (nonatomic, readonly)BOOL isEnableContinue;

// シングルトンオブジェクト取得
+ (AKInAppPurchaseHelper *)sharedHelper;
// 課金可能かチェックする
- (BOOL)canMakePayments;
// プロダクト情報要求
- (void)requestProductData;
// 購入完了処理
- (void)completeTransaction:(SKPaymentTransaction *)transaction;
// 購入失敗処理
- (void)failedTransaction:(SKPaymentTransaction *)transaction;
// リストア完了処理
- (void)restoreTransaction:(SKPaymentTransaction *)transaction;
// コンティニュー解除
- (void)enableContinue;
// 購入要求
- (void)buy;
// リストア要求
- (void)restore;
// 通信終了
- (void)endConnect;

@end
