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
 @file AKTwitterHelper.h
 @brief Twitter管理
 
 Twitterのツイートを管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

/// Twitter設定
enum AKTwitterMode {
    kAKTwitterModeOff = 0,  ///< Twitter連携Off
    kAKTwitterModeManual,   ///< 手動ツイート
    kAKTwitterModeAuto      ///< 自動ツイート
};

/// Twitter管理
@interface AKTwitterHelper : NSObject {
    /// Twitter設定
    enum AKTwitterMode mode_;
    /// Twitterアカウント
    ACAccount *twitterAccount_;
}

/// Twitterアカウント
@property (nonatomic, retain)ACAccount *twitterAccount;

// シングルトンオブジェクト取得
+ (AKTwitterHelper *)sharedHelper;
// Twitter設定取得
- (enum AKTwitterMode)mode;
// Twitter設定変更
- (void)setMode:(enum AKTwitterMode)mode;
// Twitterアカウント取得
- (void)requestAccount;
// Twitter View表示
- (void)viewTwitterWithInitialString:(NSString *)string;
// 自動ツイート
- (void)tweet:(NSString *)string;
@end
