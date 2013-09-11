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
 @file AKNavigationController.m
 @brief UINavigationControllerのカスタマイズ
 
 UINavigationControllerのカスタマイズクラスを定義する。
 */

#import <Twitter/TWTweetComposeViewController.h>
#import "AKNavigationController.h"
#import "AKCommon.h"
#import "AKScreenSize.h"
#import "AKGameScene.h"
#import "SimpleAudioEngine.h"
#import "AKInAppPurchaseHelper.h"

/// アプリのURL
static NSString *kAKAplUrl = @"https://itunes.apple.com/us/app/qing-ji/id569653828?l=ja&ls=1&mt=8";
/// AdMobパブリッシャーID
static NSString *kAKAdMobID = @"ca-app-pub-8055460627535570/7187368047";

/*!
 @brief UINavigationControllerのカスタマイズ
 
 UINavigationControllerのカスタマイズ。
 画面回転処理とGame Centerのdelegateを実装。
 */
@implementation AKNavigationController

@synthesize bannerView = bannerView_;

/*!
 @brief 初期化処理
 
 初期化処理を行う。
 スーパークラスの処理をそのまま実行する。
 @param nibNameOrNil xibファイル名
 @param nibBundleOrNil バンドル
 @return 初期化されたインスタンス
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*!
 @brief 解放時処理
 
 解放時の処理を行う。
 メンバを解放する。
 */
- (void)dealloc
{
    // viewDidLoadで生成したオブジェクトを解放する
    [self viewDidUnload];
    
    // スーパークラスの処理を実行する
    [super dealloc];
}

/*!
 @brief 読み込み時処理
 
 ビューが読み込まれたときの処理。
 AdMobの広告バナーを生成する。
 */
- (void)viewDidLoad
{
    AKLog(1, @"start");
    
    // スーパークラスの処理を実行する
    [super viewDidLoad];

    // 広告解除が無効の場合は広告を作成する
    if (![[AKInAppPurchaseHelper sharedHelper] isRemoveAd]) {
        [self createAdBanner];
    }
    
    AKLog(1, @"end");
}

/*!
 @brief メモリ不足時の処理
 
 メモリが不足したときの処理。
 viewDidLoadで生成したオブジェクトを解放する。
 */
- (void)viewDidUnload
{
    // 広告バナーを解放する
    [self deleteAdBanner];
    
    // スーパークラスの処理を実行する
    [super viewDidUnload];
}

/*!
 @brief メモリ不足時の処理
 
 メモリが不足したときの処理。
 スーパークラスの処理をそのまま実行する。
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*!
 @brief 回転可否判定
 
 画面回転処理を行うかどうかを判定する。
 常にYESを返す。
 @return 回転処理を行う場合YES、行わない場合NO
 */
- (BOOL)shouldAutorotate
{
    return YES;
}

/*!
 @brief 回転できる画面の向き
 
 回転できる画面の向きを返す。
 左側にホームボタンを配置した横向きのみを許可する。
 @return 回転できる画面の向き
 */
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

/*!
 @brief Leaderboard終了処理
 
 Leaderboard終了時にLeaderboardを閉じる。
 @param viewController LeaderboardのView Controller
 */
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
}

/*!
 @brief Achievements終了処理
 
 Achievemets終了時にAchievementsを閉じる。
 @param viewController AchievementsのView Controller
 */
- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
}

/*!
 @brief 広告バナーを作成
 
 広告バナーを作成する。
 */
- (void)createAdBanner
{
    AKLog(1, @"start");
    
    // 画面下部に標準サイズのビューを作成する
    self.bannerView = [[[GADBannerView alloc] initWithFrame:CGRectMake(0.0,
                                                                       self.view.bounds.size.height - GAD_SIZE_320x50.height,
                                                                       GAD_SIZE_320x50.width,
                                                                       GAD_SIZE_320x50.height)]
                       autorelease];
    
    // 広告の「ユニット ID」を指定する。これは AdMob パブリッシャー ID です。
    self.bannerView.adUnitID = kAKAdMobID;
    
    // デリゲートを設定する
    self.bannerView.delegate = self;
    
    // ユーザーに広告を表示した場所に後で復元する UIViewController をランタイムに知らせて
    // ビュー階層に追加する。
    self.bannerView.rootViewController = self;
    [self.view addSubview:self.bannerView];
    
    // 広告リクエストを作成する
    GADRequest *request = [GADRequest request];
    
    // リクエストを行って広告を読み込む
    [self.bannerView loadRequest:request];
    
    AKLog(1, @"end");
}

/*!
 @brief 広告バナーを削除
 
 広告バナーを削除する。
 */
- (void)deleteAdBanner
{
    AKLog(1, @"start");
    
    // バナーを取り除く
    [self.bannerView removeFromSuperview];
    
    // デリゲートを削除する
    self.bannerView.delegate = nil;
    
    // バナーを削除する
    self.bannerView = nil;
    
    AKLog(1, @"end");
}

/*!
 @brief Twitter Viewの表示
 
 Twitter Viewを表示する。
 */
- (void)viewTwitterWithInitialString:(NSString *)string
{
    // Twitter Viewを生成する
    TWTweetComposeViewController *viewController = [[[TWTweetComposeViewController alloc] init] autorelease];
    
    // 初期文字列を設定する
    [viewController setInitialText:string];

    // URLを設定する
    [viewController addURL:[NSURL URLWithString:kAKAplUrl]];
    
    // Twitter Viewを閉じる時の処理を設定する
    viewController.completionHandler = ^(TWTweetComposeViewControllerResult res) {
        
        // 送信完了時のログを出力する
        AKLog(res == TWTweetComposeViewControllerResultDone, @"Tweet送信完了");
        
        // 送信キャンセル時のログを出力する
        AKLog(res == TWTweetComposeViewControllerResultCancelled, @"Tweetキャンセル");
        
        // モーダルウィンドウを閉じる
        [self dismissModalViewControllerAnimated:YES];
    };
    
    AKLog(1, @"Twitter View表示");
    // Twitter Viewを表示する
    [self presentModalViewController:viewController animated:YES];
}

/*!
 @brief リクエスト成功時処理
 
 広告リクエストに成功した時の処理。
 画面内に広告バナーを表示する。
 @param bannerView 広告バナー
 */
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    AKLog(1, @"start");
    
    // 画面内に広告を表示する
    bannerView.frame = CGRectMake(0.0,
                                  self.view.bounds.size.height - GAD_SIZE_320x50.height,
                                  bannerView.frame.size.width,
                                  bannerView.frame.size.height);
    
    AKLog(1, @"end");
}

/*!
 @brief リクエスト失敗時処理
 
 広告リクエストに失敗した時の処理。
 画面外に広告バナーを移動する。
 @param bannerView 広告バナー
 @param error エラー内容
 */
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    AKLog(1, @"start");
    
    // ビューの位置を画面外に設定する
    bannerView.frame = CGRectMake(0.0,
                                  -bannerView.frame.size.height,
                                  bannerView.frame.size.width,
                                  bannerView.frame.size.height);
    
    AKLog(1, @"end");
}

/*!
 @brief 広告フルスクリーン表示時処理
 
 広告がフルスクリーン表示される前に行う処理。
 ゲームプレイ中の場合は一時停止状態にする。
 @param bannerView 広告バナー
 */
- (void)adViewWillPresentScreen:(GADBannerView *)bannerView
{
    AKLog(1, @"start");
    
    // 実行中のシーンを取得する
    CCScene *scene = [[CCDirector sharedDirector] runningScene];
    
    // ゲームプレイシーンでゲームプレイ中の場合は一時停止状態にする
    if ([scene isKindOfClass:[AKGameScene class]]) {
        
        // ゲームプレイシーンにキャストする
        AKGameScene *gameScene = (AKGameScene *)scene;
        
        // ゲームプレイ中の場合は一時停止状態にする
        if (gameScene.state == kAKGameStatePlaying) {
            
            // 一時停止する
            [gameScene pause:NO];
            
            // BGMは停止させる
            [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        }
    }
    
    AKLog(1, @"end");
}

/*!
 @brief 広告フルスクリーン終了時処理
 
 フルスクリーン広告が閉じられる時に行う処理。
 @param bannerView 広告バナー
 */
- (void)adViewDidDismissScreen:(GADBannerView *)bannerView
{
    AKLog(1, @"start");
}

/*!
 @brief 広告表示によるバックグラウンド移行時処理
 
 広告表示によってアプリケーションがバックグラウンドに移行するときの処理。
 @param bannerView 広告バナー
 */
- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView
{
    AKLog(1, @"start");
}
@end
