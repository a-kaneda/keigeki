/*!
 @file AKGameCenterHelper.h
 @brief Game Center管理
 
 Game Centerの入出力を管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

/// 実績ノーミスクリアのID
extern NSString *kAKGCNoMissID;
/// 実績短時間クリアのID
extern NSString *kAKGCShortTimeID;
/// 実績背後からの撃墜のID
extern NSString *kAKGCBackShootID;
/// 実績命中率100%のID
extern NSString *kAKGCInfallibleShoot;
/// 実績1UPのID
extern NSString *kAKGC1UpID;
/// 実績プレイ回数のID
extern NSString *kAKGCPlayCountID;

// Game Center管理
@interface AKGameCenterHelper : NSObject {
    /// 解除済みの実績
    NSMutableDictionary *localAchievments_;
}

/// 解除済みの実績
@property (retain, nonatomic)NSMutableDictionary *localAchievements;

// シングルトンオブジェクトを取得する
+ (AKGameCenterHelper *)sharedHelper;
// 解除済みの実績読み込み
- (void)readLocalAchievements;
// 解除済みの実績書き込み
- (void)writeLocalAchievements;
// ユーザー認証
- (void)authenticateLocalPlayer;
// 送信に失敗したデータを再送信する
- (void)reSendData:(NSDictionary *)networkAchievements;
// 実績取得
- (void)loadAchievements;
// ハイスコア送信
- (void)reportHiScore:(NSInteger)score;
// 実績送信
- (void)reportAchievements:(NSString *)identifier;
// 達成率増加分を指定して実績送信
- (void)reportAchievements:(NSString *)identifier percentIncrement:(float)percent;
// ステージクリア送信
- (void)reportStageClear:(NSInteger)stage;
// Leaderboard表示
- (void)showLeaderboard;
// Achievements表示
- (void)showAchievements;
@end
