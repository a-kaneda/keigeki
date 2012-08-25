/*!
 @file AKGameScene.h
 @brief ゲームプレイシーンクラス定義
 
 ゲームプレイのメインのシーンを管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKBackground.h"
#import "AKPlayer.h"
#import "AKCharacterPool.h"
#import "AKRadar.h"
#import "AKLifeMark.h"
#import "AKEnemyShot.h"
#import "common.h"

/// 同時に生成可能な自機弾の最大数
#define MAX_PLAYER_SHOT_COUNT 16
/// 同時に生成可能な敵弾の最大数
#define MAX_ENEMY_SHOT_COUNT 64
/// 同時に生成可能な画面効果の最大数
#define MAX_EFFECT_COUNT 16

/// 初期残機数
#define START_LIFE_COUNT 2
/// 自機復活までの間隔
#define REBIRTH_INTERVAL 1

/// 1ステージのウェイブの数
#define WAVE_COUNT 1
/// ステージの数
#define STAGE_COUNT 5
/// ウェイブが始まるまでの間隔
#define WAVE_INTERVAL 2

/// スコアの表示位置x座標
#define SCORE_POS_X 10
/// スコアの表示位置y座標
#define SCORE_POS_Y 300
/// ハイスコアの表示位置x座標
#define HISCORE_POS_X 280
/// ハイスコアの表示位置y座標
#define HISCORE_POS_Y 300

/// スコア表示のフォーマット
#define SCORE_FORMAT @"SCORE:%08d"
/// ハイスコア表示のフォーマット
#define HISCORE_FORMAT @"HI:%08d"

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
    ENEMY_TYPE_NORMAL = 0,  ///< 雑魚
    ENEMY_TYPE_COUNT        ///< 敵の種類の数
};

/// 情報レイヤーに配置するノードのタグ
enum INFOLAYER_TAG {
    INFOLAYER_TAG_PAUSE = 0,    ///< 一時停止
    INFOLAYER_TAG_GAMEOVER,     ///< ゲームオーバー
    INFOLAYER_TAG_SCORE,        ///< スコア
    INFOLAYER_TAG_HISCORE,      ///< ハイスコア
    INFOLAYER_TAG_COUNT         ///< タグの種類の数
};

/// レイヤーのz座標、タグの値にも使用する
enum LAYER_POS_Z {
    LAYER_POS_Z_BASELAYER = 0,  ///< ベースレイヤー
    LAYER_POS_Z_INFOLAYER,      ///< 情報レイヤー
    LAYER_POS_Z_RESULTLAYER,    ///< ステージクリアレイヤー
    LAYER_POS_Z_INTERFACELAYER  ///< インターフェースレイヤー
};

/// キャラクターのz座標
enum CHARA_POS_Z {
    CHARA_POS_Z_BACKGROUND = 0, ///< 背景
    CHARA_POS_Z_PLAYER,         ///< 自機
    CHARA_POS_Z_ENEMY,          ///< 敵
    CHARA_POS_Z_PLAYERSHOT,     ///< 自機弾
    CHARA_POS_Z_ENEMYSHOT,      ///< 敵弾
    CHARA_POS_Z_EFFECT          ///< 画面効果
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
    /// スコア
    NSInteger m_score;
    /// ハイスコア
    NSInteger m_hiScore;
    /// 自機復活までの間隔
    float m_rebirthInterval;
    /// 次のウェーブ開始までの間隔
    float m_waveInterval;
    /// 背景
    AKBackground *m_background;
    /// 自機
    AKPlayer *m_player;
    /// 自機弾プール
    AKCharacterPool *m_playerShotPool;
    /// 敵プール
    AKCharacterPool *m_enemyPool;
    /// 敵弾プール
    AKCharacterPool *m_enemyShotPool;
    /// 画面効果プール
    AKCharacterPool *m_effectPool;
    /// レーダー
    AKRadar *m_radar;
    /// 残機表示
    AKLifeMark *m_lifeMark;
}

/// 現在の状態
@property (nonatomic, readonly)enum GAME_STATE state;
/// 背景
@property (nonatomic, retain)AKBackground *background;
/// 自機
@property (nonatomic, retain)AKPlayer *player;
/// 自機弾プール
@property (nonatomic, retain)AKCharacterPool *playerShotPool;
/// 敵プール
@property (nonatomic, retain)AKCharacterPool *enemyPool;
/// 敵弾プール
@property (nonatomic, retain)AKCharacterPool *enemyShotPool;
/// 画面効果プール
@property (nonatomic, retain)AKCharacterPool *effectPool;
/// レーダー
@property (nonatomic, retain)AKRadar *rader;
/// 残機表示
@property (nonatomic, retain)AKLifeMark *lifeMark;

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
// 敵弾の生成
- (void)fireEnemyShot:(enum ENEMY_SHOT_TYPE)type PosX:(NSInteger)posx PosY:(NSInteger)posy Angle:(float)angle;
// 画面効果の生成
- (void)entryEffect:(CCParticleSystem *)particle Time:(float)time PosX:(float)posx PosY:(float)posy;
// 自機破壊時の処理
- (void)miss;
// ゲーム状態リセット
- (void)resetAll;
// スコア加算
- (void)addScore:(NSInteger)score;
// ポーズ
- (void)pause;
// ゲーム再開
- (void)resume;
// スクリプト読込
- (void)readScriptOfStage:(NSInteger)stage Wave:(NSInteger)wave;
// ウェーブクリア
- (void)clearWave;
// ステージクリア結果スキップ
- (void)skipResult;
// ステージクリア
- (void)clearStage;
@end
