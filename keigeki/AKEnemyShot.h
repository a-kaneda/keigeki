/*!
 @file AKEnemyShot.h
 @brief 敵弾クラス定義
 
 敵弾を管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKShot.h"

/// 敵弾の種類
enum ENEMY_SHOT_TYPE {
    ENEMY_SHOT_TYPE_NORMAL = 0, // 通常弾
    ENEMY_SHOT_TYPE_COUNT       // 敵弾の種類
    };
// 敵弾クラス
@interface AKEnemyShot : AKShot {
    
}

// 生成処理
- (void)createWithType:(enum ENEMY_SHOT_TYPE)type X:(NSInteger)x Y:(NSInteger)y Z:(NSInteger)z
                 Angle:(float)angle Parent:(CCNode*)parent;
@end
