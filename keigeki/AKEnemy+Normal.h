/*!
 @file AKEnemy+Normal.h
 @brief 雑魚クラス定義
 
 雑魚敵を定義する。
 */


#import "AKEnemy.h"

/// 雑魚の移動速度
#define ENEMY_NORMAL_SPEED 240
/// 雑魚の回転速度
#define ENEMY_NORAML_ROTSPEED 0.5
/// 雑魚の弾発射の時間
#define ENEMY_NORMAL_ACTIONTIME 5
/// 雑魚の敵のサイズ
#define ENEMY_NORMAL_SIZE 16

// 雑魚カテゴリ
@interface AKEnemy (Normal)
// 生成処理
- (void)createNoraml;
// 動作処理
- (void)actionNoraml:(ccTime)dt;
// 破壊処理
- (void)destroyNormal;
// 通常弾発射
- (void)fireNormal;
@end
