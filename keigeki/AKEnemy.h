/*!
 @file AKEnemy.h
 @brief 敵クラス定義
 
 敵キャラクターのクラスの定義をする。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKCharacter.h"
#import "AKCommon.h"

// 敵クラス
@interface AKEnemy : AKCharacter {
    /// 動作開始からの経過時間(各敵種別で使用)
    ccTime time_;
    /// 動作状態(各敵種別で使用)
    NSInteger state_;
    /// 動作処理のセレクタ
    SEL action_;
    /// 破壊処理のセレクタ
    SEL destroy_;
}

// 生成処理
- (void)createWithX:(NSInteger)x Y:(NSInteger)y Z:(NSInteger)z Angle:(float)angle
             Parent:(CCNode*)parent CreateSel:(SEL)create;
// 雑魚生成処理
- (void)createNoraml;
// 高速移動生成
- (void)createHighSpeed;
// 高速旋回生成
- (void)createHighTurn;
// 高速ショット生成
- (void)createHighShot;
// 3-Way弾発射生成
- (void)create3WayShot;
// 大砲生成
- (void)createCanon;
// 雑魚動作処理
- (void)actionNoraml:(ccTime)dt;
// 高速旋回動作処理
- (void)actionHighTurn:(ccTime)dt;
// 高速ショット処理
- (void)actionHighShot:(ccTime)dt;
// 3-Way弾発射処理
- (void)action3WayShot:(ccTime)dt;
// 大砲動作処理
- (void)actionCanon:(ccTime)dt;
// 雑魚破壊処理
- (void)destroyNormal;
// 雑魚通常弾発射
- (void)fireNormal;
// n-Way弾発射
- (void)fireNWay:(NSInteger)way;
@end
