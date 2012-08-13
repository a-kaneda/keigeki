//
//  AKPlayerShot.h
//  keigeki:傾撃
//
//  Created by 金田 明浩 on 2012/07/23.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKCharacter.h"

// 自機弾の射程距離
#define PLAYER_SHOT_RANGE   600
// 自機弾のスピード
#define PLAYER_SHOT_SPEED   1200
// 自機弾の幅
#define PLAYER_SHOT_WIDTH   2
// 自機弾の高さ
#define PLAYER_SHOT_HEIGHT  8

/*!
 @class 自機弾クラス
 @abstruct 自機弾を管理するクラス。
 */
@interface AKPlayerShot : AKCharacter {
    // 移動距離
    float m_distance;
}

// 生成処理
- (void)createWithX:(NSInteger)x Y:(NSInteger)y Z:(NSInteger)z Angle:(float)angle
             Parent:(CCNode*)parent;
@end
