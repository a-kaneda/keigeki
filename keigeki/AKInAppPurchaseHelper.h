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
