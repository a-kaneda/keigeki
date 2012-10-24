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
    /// 動作処理のセレクタ
    SEL action_;
    /// 破壊処理のセレクタ
    SEL destroy_;
}

// 生成処理
- (void)createWithX:(NSInteger)x Y:(NSInteger)y Z:(NSInteger)z Angle:(float)angle
             Parent:(CCNode*)parent CreateSel:(SEL)create;
@end
