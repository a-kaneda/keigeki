/*!
 @file AKGameScene.h
 @brief ゲームプレイシーンクラス定義
 
 ゲームプレイのメインのシーンを管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKGameIFLayer.h"
#import "AKBackground.h"
#import "AKPlayer.h"
#import "AKCharacterPool.h"
#import "AKRadar.h"
#import "AKLifeMark.h"
#import "common.h"

/// 同時に生成可能な自機弾の最大数
#define MAX_PLAYER_SHOT_COUNT 16
/// 同時に生成可能な画面効果の最大数
#define MAX_EFFECT_COUNT 16

/// 初期残機数
#define START_LIFE_COUNT 2
/// 自機復活までの間隔
#define REBIRTH_INTERVAL 1

/// 自機の配置z座標
#define PLAYER_POS_Z 2
/// 自機弾の配置z座標
#define PLAYER_SHOT_POS_Z 4
/// 敵の配置z座標
#define ENEMY_POS_Z 3
/// 画面効果の配置z座標
#define EFFECT_POS_Z 5

/// ゲームプレイの状態
enum GAME_STATE {
    GAME_STATE_START = 0,   ///< ゲーム開始時
    GAME_STATE_PLAYING,     ///< プレイ中
    GAME_STATE_CLEAR,       ///< ステージクリア後
    GAME_STATE_GAMEOVER,    ///< ゲームオーバーの表示中
    GAME_STATE_PUASE,       ///< 一時停止中
    GAME_STATE_COUNT        ///< ゲームプレイ状態の数
};

/// 敵の種類
enum ENEMY_TYPE {
    NORMAL = 0,         ///< 雑魚
    ENEMY_TYPE_COUNT    ///< 敵の種類の数
};

// ゲームプレイシーン
@interface AKGameScene : CCScene {
    /// 現在の状態
    enum GAME_STATE m_state;
    /// 現在のステージ番号
    NSInteger m_stageNo;
    /// 現在のウェイブ番号
    NSInteger m_waveNo;
    /// 残機の数
    NSInteger m_life;
    /// 自機復活までの間隔
    float m_rebirthInterval;
    /// キャラクターを配置するレイヤー
    CCLayer *m_baseLayer;
    /// キャラクター以外を配置するレイヤー
    CCLayer *m_infoLayer;
    /// インターフェースレイヤー
    AKGameIFLayer *m_interface;
    /// 背景
    AKBackground *m_background;
    /// 自機
    AKPlayer *m_player;
    /// 自機弾
    AKCharacterPool *m_playerShotPool;
    /// 敵
    AKCharacterPool *m_enemyPool;
    /// 画面効果
    AKCharacterPool *m_effectPool;
    /// レーダー
    AKRadar *m_radar;
    /// 残機表示
    AKLifeMark *m_lifeMark;
    /// ゲームオーバーの画像
    CCSprite *m_gameOverImage;
}

/// 現在の状態
@property (nonatomic, readonly)enum GAME_STATE state;
/// キャラクターを配置するレイヤー
@property (nonatomic, retain)CCLayer *baseLayer;
/// キャラクター以外を配置するレイヤー
@property (nonatomic, retain)CCLayer *infoLayer;
/// インターフェースレイヤー
@property (nonatomic, retain)AKGameIFLayer *interface;
/// 背景
@property (nonatomic, retain)AKBackground *background;
/// 自機
@property (nonatomic, retain)AKPlayer *player;
/// 自機弾
@property (nonatomic, retain)AKCharacterPool *playerShotPool;
/// 敵
@property (nonatomic, retain)AKCharacterPool *enemyPool;
/// 画面効果
@property (nonatomic, retain)AKCharacterPool *effectPool;
/// レーダー
@property (nonatomic, retain)AKRadar *rader;
/// 残機表示
@property (nonatomic, retain)AKLifeMark *lifeMark;
/// ゲームオーバーの画像
@property (nonatomic, retain)CCSprite *gameOverImage;

// シングルトンオブジェクト取得
+ (AKGameScene *)sharedInstance;
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
// 画面効果の生成
- (void)entryEffect:(CCParticleSystem *)particle Time:(float)time PosX:(float)posx PosY:(float)posy;
// 自機破壊時の処理
- (void)miss;
// ゲーム状態リセット
- (void)resetAll;
@end
