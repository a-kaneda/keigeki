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
- (void)startEffectWithFile:(NSString *)fileName startRect:(CGRect)rect
                 frameCount:(NSInteger)count delay:(float)delay
                       posX:(float)posx posY:(float)posy;
@end
