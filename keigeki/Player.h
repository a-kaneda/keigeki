//
//  Player.h
//  keigeki
//
//  Created by 金田 明浩 on 12/05/16.
//  Copyright 2012年 KANEDA Akihiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Character.h"
#import "common.h"

// 速度の最大値
#define PLAYER_SPEED        60
// 自機の回転速度
#define PLAYER_ROT_SPEED    1

/*!
 @class 自機クラス
 @abstruct 自機を管理する
 */
@interface Player : Character {
}

// スクリーン座標(x座標)の取得
- (float)getScreenPosX;
// スクリーン座標(y座標)の取得
- (float)getScreenPosY;
// 速度の設定
- (void)setVelocityX:(float)vx Y:(float)vy;

@end
