/*
 * Copyright (c) 2012-2013 Akihiro Kaneda.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   1.Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *   2.Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *   3.Neither the name of the Monochrome Soft nor the names of its contributors
 *     may be used to endorse or promote products derived from this software
 *     without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
/*!
 @file AKInAppPurchaseHelper.m
 @brief アプリ内課金管理
 
 アプリ内課金を管理するクラスを定義する。
 */

#import "cocos2d.h"
#import "AKInAppPurchaseHelper.h"
#import "AKCommon.h"
#import "AKOptionScene.h"
#import "AKNavigationController.h"

/// コンティニュー解除のプロダクトID
static NSString *kAKProductIDContinue = @"continue";
/// 広告解除の設定のキー
static NSString *kAKRemoveAdKey = @"remove_ad";
/// 2周目解除の設定のキー
static NSString *kAKContinue = @"continue";

/*!
 @brief アプリ内課金管理クラス
 
 アプリ内課金を管理する。
 */
@implementation AKInAppPurchaseHelper

/// シングルトンオブジェクト
static AKInAppPurchaseHelper *sharedHelper_ = nil;

@synthesize isRemoveAd = isRemoveAd_;
@synthesize isEnableContinue = isEnableContinue_;

/*!
 @brief シングルトンオブジェクト取得
 
 シングルトンオブジェクトを取得する。
 まだ生成されていない場合は生成を行う。
 @return シングルトンオブジェクト
 */
+ (AKInAppPurchaseHelper *)sharedHelper
{
    // 他のスレッドで同時に実行されないようにする
    @synchronized(self) {
        
        // シングルトンオブジェクトが生成されていない場合は生成する
        if (!sharedHelper_) {
            sharedHelper_ = [[AKInAppPurchaseHelper alloc] init];
        }
        
        return sharedHelper_;
    }
    
    return nil;
}

/*!
 @brief インスタンス生成処理
 
 インスタンス生成処理。
 シングルトンのため、二重に生成された場合はアサーションを出力する。
 */
+ (id)alloc
{
    // 他のスレッドで同時に実行されないようにする
    @synchronized(self) {
        
		NSAssert(sharedHelper_ == nil, @"Attempted to allocate a second instance of a singleton.");
        return [super alloc];
    }
    
    return nil;
}

/*!
 @brief インスタンス初期化処理
 
 インスタンス初期化処理。
 ペイメントキューに自分をオブザーバーとして登録する。
 @return 初期化したインスタンス
 */
- (id)init
{
    // スーパークラスの処理を実行する
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 設定の初期値を設定する
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaultData = [NSMutableDictionary dictionaryWithCapacity:2];
    [defaultData setObject:[NSNumber numberWithBool:NO] forKey:kAKRemoveAdKey];
    [defaultData setObject:[NSNumber numberWithBool:NO] forKey:kAKContinue];
    [userDefaults registerDefaults:defaultData];
    
    // テスト用、課金情報をクリアする
//    [userDefaults setBool:NO forKey:kAKRemoveAdKey];
//    [userDefaults setBool:NO forKey:kAKContinue];
    
    // 広告解除の設定を読み込む
    isRemoveAd_ = [userDefaults boolForKey:kAKRemoveAdKey];
    
    // コンティニュー解除の設定を読み込む
    isEnableContinue_ = [userDefaults boolForKey:kAKContinue];
    
    AKLog(1, @"isRemoveAd=%d isEnableContinue=%d", isRemoveAd_, isEnableContinue_);
    
    // ペイメントキューにオブザーバーとして登録する
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    return self;
}

/*!
 @brief インスタンス解放処理
 
 インスタンス解放時の処理を行う。
 オブザーバーの削除を行う。
 */
- (void)dealloc
{
    // オブザーバーの削除を行う
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    
    // スーパークラスの処理を実行する
    [super dealloc];
}

/*!
 @brief 課金可能かチェックする
 
 課金可能な設定になっているかチェックする。
 @return 課金可能かどうか
 */
- (BOOL)canMakePayments
{
    // 課金可能な場合
    if ([SKPaymentQueue canMakePayments]) {
        return YES;
    }
    // 課金不能な場合
    else {
        return NO;
    }
}

/*!
 @brief プロダクト情報要求
 
 プロダクト情報を要求する。
 */
- (void)requestProductData
{
    AKLog(1, @"プロダクト情報要求");
    
    // アプリ課金のプロダクトID;
    NSSet *productIDs = [NSSet setWithObject:kAKProductIDContinue];
    
    // リクエストを作成する
    SKProductsRequest *request = [[[SKProductsRequest alloc] initWithProductIdentifiers:productIDs] autorelease];
    
    // デリゲートを設定する
    request.delegate = self;
    
    // リクエストを開始する
    [request start];
}

/*!
 @brief プロダクト情報受信
 
 プロダクト情報を受信する。
 SKProductRequestのデリゲート。
 ペイメントオブジェクトを作成し、キューに登録する。
 @param request リクエスト
 @param response プロダクト情報
 */
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    AKLog(1, @"プロダクト情報受信");
    
    // エラー情報を調べる
    if (response.invalidProductIdentifiers.count > 0) {
        
        // エラーメッセージを作成する
        NSString *message = NSLocalizedString(@"ErrorGetAddOnInfo", @"アドオン情報取得失敗");
        
        // アラートビューを作成する
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:message
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil] autorelease];
        
        // アラートビューを表示する
        [alert show];
        
        // 処理を中断する
        return;
    }
    
    // プロダクト情報を取り出す
    for (SKProduct *product in response.products) {
        
        // ペイメントオブジェクトを作成する
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        
        // ペイメントキューに登録する
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

/*!
 @brief トランザクション受信処理
 
 ペイメントトランザクション完了時の処理を実行する。
 @param queue ペイメントキュー
 @param transactions トランザクション
 */
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    AKLog(1, @"start");
    
    // 各トランザクションを処理する
    for (SKPaymentTransaction *transaction in transactions) {
        
        // トランザクションの状態によって処理を分岐する
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:    // 購入完了
                [self completeTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:       // 購入失敗
                [self failedTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateRestored:     // リストア完了
                [self restoreTransaction:transaction];
                break;
                
            default:
                break;
        }
    }
}

/*!
 @brief リストア失敗時処理
 
 リストア失敗時の処理を行う。
 @param queue ペイメントキュー
 @param error エラー
 */
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    AKLog(1, @"start : error=%@", error.description);
    
    // 通信終了処理を行う
    [self endConnect];
}

/*!
 @brief リストア完了時処理
 
 リストアが完了した時の処理を行う。
 @param queue ペイメントキュー
 */
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    AKLog(1, @"start");
    
    // 通信終了処理を行う
    [self endConnect];

}

/*!
 @brief トランザクション完了処理
 
 すべてのトランザクションが完了した時の処理を行う。
 通信処理を終了する。
 @param queue ペイメントキュー
 @param transactions トランザクション
 */
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    AKLog(1, @"start");
    
    // 通信終了処理を行う
    [self endConnect];
}

/*!
 @brief 購入完了処理
 
 購入が完了した時の処理を行う。
 @param transaction トランザクション
 */
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    AKLog(1, @"購入完了:ID=%@", transaction.payment.productIdentifier);
    
    // コンティニュー解除の場合はコンティニュー解除処理を行う
    if ([transaction.payment.productIdentifier isEqualToString:kAKProductIDContinue]) {
        [self enableContinue];
    }
    
    // ペイメントキューからトランザクションを削除する
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

/*!
 @brief 購入失敗処理
 
 購入が失敗した時の処理を行う。
 @param transaction トランザクション
 */
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    AKLog(1, @"購入失敗");
    
    // ペイメントキューからトランザクションを削除する
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

/*!
 @brief リストア完了処理
 
 リストアが完了した時の処理を行う。
 @param transaction トランザクション
 */
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    AKLog(1, @"リストア完了:ID=%@", transaction.payment.productIdentifier);
    
    // コンティニュー解除の場合はコンティニュー解除処理を行う
    if ([transaction.payment.productIdentifier isEqualToString:kAKProductIDContinue]) {
        [self enableContinue];
    }
    
    // ペイメントキューからトランザクションを削除する
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

/*!
 @brief コンティニュー解除
 
 コンティニュー機能を解除する。
 また、広告バナーの削除も行う。
 */
- (void)enableContinue
{
    AKLog(1, @"start");
    
    // ユーザーデフォルトを取得する
    NSUserDefaults *userDefaults= [NSUserDefaults standardUserDefaults];
    
    // 広告解除の設定を有効にする
    isRemoveAd_ = YES;
    [userDefaults setBool:isRemoveAd_ forKey:kAKRemoveAdKey];
    
    // コンティニュー解除の設定を有効にする
    isEnableContinue_ = YES;
    [userDefaults setBool:isEnableContinue_ forKey:kAKContinue];
    
    // Navigation Controllerを取得する
    AKNavigationController *navigationController = (AKNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    // 広告バナーを削除する
    [navigationController deleteAdBanner];
}

/*!
 @brief 購入要求
 
 購入を行う。
 */
- (void)buy
{
    // プロダクト情報を要求する
    [self requestProductData];
}

/*!
 @brief リストア要求
 
 リストアを行う。
 */
- (void)restore
{
    // リストアを行う
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

/*!
 @brief 通信終了
 
 通信終了時の処理を行う。
 オプション画面シーンに通信終了を通知する。
 */
- (void)endConnect
{
    // 実行中のシーンを取得する
    CCScene *scene = [[CCDirector sharedDirector] runningScene];
    
    // オプション画面の場合は通信中のビューを閉じる
    if ([scene isKindOfClass:[AKOptionScene class]]) {
        
        // オプション画面シーンクラスにキャストする
        AKOptionScene *optionScene = (AKOptionScene *)scene;
        
        // 通信終了を通知する
        [optionScene endConnect];
        
        // 購入ボタン、リストアボタンを削除するためにページ番号更新を行う
        optionScene.pageNo = optionScene.pageNo;
    }
}

@end
