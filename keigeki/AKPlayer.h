/*!
 @file AKPlayer.h
 @brief 自機クラス定義
 
 自機を管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKCharacter.h"
#import "common.h"

// 自機クラス
@interface AKPlayer : AKCharacter {
    /// 無敵状態かどうか
    BOOL m_isInvincible;
    /// 無敵状態の残り時間
    float m_invincivleTime;
}

/// 無敵状態かどうか
@property (nonatomic)BOOL isInvincible;

// スクリーン座標(x座標)の取得
- (float)getScreenPosX;
// スクリーン座標(y座標)の取得
- (float)getScreenPosY;
// 速度の設定
- (void)setVelocityX:(float)vx Y:(float)vy;
// 復活
- (void)rebirth;
// 初期化
- (void)reset;

@end
