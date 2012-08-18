/*!
 @file AKPlayer.h
 @brief 自機クラス定義
 
 自機を管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKCharacter.h"
#import "common.h"

/// 速度の最大値
#define PLAYER_SPEED        240
/// 自機の回転速度
#define PLAYER_ROT_SPEED    1

// 自機クラス
@interface AKPlayer : AKCharacter {
}

// スクリーン座標(x座標)の取得
- (float)getScreenPosX;
// スクリーン座標(y座標)の取得
- (float)getScreenPosY;
// 速度の設定
- (void)setVelocityX:(float)vx Y:(float)vy;

@end
