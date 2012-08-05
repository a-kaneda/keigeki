//
//  GameScene.h
//  keigeki
//
//  Created by 金田 明浩 on 12/05/03.
//  Copyright 2012年 KANEDA Akihiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameIFLayer.h"
#import "Background.h"
#import "Player.h"

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
}

// シングルトンオブジェクト取得
+ (GameScene *)sharedInstance;
// 自機の移動
- (void)movePlayerByVX:(float)vx VY:(float)vy;
// 自機弾の発射
- (void)filePlayerShot;

@end
