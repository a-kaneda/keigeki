/*!
 @file AKEnemy.h
 @brief 敵クラス定義
 
 敵キャラクターのクラスの定義をする。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKCharacter.h"
#import "common.h"

/// 敵を倒したときのスコア
#define ENEMY_SCORE 100

// 敵クラス
@interface AKEnemy : AKCharacter {
    /// 動作開始からの経過時間(各敵種別で使用)
    ccTime m_time;
    /// 動作処理のセレクタ
    SEL m_action;
    /// 破壊処理のセレクタ
    SEL m_destroy;
}

// 生成処理
- (void)createWithX:(NSInteger)x Y:(NSInteger)y Z:(NSInteger)z Angle:(float)angle
             Parent:(CCNode*)parent CreateSel:(SEL)create;
@end
