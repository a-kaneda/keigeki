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
#import "AKResultLayer.h"
#import "AKInterface.h"
#import "AKLabel.h"
#import "common.h"

/// ゲームプレイの状態
enum AKGameState {
    kAKGameStatePreLoad = 0,    ///< ゲームシーン読み込み前
    kAKGameStateStart,          ///< ゲーム開始時
    kAKGameStatePlaying,        ///< プレイ中
    kAKGameStateClear,          ///< ステージクリア後
    kAKGameStateResult,         ///< リザルト画面表示中
    kAKGameStateGameOver,       ///< ゲームオーバーの表示中
    kAKGameStatePause,          ///< 一時停止中
    kAKGameStateQuitMenu,       ///< 終了メニュー表示中
    kAKGameStateWait,           ///< アクション終了待機中
    kAKGameStateSleep           ///< スリープ処理中
};

/// 敵の種類
enum AKEnemyType {
    kAKEnemyTypeNormal = 0  ///< 雑魚
};


// ゲームプレイシーン
@interface AKGameScene : CCScene {
    /// 現在の状態
    enum AKGameState m_state;
    /// スリープ終了後の状態
    enum AKGameState m_nextState;
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
    /// ショット発射数
    NSInteger m_shotCount;
    /// ショット命中数
    NSInteger m_hitCount;
    /// 撃墜された数
    NSInteger m_missCount;
    /// 自機復活までの間隔
    float m_rebirthInterval;
    /// 次のウェーブ開始までの間隔
    float m_waveInterval;
    /// 状態変更時の間隔
    float m_stateInterval;
    /// ステージのプレイ時間
    float m_playTime;
    /// スリープ時間
    float m_sleepTime;
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
@property (nonatomic)enum AKGameState state;
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
/// ショット発射数
@property (nonatomic)NSInteger shotCount;
/// ショット命中数
@property (nonatomic)NSInteger hitCount;

// シングルトンオブジェクト取得
+ (AKGameScene *)sharedInstance;
// リザルト画面取得
- (AKResultLayer *)resultLayer;
// 入力レイヤー取得
- (AKInterface *)interfaceLayer;
// ゲーム開始時の更新処理
- (void)updateStart:(ccTime)dt;
// プレイ中の更新処理
- (void)updatePlaying:(ccTime)dt;
// クリア表示中の更新処理
- (void)updateClear:(ccTime)dt;
// スリープ中の更新処理
- (void)updateSleep:(ccTime)dt;
// 自機の移動
- (void)movePlayerByVX:(float)vx VY:(float)vy;
// 自機弾の発射
- (void)firePlayerShot;
// 敵の生成
- (void)entryEnemy:(enum AKEnemyType)type
              PosX:(NSInteger)posx PosY:(NSInteger)posy Angle:(float)angle;
// 敵弾の生成
- (void)fireEnemyShot:(enum ENEMY_SHOT_TYPE)type
                 PosX:(NSInteger)posx PosY:(NSInteger)posy Angle:(float)angle;
// 画面効果の生成
- (void)entryEffect:(NSString *)fileName startRect:(CGRect)rect
         frameCount:(NSInteger)count delay:(float)delay
               posX:(float)posx posY:(float)posy;
// 自機破壊時の処理
- (void)miss;
// ゲーム状態リセット
- (void)resetAll;
// スコア加算
- (void)addScore:(NSInteger)score;
// ポーズ(効果音有無指定)
- (void)pause:(BOOL)isUseSE;
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
// ハイスコアファイルの読込
- (void)readHiScore;
// ハイスコアファイルの書込
- (void)writeHiScore;
// 命中率更新
- (void)updateHit;
// プレイ時間更新
- (void)updateTime;
// 情報レイヤーへのラベル配置
- (void)setLabelToInfoLayer:(NSString *)str atPos:(CGPoint)pos tag:(NSInteger)tag frame:(enum AKLabelFrame)frame;
// ボタンの追加
- (void)addButtonWithFile:(NSString *)filename atPos:(CGPoint)pos action:(SEL)action ofState:(enum AKGameState)state;
// タイトル画面に戻る
- (void)backToTitle;
// リザルト画面表示
- (void)viewResult;
// 終了メニュー表示
- (void)viewQuitMenu;
// 終了メニュー実行
- (void)execQuitMenu;
// 終了メニューキャンセル
- (void)cancelQuitMenu;
// 再開ボタン選択
- (void)selectResumeButton;
// 終了ボタン選択
- (void)selectQuitButton;
// 終了メニューNOボタン選択
- (void)selectQuitNoButton;
@end
