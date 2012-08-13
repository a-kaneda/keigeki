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

// 同時に生成可能な敵の最大数
#define MAX_ENEMY_COUNT 16
// 同時に生成可能な自機弾の最大数
#define MAX_PLAYER_SHOT_COUNT 16

// 自機の配置z座標
#define PLAYER_POS_Z 2
// 自機弾の配置z座標
#define PLAYER_SHOT_POS_Z 4
// 敵の配置z座標
#define ENEMY_POS_Z 3

// レーダーのサイズ
#define RADAR_SIZE 128
// レーダーの配置位置x座標
#define RADAR_POS_X (SCREEN_WIDTH - 80)
// レーダーの配置位置y座標
#define RADAR_POS_Y (SCREEN_HEIGHT - 130)

// ゲームプレイの状態
enum GAME_STATE {
    GAME_STATE_START = 0,   // ゲーム開始時
    GAME_STATE_PLAYING,     // プレイ中
    GAME_STATE_CLEAR,       // ステージクリア後
    GAME_STATE_GAMEOVER,    // ゲームオーバーの表示中
    GAME_STATE_PUASE,       // 一時停止中
    GAME_STATE_COUNT        // ゲームプレイ状態の数
};

// 敵の種類
enum ENEMY_TYPE {
    NORMAL = 0,         // 雑魚
    ENEMY_TYPE_COUNT    // 敵の種類の数
};

/*!
 @class ゲームプレイシーン
 @abstruct ゲームプレイのメインのシーンを管理する。
 */
@interface GameScene : CCScene {
    // 現在の状態
    enum GAME_STATE m_state;
    // 現在のステージ番号
    NSInteger m_stageNo;
    // 現在のウェイブ番号
    NSInteger m_waveNo;
    // キャラクターを配置するレイヤー
    CCLayer *m_baseLayer;
    // キャラクター以外を配置するレイヤー
    CCLayer *m_infoLayer;
    // インターフェースレイヤー
    GameIFLayer *m_interface;
    // 背景
    Background *m_background;
    // 自機
    Player *m_player;
    // 自機弾
    CharacterPool *m_playerShotPool;
    // 敵
    CharacterPool *m_enemyPool;
    // レーダーの画像
    CCSprite *m_radar;
}

@property (nonatomic, retain)CCLayer *baseLayer;
@property (nonatomic, retain)CCLayer *infoLayer;
@property (nonatomic, retain)GameIFLayer *interface;
@property (nonatomic, retain)Background *background;
@property (nonatomic, retain)Player *player;
@property (nonatomic, retain)CharacterPool *playerShotPool;
@property (nonatomic, retain)CharacterPool *enemyPool;
@property (nonatomic, retain)CCSprite *rader;

// シングルトンオブジェクト取得
+ (GameScene *)sharedInstance;
// ゲーム開始時の更新処理
- (void)updateStart:(ccTime)dt;
// プレイ中の更新処理
- (void)updatePlaying:(ccTime)dt;
// 自機の移動
- (void)movePlayerByVX:(float)vx VY:(float)vy;
// 自機弾の発射
- (void)filePlayerShot;
// 敵の生成
- (void)entryEnemy:(enum ENEMY_TYPE)type PosX:(NSInteger)posx PosY:(NSInteger)posy Angle:(float)angle;
@end
