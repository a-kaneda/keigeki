//
//  GameScene.h
//  keigeki
//
//  Created by 金田 明浩 on 12/05/03.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameIFLayer.h"
#import "Background.h"
#import "Player.h"
#import "CharacterPool.h"

// 同時に生成可能な自機弾の最大数
#define MAX_PLAYER_SHOT_COUNT   16

// 自機の配置z座標
#define PLAYER_POS_Z 2
// 自機弾の配置z座標
#define PLAYER_SHOT_POS_Z 3

/*!
 @class ゲームプレイシーン
 @abstruct ゲームプレイのメインのシーンを管理する。
 */
@interface GameScene : CCScene {
    // キャラクターを配置するレイヤー
    CCLayer *m_baseLayer;
    // インターフェースレイヤー
    GameIFLayer *m_interface;
    // 背景
    Background *m_background;
    // 自機
    Player *m_player;
    // 自機弾
    CharacterPool *m_playerShotPool;
}

@property (nonatomic, retain)CCLayer *baseLayer;
@property (nonatomic, retain)GameIFLayer *interface;
@property (nonatomic, retain)Background *background;
@property (nonatomic, retain)Player *player;
@property (nonatomic, retain)CharacterPool *playerShotPool;

// シングルトンオブジェクト取得
+ (GameScene *)sharedInstance;
// 自機の移動
- (void)movePlayerByVX:(float)vx VY:(float)vy;
// 自機弾の発射
- (void)filePlayerShot;

@end
