/*!
 @file AKGameCenterHelper.m
 @brief Game Center管理
 
 Game Centerの入出力を管理するクラスを定義する。
 */

#import <GameKit/GameKit.h>
#import "AKGameCenterHelper.h"
#import "AKNavigationController.h"

/// 傾撃ハイスコアのカテゴリ
static NSString *kAKGameCenterScoreCategory = @"keigeki_score";

/*!
 @brief GameCenter管理
 
 Game Centerの入出力を管理する。
 */
@implementation AKGameCenterHelper

// シングルトンオブジェクト
static AKGameCenterHelper *g_instance = nil;

/*!
 @brief シングルトンオブジェクト取得
 
 シングルトンオブジェクトを取得する。
 まだ生成されていない場合は生成を行う。
 @return シングルトンオブジェクト
 */
+ (AKGameCenterHelper *)sharedHelper
{
    // 他のスレッドで同時に実行されないようにする
    @synchronized(self) {
     
        // シングルトンオブジェクトが生成されていない場合は生成する
        if (!g_instance) {
            g_instance = [[AKGameCenterHelper alloc] init];
        }
        
        return g_instance;
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

		NSAssert(g_instance == nil, @"Attempted to allocate a second instance of a singleton.");
        return [super alloc];
    }
    
    return nil;
}

/*!
 @brief Game Centerをサポートしているか調べる
 
 動いているデバイスがGame Centerをサポートしているかを調べる。
 GKLocalPlayerクラスが存在し、iOSのバージョンが4.1以上の場合はTRUEを返す。
 @return Game Centerをサポートしているかどうか
 */
- (BOOL)isGameCenterAPIAvaliable
{
    // GKLocalPlayerクラスが存在するかどうかをチェックする
    BOOL localPlayerClassAvailable = (NSClassFromString(@"GKLocalPlayer")) != nil;
    
    // デバイスがiOS 4.1以降で動作しているかどうか調べる
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:@"4.1"
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (localPlayerClassAvailable && osVersionSupported);
}

/*!
 @brief ユーザー認証
 
 ユーザー認証を行う。
 */
- (void)authenticateLocalPlayer
{
    // Game Center非対応の場合は処理を終了する
    if (![self isGameCenterAPIAvaliable]) {
        return;
    }
    
    // ローカルプレイヤーを取得する
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    // すでに認証済みならば処理を終了する
    if (localPlayer.isAuthenticated) {
        return;
    }
    
    // 認証を行う
    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
        
        // 認証ができた場合はゲームセンターのデータを取得する
        if (localPlayer.isAuthenticated) {
            
        }
    }];
}

/*!
 @brief ハイスコア送信
 
 ハイスコアをGame Centerに送信する。
 @param score スコア
 */
- (void)reportHiScore:(NSInteger)score
{
    // スコア送信クラスの生成
    GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:kAKGameCenterScoreCategory] autorelease];
    
    // スコアを設定する
    scoreReporter.value = score;
    
    // スコアを送信する
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        
        // エラー発生時は送信内容をアーカイブして、後で送信できるようにする
        if (error != nil) {
            
        }
    }];
}

/*!
 @brief Leaderboard表示
 
 Leaderboardを表示する。
 */
- (void) showLeaderboard
{
    // LeaderboardのView Controllerを生成する
    GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
    
    // LeaderboardのView Controllerの生成に失敗した場合は処理を終了する
    if (leaderboardController == nil) {
        return;
    }
    
    // View Controllerを取得する
    AKNavigationController *viewController = (AKNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    // delegateを設定する
    leaderboardController.leaderboardDelegate = viewController;
    
    // Leaderboardを表示する
    [viewController presentModalViewController:leaderboardController animated:YES];
}
@end
