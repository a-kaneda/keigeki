/*!
 @file AKShot.h
 @brief 弾クラス定義
 
 弾を管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKCharacter.h"

// 弾クラス
@interface AKShot : AKCharacter {
    /// 移動距離
    float m_distance;
}

// 生成処理
- (void)createWithX:(NSInteger)x Y:(NSInteger)y Z:(NSInteger)z Angle:(float)angle
             Parent:(CCNode*)parent;
@end
