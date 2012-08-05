//
//  PlayerShot.h
//  keigeki
//
//  Created by 金田 明浩 on 12/07/23.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Character.h"

// 自機弾の射程距離
#define PLAYER_SHOT_RANGE   480
// 自機弾のスピード
#define PLAYER_SHOT_SPEED   600
// 自機弾の幅
#define PLAYER_SHOT_WIDTH   2
// 自機弾の高さ
#define PLAYER_SHOT_HEIGHT  8

/*!
 @class 自機弾クラス
 @abstruct 自機弾を管理するクラス。
 */
@interface PlayerShot : Character {
    // 移動距離
    float m_distance;
}

// 生成処理
- (void)createWithX:(NSInteger)x Y:(NSInteger)y Z:(NSInteger)z Angle:(float)angle
             Parent:(CCNode*)parent;
@end
