/*!
 @file AKEnemy+Normal.h
 @brief 雑魚クラス定義
 
 雑魚敵を定義する。
 */


#import "AKEnemy.h"

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
