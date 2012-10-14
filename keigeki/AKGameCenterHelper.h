/*!
 @file AKGameCenterHelper.h
 @brief Game Center管理
 
 Game Centerの入出力を管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>

// Game Center管理
@interface AKGameCenterHelper : NSObject

// シングルトンオブジェクトを取得する
+ (AKGameCenterHelper *)sharedHelper;
// Game Centerをサポートしているか調べる
- (BOOL)isGameCenterAPIAvaliable;
// ユーザー認証
- (void)authenticateLocalPlayer;
// ハイスコア送信
- (void)reportHiScore:(NSInteger)score;
// Leaderboard表示
- (void)showLeaderboard;
@end
