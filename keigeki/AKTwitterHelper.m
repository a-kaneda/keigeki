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
 @file AKTwitterHelper.m
 @brief Twitter管理
 
 Twitterのツイートを管理するクラスを定義する。
 */

#import <Twitter/Twitter.h>
#import "AKTwitterHelper.h"
#import "AKNavigationController.h"
#import "AKCommon.h"

/// Twitter設定のユーザーデフォルトのキー
static NSString *kAKTwitterModeKey = @"twitter_mode";

/*!
 @brief Twitter管理
 
 Twitterのツイートを管理する。
 */
@implementation AKTwitterHelper

/// シングルトンオブジェクト
static AKTwitterHelper *sharedHelper_ = nil;

@synthesize twitterAccount = twitterAccount_;

/*!
 @brief シングルトンオブジェクト取得
 
 シングルトンオブジェクトを取得する。
 まだ生成されていない場合は生成を行う。
 @return シングルトンオブジェクト
 */
+ (AKTwitterHelper *)sharedHelper
{
    // 他のスレッドで同時に実行されないようにする
    @synchronized(self) {
        
        // シングルトンオブジェクトが生成されていない場合は生成する
        if (!sharedHelper_) {
            sharedHelper_ = [[AKTwitterHelper alloc] init];
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
 
 インスタンス初期化時の処理。
 自動ツイート設定をユーザーデフォルトから取得する。
 Twitterアカウント認証を行う。
 @return 初期化したインスタンス。失敗時はnilを返す。
 */
- (id)init
{
    // スーパークラスの初期化処理を実行する
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 自動ツイート設定の初期値を設定する
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaultData = [NSMutableDictionary dictionaryWithCapacity:1];
    [defaultData setObject:[NSNumber numberWithInteger:kAKTwitterModeManual] forKey:kAKTwitterModeKey];
    [userDefaults registerDefaults:defaultData];
    
    // Twitter設定を読み込む
    mode_ = [userDefaults integerForKey:kAKTwitterModeKey];
    
    // Twitterアカウント認証を行う
    [self requestAccount];
    
    return self;
}

/*!
 @brief インスタンス解放処理
 
 インスタンス解放時の処理。
 メンバを解放する。
 */
- (void)dealloc
{
    // メンバを解放する
    self.twitterAccount = nil;
    
    // スーパークラスの解放処理を実行する
    [super dealloc];
}

/*!
 @brief Twitter設定取得
 
 Twitter設定を取得する。
 @return Twitter設定
 */
- (enum AKTwitterMode)mode
{
    return mode_;
}

/*!
 @brief Twitter設定変更
 
 Twitter設定を変更する。
 変更後にユーザーデフォルトの書き込みを行う。
 @param mode Twitter設定
 */
- (void)setMode:(enum AKTwitterMode)mode
{
    // メンバを変更する
    mode_ = mode;
    
    // 自動ツイート設定をユーザーデフォルトに書き込む
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:mode_ forKey:kAKTwitterModeKey];
    
    AKLog(1, @"モード変更:%d", self.mode);
    
    // 自動設定になった場合はアカウント情報を取得する
    if (self.mode == kAKTwitterModeAuto && self.twitterAccount == nil) {
        [self requestAccount];
    }
}

/*!
 @brief Twitterアカウント取得
 
 TwitterアカウントをiOSから取得する。
 */
- (void)requestAccount
{
    AKLog(1, @"Twitterアカウント認証開始");
    
    // 認証前にメンバを初期化する
    self.twitterAccount = nil;
    
    // Create an account store object.
	ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
	
	// Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
	// Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        
        AKLog(granted, @"アカウント取得成功");
        AKLog(!granted, @"アカウント取得に失敗:error=%@", error != nil ? error.description : @"(errorなし)");
        
        if(granted) {
            
			// Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            AKLog([accountsArray count] <= 0, @"アカウント数が0");
			
			// For the sake of brevity, we'll assume there is only one Twitter account present.
			// You would ideally ask the user which account they want to tweet from, if there is more than one Twitter account present.
			if ([accountsArray count] > 0) {
                
				// Grab the initial Twitter account to tweet from.
				self.twitterAccount = [accountsArray objectAtIndex:0];
                
                AKLog(1, @"Twitterアカウント認証成功:%@", self.twitterAccount.username);
			}
        }
	}];}

/*!
 @brief Twitter View表示
 
 初期文字列を指定してTwitter Viewを表示する。
 @brief string 初期文字列
 */
- (void)viewTwitterWithInitialString:(NSString *)string
{
    // Root Viewを取得する
    AKNavigationController *viewController = (AKNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    // Twitter Viewを表示する
    [viewController viewTwitterWithInitialString:string];
}

/*!
 @brief 自動ツイート
 
 自動的にツイートを行う。
 @brief ツイート内容
 */
- (void)tweet:(NSString *)string
{
    AKLog(1, @"自動ツイート開始:%@", string);
    
    // アカウント情報が取得できていない場合は取得する
    if (self.twitterAccount == nil) {
        [self requestAccount];
    }
    
    // ツイート内容を作成する
    NSDictionary *tweetData = [NSDictionary dictionaryWithObject:string forKey:@"status"];
                
    // postリクエストを作成する
	TWRequest *postRequest = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"]
                                                  parameters:tweetData
                                               requestMethod:TWRequestMethodPOST] autorelease];
				
    // Set the account used to post the tweet.
    [postRequest setAccount:self.twitterAccount];
                
    // リクエストを実行する
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        AKLog(1, @"ツイートの実行完了");
        AKLog(error != nil, @"error:%@", error.description);
        
        
        if (responseData) {
#ifndef DEBUG
            [NSJSONSerialization JSONObjectWithData:responseData
                                            options:NSJSONReadingMutableLeaves
                                              error:nil];
#else
            id data =[NSJSONSerialization JSONObjectWithData:responseData
                                                     options:NSJSONReadingMutableLeaves
                                                       error:nil];
            AKLog(1, @"%@", data);
#endif
        }
    }];
}

@end
