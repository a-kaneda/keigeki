/*
 * Copyright (c) 2012-2013 Akihiro Kaneda.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   1.Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *   2.Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *   3.Neither the name of the Monochrome Soft nor the names of its contributors
 *     may be used to endorse or promote products derived from this software
 *     without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
/*!
 @file AKGameScene.m
 @brief ゲームプレイシーンクラス定義
 
 ゲームプレイのメインのシーンを管理するクラスを定義する。
 */

#import "AKGameScene.h"
#import "AKGameIFLayer.h"
#import "AKPlayerShot.h"
#import "AKEnemy.h"
#import "AKEnemyShot.h"
#import "AKEffect.h"
#import "AKHiScoreFile.h"
#import "AKResultLayer.h"
#import "AKLabel.h"
#import "AKTitleScene.h"
#import "AKScreenSize.h"
#import "SimpleAudioEngine.h"
#import "AKGameCenterHelper.h"
#import "AKTwitterHelper.h"

/// 情報レイヤーに配置するノードのタグ
enum {
    kAKInfoTagStageClear = 0,   ///< ステージクリア
    kAKInfoTagGameClear,        ///< ゲームクリア
    kAKInfoTagScore,            ///< スコア
    kAKInfoTagHiScore,          ///< ハイスコア
    kAKInfoTagWaveNo,           ///< Wave番号
    kAKInfoTagHit,              ///< 命中率
    kAKInfoTagTime              ///< プレイ時間
};

/// レイヤーのz座標、タグの値にも使用する
enum {
    kAKLayerPosZBase = 0,   ///< ベースレイヤー
    kAKLayerPosZInfo,       ///< 情報レイヤー
    kAKLayerPosZResult,     ///< ステージクリアレイヤー
    kAKLayerPosZInterface   ///< インターフェースレイヤー
};

/// キャラクターのz座標
enum {
    kAKCharaPosZBackground = 0, ///< 背景
    kAKCharaPosZPlayer,         ///< 自機
    kAKCharaPosZEnemy,          ///< 敵
    kAKCharaPosZPlayerShot,     ///< 自機弾
    kAKCharaPosZEnemyShot,      ///< 敵弾
    kAKCharaPosZEffect          ///< 画面効果
};

/// 同時に生成可能な自機弾の最大数
static const NSInteger kAKMaxPlayerShotCount = 16;
/// 同時に生成可能な敵弾の最大数
static const NSInteger kAKEnemyShotCount = 64;
/// 同時に生成可能な画面効果の最大数
static const NSInteger kAKMaxEffectCount = 16;

/// 初期残機数
static const NSInteger kAKStartLifeCount = 2;
/// 自機復活までの間隔
static const float kAKRebirthInterval = 1.0f;
/// 短時間クリアの実績解除の時間
static const float kAKClearShortTime = 120.0f;
/// 1UPするスコア
static const NSInteger kAKExtendScore = 50000;

/// 開始ステージ
static const NSInteger kAKStartStage = 1;
/// 1ステージのウェイブの数
static const NSInteger kAKWaveCount = 6;
/// ステージの数
static const NSInteger kAKStageCount = 5;
/// ウェイブが始まるまでの間隔
static const float kAKWaveInterval = 2.0f;

/// ステージクリアのキャプション表示中の間隔
static const float kAKStageClearInterval = 3.0f;

/// ゲームオーバーのキャプション表示中の間隔
static const float kAKGameOverInterval = 2.0f;

/// スコアの表示位置、左からの位置
static const float kAKScorePosLeftPoint = 10.0f;
/// スコアの表示位置、上からの位置
static const float kAKScorePosTopPoint = 26.0f;
/// ハイスコアの表示位置、左からの位置
static const float kAKHiScorePosLeftPoint = 20.0f;
/// ハイスコアの表示位置、上からの位置
static const float kAKHiScorePosTopPoint = 26.0f;
/// Wave番号の表示位置、左からの位置
static const float kAKWaveNoPosLeftPoint = 20.0f;
/// Wave番号の表示位置、上からの位置
static const float kAKWaveNoPosTopPoint = 26.0f;
/// 命中率の表示位置、左からの位置
static const float kAKHitPosLeftPoint = 10.0f;
/// 命中率の表示位置、上からの位置
static const float kAKHitPosTopPoint = 46.0f;
/// プレイ時間の表示位置、左からの位置
static const float kAKTimePosLeftPoint = 20.0f;
/// プレイ時間の表示位置、上からの位置
static const float kAKTimePosTopPoint = 46.0f;

/// メニュー項目の数
static const NSInteger kAKItemCount = 8;

/// スコア表示のフォーマット
static NSString *kAKScoreFormat = @"SCORE:%06d";
/// ハイスコア表示のフォーマット
static NSString *kAKHiScoreFormat = @"HI:%06d";
/// Wave番号表示のフォーマット
static NSString *kAKWaveNoFormat = @"%d/%d";
/// 命中率表示のフォーマット
static NSString *kAKHitFormat = @"HIT:%3d%%";
/// プレイ時間のフォーマット
static NSString *kAKTimeFormat = @"TIME:%02d:%02d:%02d";
/// ハイスコアファイル名
static NSString *kAKDataFileName = @"hiscore.dat";
/// ハイスコアファイルのエンコードキー名
static NSString *kAKDataFileKey = @"hiScoreData";

/// ステージクリア時の表示文字列
static NSString *kAKStageClearString = @"STAGE CLEAR";
/// ゲームクリア時のツイートのフォーマットのキー
static NSString *kAKGameClearTweetKey = @"GameClearTweet";
/// ゲームオーバー時のツイートのフォーマットのキー
static NSString *kAKGameOverTweetKey = @"GameOverTweet";

/// ステージクリア画面のBGMファイル名
static NSString *kAKClearBGM = @"Clear.mp3";
/// 全ステージクリア時のBGMファイル名
static NSString *kAKEndingBGM = @"Ending.mp3";
/// ショット発射効果音ファイル名
static NSString *kAKShotSE = @"Shot.caf";
/// 一時停止効果音ファイル名
static NSString *kAKPauseSE = @"Pause.caf";
/// 破壊時の効果音
static NSString *kAKHitSE = @"Hit.caf";
/// エクステンド時の効果音
static NSString *kAK1UpSE = @"1Up.caf";

/// アプリのURL
static NSString *kAKAplUrl = @"https://itunes.apple.com/us/app/qing-ji/id569653828?l=ja&ls=1&mt=8";

/*!
 @brief ゲームプレイシーン
 
 ゲームプレイのメインのシーンを管理する。
 */
@implementation AKGameScene

@synthesize player = player_;
@synthesize playerShotPool = playerShotPool_;
@synthesize enemyPool = enemyPool_;
@synthesize enemyShotPool = enemyShotPool_;
@synthesize rader = radar_;
@synthesize effectPool = effectPool_;
@synthesize lifeMark = lifeMark_;
@synthesize shotCount = shotCount_;
@synthesize hitCount = hitCount_;

/*!
 @brief ゲームシーンクラス取得
 
 現在実行中のシーンをゲームプレイシーンクラスにキャストして返す。
 ゲームプレイシーンが実行中でない場合はnilを返す。
 @return ゲームプレイシーンのインスタンス
 */
+ (AKGameScene *)getInstance
{
    // 実行中のシーンを取得する
    CCScene *scene = [[CCDirector sharedDirector] runningScene];
    
    // ゲームプレイシーンでゲームプレイ中の場合は一時停止状態にする
    if ([scene isKindOfClass:[AKGameScene class]]) {
        
        // ゲームプレイシーンにキャストして返す
        return (AKGameScene *)scene;
    }
    
    // 現在実行中のシーンがゲームプレイシーンでない場合はエラー
    NSAssert(0, @"ゲームプレイ中以外にゲームシーンクラスの取得が行われた");
    return nil;
}

/*!
 @brief オブジェクト生成処理
 
 オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    AKLog(0, @"init 開始");
    
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 効果音の読み込みを行う
    [[SimpleAudioEngine sharedEngine] preloadEffect:kAKShotSE];
    [[SimpleAudioEngine sharedEngine] preloadEffect:kAKPauseSE];
    [[SimpleAudioEngine sharedEngine] preloadEffect:kAKHitSE];
    [[SimpleAudioEngine sharedEngine] preloadEffect:kAK1UpSE];

    // キャラクターを配置するレイヤーを生成する
    CCLayer *baseLayer = [CCLayer node];

    // ベースレイヤーを画面に配置する
    [self addChild:baseLayer z:kAKLayerPosZBase tag:kAKLayerPosZBase];
    
    // 画面回転時の中心点を求める
    // CCLayerのサイズは320x480だが、画面サイズはLandscape時は480x320のため、
    // 画面右上の点が(480 / 320, 320 / 480)となる。
    // 中心点座標のCCLayer上での比率に上の値をかけて、画面上での比率を求める。
    // なお、この現象は初期シーンに設定した時のみ発生する。(画面向きの方向の処理がまだ終わっていないためか？)
    float anchor_x = ((float)AKPlayerPosX() / [AKScreenSize screenSize].width) *
                        ((float)[AKScreenSize screenSize].width / baseLayer.contentSize.width);
    float anchor_y = ((float)AKPlayerPosY() / [AKScreenSize screenSize].height) *
                        ((float)[AKScreenSize screenSize].height / baseLayer.contentSize.height);
    
    // 画面回転時の中心点を設定する
    baseLayer.anchorPoint = ccp(anchor_x, anchor_y);
    
    // キャラクター以外の情報を配置するレイヤーを生成する
    CCLayer *infoLayer = [CCLayer node];
    infoLayer.tag = kAKLayerPosZInfo;
    [self addChild:infoLayer z:kAKLayerPosZInfo];
    
    // インターフェースを作成する
    [self addChild:[AKGameIFLayer interfaceWithCapacity:kAKItemCount]
                 z:kAKLayerPosZInterface
               tag:kAKLayerPosZInterface];
    
    // 背景の生成
    self.background = [[[AKBackground alloc] init] autorelease];
    [baseLayer addChild:self.background.batch z:kAKCharaPosZBackground];
    
    // 自機の生成
    self.player = [[[AKPlayer alloc] init] autorelease];
    [baseLayer addChild:self.player.image z:kAKCharaPosZPlayer];
    
    // 自機弾プールの生成
    self.playerShotPool = [[[AKCharacterPool alloc] initWithClass:[AKPlayerShot class]
                                                             Size:kAKMaxPlayerShotCount] autorelease];
    
    // 敵プールの生成
    self.enemyPool = [[[AKCharacterPool alloc] initWithClass:[AKEnemy class]
                                                        Size:kAKMaxEnemyCount] autorelease];
    
    // 敵弾プールの生成
    self.enemyShotPool = [[[AKCharacterPool alloc] initWithClass:[AKEnemyShot class]
                                                            Size:kAKEnemyShotCount] autorelease];

    // 画面効果プールの生成
    self.effectPool = [[[AKCharacterPool alloc] initWithClass:[AKEffect class]
                                                         Size:kAKMaxEffectCount] autorelease];
    
    // レーダーの生成
    self.rader = [AKRadar node];
    
    // レーダーをレイヤーに配置する
    [infoLayer addChild:self.rader];
    
    // 残機マークの生成
    self.lifeMark = [AKLifeMark node];
    
    // 残機マークをレイヤーに配置する
    [infoLayer addChild:self.lifeMark];
    
    // スコアラベルのx座標を計算する。スコアラベルは左詰めにするため、x座標は右に幅の半分移動する。
    float scoreLabelPosX = [AKScreenSize positionFromLeftPoint:kAKScorePosLeftPoint] +
        [AKLabel widthWithLength:[[NSString stringWithFormat:kAKScoreFormat, score_] length] hasFrame:NO] / 2;
    
    // スコアラベルを生成する
    [self setLabelToInfoLayer:[NSString stringWithFormat:kAKScoreFormat, score_]
                        atPos:ccp(scoreLabelPosX,
                                  [AKScreenSize positionFromTopPoint:kAKScorePosTopPoint])
                          tag:kAKInfoTagScore
                        frame:kAKLabelFrameNone];
    
    // ハイスコアファイルの読み込みを行う
    [self readHiScore];
    
    // ハイスコアラベルのx座標を計算する。
    // ハイスコアラベルは左詰めにし、スコアラベルの右端を原点とする。
    float hiScoreLabelPosX = scoreLabelPosX +
        [AKLabel widthWithLength:[[NSString stringWithFormat:kAKScoreFormat, score_] length] hasFrame:NO] / 2 +
        kAKHiScorePosLeftPoint +
        [AKLabel widthWithLength:[[NSString stringWithFormat:kAKHiScoreFormat, hiScore_] length] hasFrame:NO] / 2;

    // ハイスコアラベルを生成する
    [self setLabelToInfoLayer:[NSString stringWithFormat:kAKHiScoreFormat, hiScore_]
                        atPos:ccp(hiScoreLabelPosX,
                                  [AKScreenSize positionFromTopPoint:kAKHiScorePosTopPoint])
                          tag:kAKInfoTagHiScore
                        frame:kAKLabelFrameNone];
    
    // Wave番号ラベルのx座標を計算する。
    // Wave番号ラベルは左詰めにし、ハイスコアラベルの右端を原点とする。
    float waveNoLabelPosX = hiScoreLabelPosX +
        [AKLabel widthWithLength:[[NSString stringWithFormat:kAKHiScoreFormat, hiScore_] length] hasFrame:NO] / 2 +
        kAKWaveNoPosLeftPoint +
        [AKLabel widthWithLength:[[NSString stringWithFormat:kAKWaveNoFormat, 1, kAKWaveCount] length] hasFrame:NO] / 2;
    
    // Wave番号ラベルを生成する
    [self setLabelToInfoLayer:[NSString stringWithFormat:kAKWaveNoFormat, 1, kAKWaveCount]
                        atPos:ccp(waveNoLabelPosX,
                                  [AKScreenSize positionFromTopPoint:kAKWaveNoPosTopPoint])
                          tag:kAKInfoTagWaveNo
                        frame:kAKLabelFrameNone];
    
    // 命中率ラベルのx座標を計算する。命中率ラベルは左詰めにするため、x座標は右に幅の半分移動する。
    float hitLabelPosX = [AKScreenSize positionFromLeftPoint:kAKHitPosLeftPoint] +
        [AKLabel widthWithLength:[[NSString stringWithFormat:kAKHitFormat, 100] length] hasFrame:NO] / 2;

    // 命中率ラベルを生成する
    [self setLabelToInfoLayer:[NSString stringWithFormat:kAKHitFormat, 100]
                        atPos:ccp(hitLabelPosX,
                                  [AKScreenSize positionFromTopPoint:kAKHitPosTopPoint])
                          tag:kAKInfoTagHit
                        frame:kAKLabelFrameNone];

    // プレイ時間ラベルのx座標を計算する。
    // プレイ時間ラベルは左詰めにし、命中率ラベルの右端を原点とする。
    float timeLabelPosX = hitLabelPosX +
        [AKLabel widthWithLength:[[NSString stringWithFormat:kAKHitFormat, 100] length] hasFrame:NO] / 2 +
        kAKTimePosLeftPoint +
        [AKLabel widthWithLength:[[NSString stringWithFormat:kAKTimeFormat, 0, 0, 0] length] hasFrame:NO] / 2;

    // プレイ時間ラベルを生成する
    [self setLabelToInfoLayer:[NSString stringWithFormat:kAKTimeFormat, 0, 0, 0]
                        atPos:ccp(timeLabelPosX,
                                  [AKScreenSize positionFromTopPoint:kAKTimePosTopPoint])
                          tag:kAKInfoTagTime
                        frame:kAKLabelFrameNone];

    // 状態を初期化する
    [self resetAll:kAKStartStage];
        
    // 更新処理開始
    [self scheduleUpdate];
    
    return self;
}

/*!
 @brief インスタンス解放時処理

 インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    AKLog(1, @"dealloc 開始");
    
    // 更新処理停止
    [self unscheduleUpdate];
    
    // リソースの解放
    self.playerShotPool = nil;
    self.enemyPool = nil;
    self.enemyShotPool = nil;
    self.effectPool = nil;
    self.background = nil;
    
    // スーパークラスの処理を実行する
    [super dealloc];
    
    AKLog(1, @"dealloc 終了");
}

/*!
 @brief ゲーム状態の取得
 
 ゲームシーンの状態を取得する。
 @return ゲーム状態
 */
- (enum AKGameState)state
{
    return state_;
}

/*!
 @brief ゲーム状態の設定
 
 ゲームシーンの状態を設定する。
 同時にインターフェースレイヤーの有効タグも変更する。
 @param state ゲーム状態
 */
- (void)setState:(enum AKGameState)state
{
    // メンバ変数に設定する
    state_ = state;
    
    // 自動ツイート設定の場合、ゲームオーバー時・ゲームクリア時は結果をツイートする
    if ([AKTwitterHelper sharedHelper].mode == kAKTwitterModeAuto &&
        ((self.state == kAKGameStateGameOver) || (self.state == kAKGameStateGameClear))) {
        
        NSString *tweet = [NSString stringWithFormat:@"%@ %@", [self makeTweet], kAKAplUrl];
        [[AKTwitterHelper sharedHelper] tweet:tweet];
    }
    
    // インターフェースレイヤーを取得する
    AKGameIFLayer *interface = (AKGameIFLayer *)[self getChildByTag:kAKLayerPosZInterface];
    
    // 有効なメニューアイテムを変更する
    switch (state) {
        case kAKGameStatePlaying:
            interface.enableTag = kAKGameIFTagPlaying;
            break;
            
        case kAKGameStatePause:
            interface.enableTag = kAKGameIFTagPause;
            break;
            
        case kAKGameStateQuitMenu:
            interface.enableTag = kAKGameIFTagQuit;
            break;
            
        case kAKGameStateGameOver:
            interface.enableTag = kAKGameIFTagGameOver;
            break;
            
        case kAKGameStateGameClear:
            interface.enableTag = kAKGameIFTagGameClear;
            break;
            
        case kAKGameStateResult:
            interface.enableTag = kAKGameIFTagResult;
            break;
            
        case kAKGameStateWait:
            interface.enableTag = kAKGameIFTagWait;
            break;
            
        default:
            interface.enableTag = 0;
            break;
    }
}

/*!
 @brief リザルト画面取得
 
 リザルト画面のインスタンスを取得する。
 @return リザルト画面
 */
- (AKResultLayer *)resultLayer
{
    NSAssert([self getChildByTag:kAKLayerPosZResult] != nil, @"リザルト画面が表示されていない");
    return (AKResultLayer *)[self getChildByTag:kAKLayerPosZResult];
}

/*!
 @brief 入力レイヤー取得
 
 入力レイヤーのインスタンスを取得する。
 @return 入力レイヤー
 */
- (AKGameIFLayer *)interfaceLayer
{
    NSAssert([self getChildByTag:kAKLayerPosZInterface] != nil, @"入力レイヤーが作成されていない");
    return (AKGameIFLayer *)[self getChildByTag:kAKLayerPosZInterface];
}

/*!
 @brief トランジション終了時の処理
 
 トランジション終了時の処理。
 トランジション途中でBGM再生等が行われないようにするため、
 トランジション終了後にゲーム開始の状態にする。
 */
- (void)onEnterTransitionDidFinish
{
    // ゲーム状態を開始時に変更する。
    self.state = kAKGameStateStart;
    
    // スーパークラスの処理を実行する
    [super onEnterTransitionDidFinish];
}

/*!
 @brief 更新処理

 ゲームの状態によって、更新処理を行う。
 @param dt フレーム更新間隔 
 */
- (void)update:(ccTime)dt
{
    // ゲームの状態によって処理を分岐する
    switch (self.state) {
        case kAKGameStateStart:     // ゲーム開始時
            [self updateStart:dt];
            break;
            
        case kAKGameStatePlaying:   // プレイ中
            [self updatePlaying:dt];
            break;
            
        case kAKGameStateStageClear:     // クリア表示中
            [self updatePlaying:dt];
            [self updateClear:dt];
            
            break;
            
        case kAKGameStateResult:    // リザルト画面表示
            [self.resultLayer updateCalc:dt];
            break;
            
        case kAKGameStateSleep:     // スリープ中
            [self updateSleep:dt];
            break;
            
        default:
            // その他の状態のときは変化はないため、無処理とする
            break;
    }
}

/*!
 @brief ゲーム開始時の更新処理

 ステージ定義ファイルを読み込み、敵を配置する。
 @param dt フレーム更新間隔
 */
- (void)updateStart:(ccTime)dt
{
    // BGMを再生する
    [self startBGM];

    // ステージ構成スクリプトを読み込む
    [self readScriptOfStage:stageNo_ Wave:waveNo_];
    
    // 状態をプレイ中へと進める
    self.state = kAKGameStatePlaying;
}

/*!
 @brief プレイ中の更新処理

 各キャラクターの移動処理、衝突判定を行う。
 @param dt フレーム更新間隔
 */
- (void)updatePlaying:(ccTime)dt
{
    float scrx = 0.0f;      // スクリーン座標x
    float scry = 0.0f;      // スクリーン座標y
    float angle = 0.0f;     // スクリーンの向き
    NSEnumerator *enumerator = nil;   // キャラクター操作用列挙子
    AKCharacter *character = nil;       // キャラクター操作作業用バッファ
    BOOL isClear = NO;      // 敵、敵弾がすべていなくなっているか
    CCNode *baseLayer = nil;   // ベースレイヤー
    
    // 自機が破壊されている場合は復活までの時間をカウントする
    if (!self.player.isStaged) {
        
        rebirthInterval_ -= dt;
        
        // 復活までの時間が経過している場合は自機を復活する
        if (rebirthInterval_ < 0) {
            
            // 自機を復活させる
            [self.player rebirth];
        }
    }
    
    // 自機の移動
    // 自機にスクリーン座標は無関係なため、0をダミーで格納する。
    [self.player move:dt ScreenX:0 ScreenY:0];
    AKLog(0, @"m_player.abspos=(%f, %f)", self.player.absx, self.player.absy);
        
    // 移動後のスクリーン座標の取得
    scrx = [self.player getScreenPosX];
    scry = [self.player getScreenPosY];
    AKLog(0, @"x=%f y=%f", scrx, scry);
    
    // 自機弾の移動
    enumerator = [self.playerShotPool.pool objectEnumerator];
    for (character in enumerator) {
        [character move:dt ScreenX:scrx ScreenY:scry];
        AKLog(0 && character.isStaged, @"playerShot.abxpos=(%f, %f)",
               character.absx, character.absy);
    }
    
    // ウェーブをクリアしたかどうかを判定するため、
    // 敵または敵弾がひとつでも存在するかどうかを調べる。
    // 最初にフラグを立てておいて、一つでも存在する場合はフラグを落とす。
    isClear = YES;
    
    // 敵の移動
    enumerator = [self.enemyPool.pool objectEnumerator];
    for (character in enumerator) {
        if (character.isStaged) {
            AKLog(0, @"enemy move start.");
            [character move:dt ScreenX:scrx ScreenY:scry];
            isClear = NO;
        }
    }
    
    // 敵弾の移動
    enumerator = [self.enemyShotPool.pool objectEnumerator];
    for (character in enumerator) {
        if (character.isStaged) {
            [character move:dt ScreenX:scrx ScreenY:scry];
            isClear = NO;
        }
    }
    
    // 自機弾と敵の当たり判定処理を行う
    enumerator = [self.playerShotPool.pool objectEnumerator];
    for (character in enumerator) {
        [character hit:[self.enemyPool.pool objectEnumerator]];
    }
    
    // 自機が無敵状態でない場合は当たり判定処理を行う
    if (!self.player.isInvincible) {
     
        // 自機と敵の当たり判定処理を行う
        [self.player hit:[self.enemyPool.pool objectEnumerator]];
        
        // 自機と敵弾の当たり判定処理を行う
        [self.player hit:[self.enemyShotPool.pool objectEnumerator]];
    }
    
    // 画面効果の移動
    enumerator = [self.effectPool.pool objectEnumerator];
    for (character in enumerator) {
        [character move:dt ScreenX:scrx ScreenY:scry];
        AKLog(0 && character.isStaged, @"effect=(%f, %f) player=(%f, %f)",
               character.image.position.x, character.image.position.y,
               self.player.image.position.x, self.player.image.position.y);
    }
    
    // 背景の移動
    [self.background moveWithScreenX:scrx ScreenY:scry];
    
    // レーダーの更新
    [self.rader updateMarker:self.enemyPool.pool ScreenAngle:self.player.angle];
    
    // 自機の向きの取得
    // 自機の向きと反対方向に画面を回転させるため、符号反転
    angle = -1 * AKCnvAngleRad2Scr(self.player.angle);
    
    // 画面の回転
    baseLayer = [self getChildByTag:kAKLayerPosZBase];
    baseLayer.rotation = angle;
    AKLog(0, @"m_baseLayer angle=%f", baseLayer.rotation);
    
    // 命中率の表示を更新する
    [self updateHit];
    
    // プレイ時間のカウントとクリア判定はプレイ中のみ行う
    if (state_ == kAKGameStatePlaying) {
    
        // プレイ時間を更新する
        playTime_ += dt;
        [self updateTime];
        
        // 敵と敵弾がひとつも存在しない場合は次のウェーブ開始までの時間をカウントする
        if (isClear) {
            // 次のウェーブ開始までの時間をカウントする
            waveInterval_ -= dt;
            
            // ウェーブ開始の間隔が経過した場合はウェーブクリア処理を行う
            if (waveInterval_ < 0.0f) {
                
                // ウェーブクリア処理を行う
                [self clearWave];
                
                // ウェーブ間隔をリセットする
                waveInterval_ = kAKWaveInterval;
            }
        }
    }
}

/*!
 @brief クリア表示中の更新処理
 
 クリア表示の間隔をカウントする。
 一定時間経過後にクリア表示を削除し、リザルト画面を表示して、ゲーム状態をリザルト画面表示に遷移する。
 @param dt フレーム更新間隔
 */
- (void)updateClear:(ccTime)dt
{
    // クリア表示中の間隔をカウントする
    stateInterval_ -= dt;
    
    // クリア表示中の間隔を経過している場合はリザルト画面を表示する
    if (stateInterval_ < 0.0f) {
        
        // 状態をリザルト画面表示に遷移する
        self.state = kAKGameStateResult;
        
        // ステージクリアのラベルを取り除く
        [[self getChildByTag:kAKLayerPosZInfo] removeChildByTag:kAKInfoTagStageClear cleanup:YES];
        
        // リザルト画面を表示する
        [self viewResult];
    }
}

/*!
 @brief スリープ中の更新処理
 
 スリープ中の更新処理を行う。
 スリープ時間経過したら次の状態に遷移する。
 @param dt フレーム更新間隔
 */
- (void)updateSleep:(ccTime)dt
{
    // スリープ時間をカウントする
    sleepTime_ -= dt;
    
    // スリープ時間が経過している場合は次の状態に遷移する
    if (sleepTime_ < 0.0f) {
        self.state = nextState_;
    }
}

/*!
 @brief 自機の移動

 自機の速度を-1.0〜1.0の範囲で設定する。
 @param vx x軸方向の速度
 @param vy y軸方向の速度
 */
- (void)movePlayerByVX:(float)vx VY:(float)vy
{
    [player_ setVelocityX:vx Y:vy];
}

/*!
 @brief 自機弾の発射

 自機弾を発射する。
 */
- (void)firePlayerShot
{
    float angle = 0.0f;     // 発射の方向
    AKPlayerShot *shot = nil; // 自機弾
    
    // 自機が破壊されているときは発射しない
    if (!self.player.isStaged) {
        return;
    }
    
    // プールから未使用のメモリを取得する
    shot = [self.playerShotPool getNext];
    if (shot == nil) {
        // 空きがない場合は処理終了s
        AKLog(1, @"自機弾プールに空きなし");
        assert(0);
        return;
    }
    
    // 発射する方向は自機の角度に回転速度を加算する
    angle = self.player.angle;
    
    // 初回の移動更新処理が終わるまでは表示されないように画面外に移動する
    shot.image.position = ccp([AKScreenSize screenSize].width * 2,
                              [AKScreenSize screenSize].height * 2);
    
    // 自機弾を生成する
    // 位置と向きは自機と同じとする
    [shot createWithX:self.player.absx Y:self.player.absy Z:kAKCharaPosZPlayerShot
                Angle:angle Parent:[self getChildByTag:kAKLayerPosZBase]];
    
    // ショット効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKShotSE];
}

/*!
 @brief 敵の生成

 敵を生成する。
 @param type 敵の種類
 @param posx 生成位置x座標
 @param posy 生成位置y座標
 @param angle 敵の向き
 */
- (void)entryEnemy:(enum AKEnemyType)type PosX:(NSInteger)posx PosY:(NSInteger)posy Angle:(float)angle
{
    AKEnemy *enemy = nil;     // 敵
    SEL createEnemy = nil;  // 敵生成のメソッド
    
    AKLog(0, @"type=%d posx=%d posy=%d angle=%f", type, posx, posy, AKCnvAngleRad2Deg(angle));
    
    // プールから未使用のメモリを取得する
    enemy = [self.enemyPool getNext];
    if (enemy == nil) {
        // 空きがない場合は処理終了
        assert(0);
        AKLog(1, @"敵プールに空きなし");
        return;
    }
    
    // 敵の種類によって生成するメソッドを変える
    switch (type) {
        case kAKEnemyTypeNormal:    // 雑魚
            createEnemy = @selector(createNoraml);
            break;
            
        case kAKEnemyTypeHighSpeed: // 高速移動
            createEnemy = @selector(createHighSpeed);
            break;
            
        case kAKEnemyTypeHighTurn:  // 高速旋回
            createEnemy = @selector(createHighTurn);
            break;
            
        case kAKEnemyTypeHighShot:  // 高速ショット
            createEnemy = @selector(createHighShot);
            break;
            
        case kAKEnemyType3Way:      // 3-Way弾
            createEnemy = @selector(create3WayShot);
            break;
            
        case kAKEnemyTypeCanon:      // 大砲
            createEnemy = @selector(createCanon);
            break;
            
        default:        // その他
            // エラー
            assert(0);
            AKLog(1, @"不正な敵の種類:%d", type);
            
            // 仮に雑魚を設定
            createEnemy = @selector(createNoraml);
            break;
    }
    
    // 敵を生成する
    [enemy createWithX:posx Y:posy Z:kAKCharaPosZEnemy Angle:angle
                Parent:[self getChildByTag:kAKLayerPosZBase] CreateSel:createEnemy];    
    
    // 初回の移動更新処理が終わるまでは表示されないように画面外に移動する
    enemy.image.position = ccp([AKScreenSize screenSize].width * 2,
                               [AKScreenSize screenSize].height * 2);
}

/*!
 @brief 敵弾の生成
 
 敵弾を生成する。
 @param type 敵弾の種類
 @param posx 生成位置x座標
 @param posy 生成位置y座標
 @param angle 敵弾の向き
 */
- (void)fireEnemyShot:(enum ENEMY_SHOT_TYPE)type PosX:(NSInteger)posx PosY:(NSInteger)posy Angle:(float)angle
{
    AKEnemyShot *enemyShot = nil;   // 敵弾
    
    // プールから未使用のメモリを取得する
    enemyShot = [self.enemyShotPool getNext];
    if (enemyShot == nil) {
        // 空きがない場合は処理を終了する
        assert(0);
        return;
    }
    
    // 初回の移動更新処理が行われるまでは表示されないように画面外に移動する
    enemyShot.image.position = ccp([AKScreenSize screenSize].width * 2,
                                   [AKScreenSize screenSize].height * 2);
    
    // 敵弾を生成する
    [enemyShot createWithType:type X:posx Y:posy Z:kAKCharaPosZEnemyShot
                        Angle:angle Parent:[self getChildByTag:kAKLayerPosZBase]];
}

/*!
 @brief 画面効果の生成
 
 画面効果を生成する。指定された画像ファイルからアニメーションを作成する。
 アニメーションは画像内で横方向に同じサイズで並んでいることを前提とする。
 @param fileName 画像ファイル名
 @param rect アニメーション開始時の画像範囲
 @param count アニメーションフレームの個数
 @param delay フレームの間隔
 @param posx x座標
 @param posy y座標
 */
- (void)entryEffect:(NSString *)fileName startRect:(CGRect)rect frameCount:(NSInteger)count
              delay:(float)delay posX:(float)posx posY:(float)posy
{
    // プールから未使用のメモリを取得する
    AKEffect *effect = [self.effectPool getNext];
    if (effect == nil) {
        // 空きがない場合は処理終了
        NSAssert(0, @"画面効果プールに空きがない");
        return;
    }
    
    // 画面効果を生成する
    [effect startEffectWithFile:fileName startRect:rect frameCount:count delay:delay posX:posx posY:posy];
    
    // 画面効果をベースレイヤーに配置する
    [[self getChildByTag:kAKLayerPosZBase] addChild:effect.image z:kAKCharaPosZEffect];
}

/*!
 @brief 自機破壊時の処理
 
 自機が破壊されたときの処理を行う。残機の数を一つ減らして自機を復活させる。
 残機が0の場合はゲームオーバーとする。
 */
- (void)miss
{
    // 残機が残っている場合は残機を減らして復活する
    if (life_ > 0) {

        // ライフを一つ減らす
        life_--;
        
        // 撃墜された数をカウントする
        missCount_++;
        
        // 残機の表示を更新する
        [self.lifeMark updateImage:life_];
        
        // 自機復活までの間隔を設定する
        rebirthInterval_ = kAKRebirthInterval;
    }
    // 残機がなければゲームオーバーとする
    else {
        
        // BGMを停止する
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        
        // ゲームの状態を少し間を空けて、ゲームオーバーに変更する
        sleepTime_ = kAKGameOverInterval;
        nextState_ = kAKGameStateGameOver;
        self.state = kAKGameStateSleep;
    }
}

/*!
 @brief ゲーム状態リセット
 
 ゲームの状態を初期状態にリセットする。
 @param stage 開始ステージ番号
 */
- (void)resetAll:(NSInteger)stage
{
    AKLog(1, @"ゲーム状態リセット");
    
    // 各種メンバを初期化する
    self.state = kAKGameStatePreLoad;
    stageNo_ = stage;
    waveNo_ = 1;
    life_ = kAKStartLifeCount;
    rebirthInterval_ = 0.0f;
    waveInterval_ = kAKWaveInterval;
    score_ = 0;
    shotCount_ = 0;
    hitCount_ = 0;
    missCount_ = 0;
    playTime_ = 0.0f;
    enemyCount_ = 0;
    
    // 残機マークの初期個数を反映させる
    [self.lifeMark updateImage:life_];
    
    // 情報レイヤーを取得する
    CCNode *infoLayer = [self getChildByTag:kAKLayerPosZInfo];
    
    // ラベルの内容を更新する
    NSString *scoreString = [NSString stringWithFormat:kAKScoreFormat, score_];
    AKLabel *scoreLabel = (AKLabel *)[infoLayer getChildByTag:kAKInfoTagScore];
    [scoreLabel setString:scoreString];

    // 自機の状態を初期化する
    [self.player reset];

    // 画面上の全キャラクターを削除する
    [self.playerShotPool reset];
    [self.enemyPool reset];
    [self.enemyShotPool reset];
    [self.effectPool reset];
    
    // ゲームクリアの表示を削除する
    [infoLayer removeChildByTag:kAKInfoTagGameClear cleanup:YES];
}

/*!
 @brief スコア加算
 
 スコアを加算する。
 */
- (void)addScore:(NSInteger)score
{
    // エクステンドの判定を行う
    // ゲームオーバー時にはエクステンドしない(相打ちによってスコアが入った時)
    if ((int)(score_ / kAKExtendScore) < (int)((score_ + score) / kAKExtendScore) &&
        nextState_ != kAKGameStateGameOver) {
        
        AKLog(1, @"エクステンド:m_score=%d score=%d しきい値=%d", score_, score, kAKExtendScore);
        
        // エクステンドの効果音を鳴らす
        [[SimpleAudioEngine sharedEngine] playEffect:kAK1UpSE];
        
        // 残機の数を増やす
        life_++;
        
        // 残機マークを更新する
        [self.lifeMark updateImage:life_];
        
        // 実績を解除する
        [[AKGameCenterHelper sharedHelper] reportAchievements:kAKGC1UpID];
    }
    
    // スコアを加算する
    score_ += score;
    
    // 情報レイヤーを取得する
    CCNode *infoLayer = [self getChildByTag:kAKLayerPosZInfo];
    
    // ラベルの内容を更新する
    NSString *scoreString = [NSString stringWithFormat:kAKScoreFormat, score_];
    AKLabel *scoreLabel = (AKLabel *)[infoLayer getChildByTag:kAKInfoTagScore];
    [scoreLabel setString:scoreString];
    
    // ハイスコアを更新している場合はハイスコアを設定する
    if (score_ > hiScore_) {
        
        // ハイスコアにスコアの値を設定する
        hiScore_ = score_;
        
        // ラベルの内容を更新する
        NSString *hiScoreString = [NSString stringWithFormat:kAKHiScoreFormat, hiScore_];
        AKLabel *hiScoreLabel = (AKLabel *)[infoLayer getChildByTag:kAKInfoTagHiScore];
        [hiScoreLabel setString:hiScoreString];
    }
}

/*!
 @brief ポーズ
 
 プレイ中の状態からゲームを一時停止する。
 @param isUseSE 効果音を鳴らすかどうか
 */
- (void)pause:(BOOL)isUseSE
{
    // プレイ中から以外の変更の場合はエラー
    assert(self.state == kAKGameStatePlaying);
    
    // BGMを一時停止する
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    
    if (isUseSE) {
        
        // 一時停止効果音を鳴らす
        [[SimpleAudioEngine sharedEngine] playEffect:kAKPauseSE];
    }
    
    // ゲーム状態を一時停止に変更する
    self.state = kAKGameStatePause;
    
    // すべてのキャラクターのアニメーションを停止する
    // 自機
    [self.player.image pauseSchedulerAndActions];

    // 自機弾
    for (AKCharacter *character in [self.playerShotPool.pool objectEnumerator]) {
        [character.image pauseSchedulerAndActions];
    }
    
    // 敵
    for (AKCharacter *character in [self.enemyPool.pool objectEnumerator]) {
        [character.image pauseSchedulerAndActions];
    }

    // 敵弾
    for (AKCharacter *character in [self.enemyShotPool.pool objectEnumerator]) {
        [character.image pauseSchedulerAndActions];
    }

    // 画面効果
    for (AKCharacter *character in [self.effectPool.pool objectEnumerator]) {
        [character.image pauseSchedulerAndActions];
    }
}

/*!
 @brief ポーズ
 
 プレイ中の状態からゲームを一時停止する。
 効果音ありとする。
 */
- (void)pause
{
    // 効果音ありで一時停止を行う。
    [self pause:YES];
}

/*!
 @brief ゲーム再開
 
 一時停止中の状態からゲームを再会する。
 */
- (void)resume
{    
    // 一時停止中から以外の変更の場合はエラー
    NSAssert(self.state == kAKGameStateWait, @"状態遷移異常");
    
    // 一時停止したBGMを再開する
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];

    // ゲーム状態をプレイ中に変更する
    self.state = kAKGameStatePlaying;
    
    // すべてのキャラクターのアニメーションを再開する
    // 自機
    [self.player.image resumeSchedulerAndActions];

    // 自機弾
    for (AKCharacter *character in self.playerShotPool.pool.objectEnumerator) {
        [character.image resumeSchedulerAndActions];
    }

    // 敵
    for (AKCharacter *character in self.enemyPool.pool.objectEnumerator) {
        [character.image resumeSchedulerAndActions];
    }

    // 敵弾
    for (AKCharacter *character in self.enemyShotPool.pool.objectEnumerator) {
        [character.image resumeSchedulerAndActions];
    }

    // 画面効果
    for (AKCharacter *character in self.effectPool.pool.objectEnumerator) {
        [character.image resumeSchedulerAndActions];
    }
}

/*!
 @brief スクリプト読込
 
 ステージ構成のスクリプトファイルを読み込んで敵を配置する。
 @param stage ステージ番号
 @param wave ウェーブ番号
 */
- (void)readScriptOfStage:(NSInteger)stage Wave:(NSInteger)wave
{
    // ファイル名をステージ番号、ウェイブ番号から決定する
    NSString *fileName = [NSString stringWithFormat:@"stage%d_%d", stage, wave];
    AKLog(1, @"fileName=%@", fileName);
    
    // ファイルパスをバンドルから取得する
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *filePath = [bundle pathForResource:fileName ofType:@"txt"];
    AKLog(0, @"filePath=%@", filePath);
    
    // ステージ定義ファイルを読み込む
    NSError *error = nil;
    NSString *stageScript = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding
                                                         error:&error];
    // ファイル読み込みエラー
    if (stageScript == nil && error != nil) {
        AKLog(0, @"%@", [error localizedDescription]);
    }
    
    // ステージ定義ファイルの範囲の間は処理を続ける
    NSInteger count = 0;
    NSRange lineRange = {0};
    while (lineRange.location < stageScript.length) {
        
        // 1行の範囲を取得する
        lineRange = [stageScript lineRangeForRange:lineRange];
        
        // 1行の文字列を取得する
        NSString *line = [stageScript substringWithRange:lineRange];
        AKLog(0, @"%@", line);
        
        // 1文字目が"#"の場合は処理を飛ばす
        if ([[line substringToIndex:1] isEqualToString:@"#"]) {
            AKLog(0, @"コメント:%@", line);
        }
        // コメントでない場合はパラメータを読み込む
        else {
            // カンマ区切りでパラメータを分割する
            NSArray *params = [line componentsSeparatedByString:@","];
            
            // 1個目のパラメータは敵の種類として扱う。
            NSString *param = [params objectAtIndex:0];
            enum AKEnemyType enemyType = [param integerValue];
            
            // 敵の種類は0始まりとするため、-1する。
            enemyType--;
            
            // 2個目のパラメータはx座標として扱う
            param = [params objectAtIndex:1];
            NSInteger enemyPosX = [param integerValue];
            
            // 3個目のパラメータはy座標として扱う
            param = [params objectAtIndex:2];
            NSInteger enemyPosY = [param integerValue];
            
            // iPadの場合は座標を倍にする
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                enemyPosX *= 2;
                enemyPosY *= 2;
            }
            
            AKLog(0, @"type=%d posx=%d posy=%d", enemyType, enemyPosX, enemyPosY);
            
            // 角度を自機のいる位置に設定する
            // スクリプト上の座標は自機の位置からの相対位置なので目標座標は(0, 0)
            float enemyAngle = AKCalcDestAngle(enemyPosX, enemyPosY, 0, 0);
            
            AKLog(0, @"angle=%f", AKCnvAngleRad2Deg(enemyAngle));
            
            // 生成位置は自機の位置からの相対位置とする
            enemyPosX += player_.absx;
            enemyPosY += player_.absy;
            
            // 敵を生成する
            [self entryEnemy:(enum AKEnemyType)enemyType PosX:enemyPosX PosY:enemyPosY Angle:enemyAngle];
            
            // 生成した敵の数をカウントする
            count++;
        }
        
        // 次の行へ処理を進める
        lineRange.location = lineRange.location + lineRange.length;
        lineRange.length = 0;
    }
    
    // 敵の数を保持する
    enemyCount_ += count;
    
    // 情報レイヤーを取得する
    CCNode *infoLayer = [self getChildByTag:kAKLayerPosZInfo];
    
    // ラベルの内容を更新する
    NSString *waveNoString = [NSString stringWithFormat:kAKWaveNoFormat, waveNo_, kAKWaveCount];
    AKLabel *waveNoLabel = (AKLabel *)[infoLayer getChildByTag:kAKInfoTagWaveNo];
    [waveNoLabel setString:waveNoString];
}

/*!
 @brief ウェーブクリア
 
 ウェーブクリア時の処理。次のウェーブのスクリプトを読み込む。
 すべてのウェーブをクリアしている場合はステージクリア画面を表示する。
 */
- (void)clearWave
{
    // ウェーブを進める
    waveNo_++;
    
    // ステージのウェーブ個数を超えている場合はステージクリア
    if (waveNo_ > kAKWaveCount) {
        
        // 状態をゲームクリアに移行する
        self.state = kAKGameStateStageClear;
        
        // クリアキャプション表示中の間隔を設定する
        stateInterval_ = kAKStageClearInterval;
        
        // クリアBGMを再生する
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:kAKClearBGM loop:NO];
        
        // ステージクリアのラベルを生成する
        [self setLabelToInfoLayer:kAKStageClearString
                            atPos:ccp([AKScreenSize center].x, [AKScreenSize center].y)
                              tag:kAKInfoTagStageClear
                            frame:kAKLabelFrameNone];
        
        // ステージクリアの実績を解除する
        [[AKGameCenterHelper sharedHelper] reportStageClear:stageNo_];
        
        // ステージクリア数の実績を増加させる
        [[AKGameCenterHelper sharedHelper] reportAchievements:kAKGCPlayCountID percentIncrement:1.0f];
        
        // 撃墜された数が0の場合は実績を解除する
        if (missCount_ <= 0) {
            [[AKGameCenterHelper sharedHelper] reportAchievements:kAKGCNoMissID];
        }
        
        // 撃墜された数を初期化する
        missCount_ = 0;
    }
    // ステージクリアでない場合は次のウェーブのスクリプトを読み込む
    else {
        [self readScriptOfStage:stageNo_ Wave:waveNo_];
    }
}

/*!
 @brief ステージクリア結果スキップ
 
 ステージクリア画面の表示更新をスキップする。
 すてに表示が完了している場合は次のステージを開始する。
 */
- (void)skipResult
{
    AKLog(1, @"start");
    
    // ステージクリア画面の表示が完了している場合は次のステージを開始する
    if (self.resultLayer.isFinish) {
        [self clearStage];
    }
    // ステージクリア画面の表示が完了していない場合は強制的に進める
    else {
        [self.resultLayer finish];
    }
}

/*!
 @brief ステージクリア
 
 ステージクリア時の処理。
 スコアラベルの更新。キャラクターの初期化。次のステージスクリプト読込。
 全ステージをクリアしている場合はエンディング表示。
 */
- (void)clearStage
{
    // ステージ番号を進める
    stageNo_++;
    
    // ステージクリア結果画面を削除する
    [self removeChildByTag:kAKLayerPosZResult cleanup:YES];
    
    // まだ全ステージをクリアしていない場合は次のステージを開始する
    if (stageNo_ <= kAKStageCount) {
        
        // プレイ中BGMを開始する
        [self startBGM];
        
        // ゲームの状態をプレイ中に変更する
        self.state = kAKGameStatePlaying;
        
        // ウェーブ番号を初期化する
        waveNo_ = 1;
    
        // 自機復活までのインターバルを初期化する
        rebirthInterval_ = 0.0f;
        
        // 命中率を初期化する
        shotCount_ = 0;
        hitCount_ = 0;
        
        // 敵の数を初期化する
        enemyCount_ = 0;
        
        // ステージのプレイ時間を初期化する
        playTime_ = 0.0f;

        // 残機マークを更新する
        [self.lifeMark updateImage:life_];

        // 情報レイヤーを取得する
        CCNode *infoLayer = [self getChildByTag:kAKLayerPosZInfo];

        // スコアラベルの内容を更新する
        {
            NSString *scoreString = [NSString stringWithFormat:kAKScoreFormat, score_];
            AKLabel *scoreLabel = (AKLabel *)[infoLayer getChildByTag:kAKInfoTagScore];
            [scoreLabel setString:scoreString];
        }
        
        // ハイスコアラベルの内容を更新する
        {
            NSString *hiScoreString = [NSString stringWithFormat:kAKHiScoreFormat, hiScore_];
            AKLabel *hiScoreLabel = (AKLabel *)[infoLayer getChildByTag:kAKInfoTagHiScore];
            [hiScoreLabel setString:hiScoreString];
        }
        
        // 自機の状態を初期化する
        [self.player reset];
        
        // 画面上の全キャラクターを削除する
        [self.playerShotPool reset];
        [self.enemyPool reset];
        [self.effectPool reset];
        
        // 次のステージのスクリプトを読み込む
        [self readScriptOfStage:stageNo_ Wave:waveNo_];
    }
    // 全ステージクリアしている場合はエンディング画面の表示を行う
    else {
        
        // ゲームクリア時のBGMを鳴らす
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:kAKEndingBGM loop:NO];
        
        // ゲームの状態をゲームクリアに変更する
        self.state = kAKGameStateGameClear;
        
        // 背景色レイヤーを作成する
        CCLayerColor *backColor = AKCreateBackColorLayer();
        
        // タグを設定する
        backColor.tag = kAKInfoTagGameClear;

        // 情報レイヤーへ配置する
        [[self getChildByTag:kAKLayerPosZInfo] addChild:backColor];
    }
}

/*!
 @brief ハイスコアファイルの読込
 
 ハイスコアファイルを読み込む。
 */
- (void)readHiScore
{
    AKLog(1, @"start readHiScore");
    
    // HOMEディレクトリのパスを取得する
    NSString *homeDir = NSHomeDirectory();
    
    // Documentsディレクトリへのパスを作成する
    NSString *docDir = [homeDir stringByAppendingPathComponent:@"Documents"];
    
    // ファイルパスを作成する
    NSString *filePath = [docDir stringByAppendingPathComponent:kAKDataFileName];
    
    // ファイルを読み込む
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    // ファイルが読み込めた場合はデータを取得する
    if (data != nil) {
      
        // ファイルからデコーダーを生成する
        NSKeyedUnarchiver *decoder = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
        
        // ハイスコアをデコードする
        AKHiScoreFile *hiScore = [decoder decodeObjectForKey:kAKDataFileKey];
        
        // デコードを完了する
        [decoder finishDecoding];
        
        // メンバに読み込む
        hiScore_ = hiScore.hiscore;
        
        AKLog(1, @"m_hiScore=%d", hiScore_);
    }
}

/*!
 @brief ハイスコアファイルの書込
 
 ハイスコアファイルを書き込む。
 */
- (void)writeHiScore
{
    AKLog(1, @"start writeHiScore:m_hiScore=%d m_score=%d", hiScore_, score_);
    
    // HOMEディレクトリのパスを取得する
    NSString *homeDir = NSHomeDirectory();
    
    // Documentsディレクトリへのパスを作成する
    NSString *docDir = [homeDir stringByAppendingPathComponent:@"Documents"];
    
    // ファイルパスを作成する
    NSString *filePath = [docDir stringByAppendingPathComponent:kAKDataFileName];
    
    // ハイスコアファイルオブジェクトを生成する
    AKHiScoreFile *hiScore = [[[AKHiScoreFile alloc] init] autorelease];
    
    // ハイスコアを設定する
    hiScore.hiscore = hiScore_;
    
    // エンコーダーを生成する
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *encoder = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    
    // ファイル内容をエンコードする
    [encoder encodeObject:hiScore forKey:kAKDataFileKey];
    
    // エンコードを完了する
    [encoder finishEncoding];
    
    // ファイルを書き込む
    [data writeToFile:filePath atomically:YES];
    
    // Game Centerにスコアを送信する
    [[AKGameCenterHelper sharedHelper] reportHiScore:score_];
}

/*!
 @brief 命中率更新
 
 命中率のラベルを更新する。
 */
- (void)updateHit
{
    // 命中率を計算する。1発も発射していない場合は100%とする。
    NSInteger hit = 0;
    if (shotCount_ == 0) {
        hit = 100;
    }
    else {
        hit = (float)hitCount_ / shotCount_ * 100.0f;
    }
    AKLog(0, @"hitCount=%d shotCount=%d hit=%d", hitCount_, shotCount_, hit);
    
    // 情報レイヤーを取得する
    CCNode *infoLayer = [self getChildByTag:kAKLayerPosZInfo];
    
    // 命中率ラベルを取得する
    AKLabel *hitLabel = (AKLabel *)[infoLayer getChildByTag:kAKInfoTagHit];
    
    // 命中率ラベルを更新する
    NSString *hitString = [NSString stringWithFormat:kAKHitFormat, hit];
    [hitLabel setString:hitString];
    
    AKLog(0, @"str=%@", hitString);
}

/*!
 @brief プレイ時間更新
 
 プレイ時間のラベルを更新する。
 */
- (void)updateTime
{
    // プレイ時間を分、秒、ミリ秒に分割する
    // 分を計算する
    NSInteger min = ((NSInteger)playTime_) / 60;
    
    // 秒を計算する
    NSInteger sec = ((NSInteger)playTime_) % 60;
    
    // ミリ秒を計算する
    NSInteger millisec = ((NSInteger)(playTime_ * 100.0f)) % 100;
    
    // 99分を超えている場合はカンストとする
    if (min > 99) {
        min = 99;
        sec = 59;
        millisec = 99;
    }

    // 情報レイヤーを取得する
    CCNode *infoLayer = [self getChildByTag:kAKLayerPosZInfo];
    
    // プレイ時間ラベルを取得する
    AKLabel *timeLabel = (AKLabel *)[infoLayer getChildByTag:kAKInfoTagTime];
    
    // 命中率ラベルを更新する
    NSString *timeString = [NSString stringWithFormat:kAKTimeFormat, min, sec, millisec];
    [timeLabel setString:timeString];
}

/*!
 @brief 情報レイヤーへのラベル配置
 
 ラベルを作成して情報レイヤーへ配置する。
 @param str ラベルの文字列
 @param pos 配置位置
 @param tag ラベルのタグ
 @param frame 枠の種類
 */
- (void)setLabelToInfoLayer:(NSString *)str atPos:(CGPoint)pos tag:(NSInteger)tag frame:(enum AKLabelFrame)frame
{
    // ラベルを生成する
    AKLabel *label = [AKLabel labelWithString:str maxLength:str.length maxLine:1 frame:frame];
    
    // タグを設定する
    label.tag = tag;
    
    // 表示位置を設定する
    label.position = pos;
    
    // 情報レイヤーに配置する
    [[self getChildByTag:kAKLayerPosZInfo] addChild:label];
}


/*!
 @brief タイトル画面に戻る
 
 タイトル画面に戻る。
 */
- (void)backToTitle
{
    AKLog(0, @"backToTitle開始");
    
    // ハイスコアをファイルに書き込む
    [self writeHiScore];
    
    // BGMを停止する
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        
    // タイトルシーンへの遷移を作成する
    CCTransitionFade *transition = [CCTransitionFade transitionWithDuration:0.5f scene:[AKTitleScene node]];
    
    // タイトルシーンへ遷移する
    [[CCDirector sharedDirector] replaceScene:transition];

    AKLog(0, @"backToTitle終了");
}

/*!
 @brief リザルト画面表示
 
 リザルト画面を表示する。
 */
- (void)viewResult
{
    // 結果画面を生成する
    AKResultLayer *resultLayer = [AKResultLayer node];
    resultLayer.tag = kAKLayerPosZResult;
    [self addChild:resultLayer z:kAKLayerPosZResult];
    
    // 命中率を計算する。1発も発射していない場合は100%とする。
    NSInteger hit = 0;
    if (shotCount_ == 0) {
        hit = 100;
    }
    else {
        hit = (float)hitCount_ / shotCount_ * 100.0f;
    }
    
    // 各種パラメータを設定する
    [resultLayer setParameterStage:stageNo_
                             score:score_
                              time:(NSInteger)playTime_
                               hit:hit
                              rest:life_
                        enemyCount:enemyCount_];
}

/*!
 @brief 終了メニュー表示
 
 一時停止メニューを消し、終了メニューを表示し、ゲーム状態を遷移する。
 */
- (void)viewQuitMenu
{
    // ゲーム状態を終了メニュー表示中に遷移する
    self.state = kAKGameStateQuitMenu;    
}

/*!
 @brief 終了メニュー実行
 
 終了メニューでYESボタンをタップしたときの処理。
 終了メニューの削除、タイトル画面への遷移を行う。
 */
- (void)execQuitMenu
{
    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
    // タイトル画面へ戻る
    [self backToTitle];
}

/*!
 @brief 終了メニューキャンセル
 
 終了メニューでNOボタンをタップしたときの処理。
 終了メニューの削除、一時停止メニューの表示、ゲーム状態の一時停止への遷移を行う。
 */
- (void)cancelQuitMenu
{
    // ゲーム状態を一時停止中に遷移する
    self.state = kAKGameStatePause;
}

/*!
 @brief 再開ボタン選択
 
 再開ボタン選択時の処理。
 再開ボタンをブリンクし、アクション完了時にゲーム再開処理が呼ばれるようにする。
 */
- (void)selectResumeButton
{
    // 他の処理が動作しないように待機状態にする
    self.state = kAKGameStateWait;

    // ボタンのブリンクアクションを作成する
    CCBlink *blink = [CCBlink actionWithDuration:0.2f blinks:2];
    CCCallFunc *callFunc = [CCCallFunc actionWithTarget:self selector:@selector(resume)];
    CCSequence *action = [CCSequence actions:blink, callFunc, nil];
    
    // ボタンを取得する
    CCNode *button = self.interfaceLayer.resumeButton;
    
    // ブリンクアクションを開始する
    [button runAction:action];

    // 一時停止効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKPauseSE];    

}

/*!
 @brief 終了ボタン選択
 
 終了ボタン選択時の処理。
 終了ボタンをブリンクし、アクション完了時に終了メニュー表示処理が呼ばれるようにする。
 */
- (void)selectQuitButton
{
    // 他の処理が動作しないように待機状態にする
    self.state = kAKGameStateWait;

    // ボタンのブリンクアクションを作成する
    CCBlink *blink = [CCBlink actionWithDuration:0.2f blinks:2];
    CCCallFunc *callFunc = [CCCallFunc actionWithTarget:self selector:@selector(viewQuitMenu)];
    CCSequence *action = [CCSequence actions:blink, callFunc, nil];
    
    // ボタンを取得する
    CCNode *button = self.interfaceLayer.quitButton;
    
    // ブリンクアクションを開始する
    [button runAction:action];
    
    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
}

/*!
 @brief 終了メニューNOボタン選択
 
 終了メニューのNOボタン選択時の処理。
 NOボタンをブリンクし、アクション完了時に一時停止メニュー表示処理が呼ばれるようにする。
 */
- (void)selectQuitNoButton
{
    // 他の処理が動作しないように待機状態にする
    self.state = kAKGameStateWait;
    
    // ボタンのブリンクアクションを作成する
    CCBlink *blink = [CCBlink actionWithDuration:0.2f blinks:2];
    CCCallFunc *callFunc = [CCCallFunc actionWithTarget:self selector:@selector(cancelQuitMenu)];
    CCSequence *action = [CCSequence actions:blink, callFunc, nil];
    
    // ボタンを取得する
    CCNode *button = self.interfaceLayer.quitNoButton;
    
    // ブリンクアクションを開始する
    [button runAction:action];
    
    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
}

/*!
 @brief ツイートボタン選択
 
 ツイートボタン選択時の処理。
 ツイートビューを表示し、タイトルへ戻る。
 */
- (void)selectTweetButton
{
    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
    // ツイートビューを表示する
    [[AKTwitterHelper sharedHelper] viewTwitterWithInitialString:[self makeTweet]];
}

/*!
 @brief ツイート内容作成
 
 ツイート内容を作成する。
 */
- (NSString *)makeTweet
{
    NSString *tweet = nil;

    // 全ステージクリアの場合と途中でゲームオーバーになった時でツイート内容を変更する。
    if (stageNo_ > kAKStageCount) {
        NSString *format = NSLocalizedString(kAKGameClearTweetKey, @"ゲームクリア時のツイート");
        tweet = [NSString stringWithFormat:format, score_];
    }
    else {
        NSString *format = NSLocalizedString(kAKGameOverTweetKey, @"ゲームオーバー時のツイート");
        tweet = [NSString stringWithFormat:format, stageNo_, score_];
    }
    
    
#ifdef DEBUG
    return [NSString stringWithFormat:@"%@ %@", tweet, [[NSDate date] description]];
#else
    return tweet;
#endif
}

/*!
 @brief コンティニューボタン選択
 
 コンティニューボタンが選択された時の処理。
 ステージ番号以外をすべてリセットする。
 */
- (void)selectContinueButton
{
    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
    // 現在のステージ番号を指定して初期化を行う
    [self resetAll:stageNo_];
    
    // ゲーム状態を開始時に変更する。
    self.state = kAKGameStateStart;
}

/*!
 @brief BGM再生
 
 ステージ番号に対応したBGM再生を開始する。
 */
- (void)startBGM
{
    /// プレイ中BGMファイル名
    NSString *kAKPlayBGM = @"Stage%d.mp3";

    NSString *fileName = [NSString stringWithFormat:kAKPlayBGM, stageNo_];
    
    // BGMを再生する
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:fileName loop:YES];
}
@end