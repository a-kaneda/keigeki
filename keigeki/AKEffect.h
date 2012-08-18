/*!
 @file AKEffect.h
 @brief 画面効果クラス定義
 
 爆発等の画面効果を生成するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKCharacter.h"

// 画面効果クラス
@interface AKEffect : AKCharacter {
    /// 生存時間
    float m_lifetime;
}

// 画面効果開始
- (void)startEffect:(float)time PosX:(float)posx PosY:(float)posy PosZ:(NSInteger)posz
    Parent:(CCNode *)parent;
@end
