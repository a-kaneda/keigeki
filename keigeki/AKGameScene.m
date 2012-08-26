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

/*!
 @brief ゲームプレイシーン
 
 ゲームプレイのメインのシーンを管理する。
 */
@implementation AKGameScene

// シングルトンオブジェクト
static AKGameScene *g_scene = nil;

@synthesize state = m_state;
@synthesize player = m_player;
@synthesize playerShotPool = m_playerShotPool;
@synthesize enemyPool = m_enemyPool;
@synthesize enemyShotPool = m_enemyShotPool;
@synthesize rader = m_radar;
@synthesize effectPool = m_effectPool;
@synthesize lifeMark = m_lifeMark;

/*!
 @brief シングルトンオブジェクト取得

 シングルトンオブジェクトを返す。初回呼び出し時はオブジェクトを作成して返す。
 @return シングルトンオブジェクト
 */
+ (AKGameScene *)sharedInstance
{
    // シングルトンオブジェクトが作成されていない場合は作成する。
    if (g_scene == nil) {
        g_scene = [AKGameScene node];
    }
    
    // シングルトンオブジェクトを返す。
    return g_scene;
}

/*!
 @method オブジェクト生成処理
 @abstruct オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    float anchor_x = 0.0f;  // 画面回転時の中心点x座標
    float anchor_y = 0.0f;  // 画面回転時の中心点y座標
    AKHiScoreFile *hiScoreFile = nil;   // ハイスコアファイル
    NSString *hiScoreString = nil;      // ハイスコア文字列
    NSString *scoreString = nil;        // スコア文字列
    CCLabelTTF *scoreLabel = nil;       // スコアのラベル
    CCLabelTTF *hiScoreLabel = nil;     // ハイスコアのラベル
    CCLayer *baseLayer = nil;           // ベースレイヤー
    CCLayer *infoLayer = nil;           // 情報レイヤー
    AKGameIFLayer *interface = nil;     // インターフェースレイヤー
    CCSprite *shotButton = nil;         // ショットボタンのスプライト
    CCSprite *pauseButton = nil;        // ポーズボタンのスプライト
    
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // キャラクターを配置するレイヤーを生成する
    baseLayer = [CCLayer node];
    baseLayer.tag = LAYER_POS_Z_BASELAYER;
    [self addChild:baseLayer z:LAYER_POS_Z_BASELAYER];
    
    // 画面回転時の中心点を求める
    // CCLayerのサイズは320x480だが、画面サイズはLandscape時は480x320のため、
    // 画面右上の点が(480 / 320, 320 / 480)となる。
    // 中心点座標のCCLayer上での比率に上の値をかけて、画面上での比率を求める。
    anchor_x = ((float)PLAYER_POS_X / SCREEN_WIDTH) * ((float)SCREEN_WIDTH / SCREEN_HEIGHT);
    anchor_y = ((float)PLAYER_POS_Y / SCREEN_HEIGHT) * ((float)SCREEN_HEIGHT / SCREEN_WIDTH);
    
    // 画面回転時の中心点を設定する
    baseLayer.anchorPoint = ccp(anchor_x, anchor_y);
    
    // キャラクター以外の情報を配置するレイヤーを生成する
    infoLayer = [CCLayer node];
    infoLayer.tag = LAYER_POS_Z_INFOLAYER;
    [self addChild:infoLayer z:LAYER_POS_Z_INFOLAYER];
    
    // インターフェースレイヤーを貼り付ける
    interface = [AKGameIFLayer node];
    [self addChild:interface z:LAYER_POS_Z_INTERFACELAYER];
    
    // 背景の生成
    self.background = [[[AKBackground alloc] init] autorelease];
    [baseLayer addChild:self.background.image z:CHARA_POS_Z_BACKGROUND];
    
    // 自機の生成
    self.player = [[[AKPlayer alloc] init] autorelease];
    [baseLayer addChild:self.player.image z:CHARA_POS_Z_PLAYER];
    
    // 自機弾プールの生成
    self.playerShotPool = [[[AKCharacterPool alloc] initWithClass:[AKPlayerShot class]
                                                             Size:MAX_PLAYER_SHOT_COUNT] autorelease];
    
    // 敵プールの生成
    self.enemyPool = [[[AKCharacterPool alloc] initWithClass:[AKEnemy class]
                                                        Size:MAX_ENEMY_COUNT] autorelease];
    
    // 敵弾プールの生成
    self.enemyShotPool = [[[AKCharacterPool alloc] initWithClass:[AKEnemyShot class]
                                                            Size:MAX_ENEMY_SHOT_COUNT] autorelease];

    // 画面効果プールの生成
    self.effectPool = [[[AKCharacterPool alloc] initWithClass:[AKEffect class]
                                                         Size:MAX_EFFECT_COUNT] autorelease];
    
    // ショットボタンの画像を読み込む
    shotButton = [CCSprite spriteWithFile:@"ShotButton.png"];
    assert(shotButton != nil);
    
    // ショットボタンの位置を設定する
    shotButton.position = ccp(SHOT_BUTTON_POS_X, SHOT_BUTTON_POS_Y);
    
    // ショットボタンをレイヤーに配置する
    [infoLayer addChild:shotButton];
    
    // ポーズボタンの画像を読み込む
    pauseButton = [CCSprite spriteWithFile:@"PauseButton.png"];
    assert(pauseButton != nil);
    
    // ポーズボタンの位置を設定する
    pauseButton.position = ccp(PAUSE_BUTTON_POS_X, PAUSE_BUTTON_POS_Y);
    
    // ポーズボタンをレイヤーに配置する
    [infoLayer addChild:pauseButton];
    
    // レーダーの生成
    self.rader = [AKRadar node];
    
    // レーダーをレイヤーに配置する
    [infoLayer addChild:self.rader];
    
    // 残機マークの生成
    self.lifeMark = [AKLifeMark node];
    
    // 残機マークをレイヤーに配置する
    [infoLayer addChild:self.lifeMark];
    
    // スコアラベルを生成する
    scoreString = [NSString stringWithFormat:SCORE_FORMAT, m_score];
    scoreLabel = [CCLabelTTF labelWithString:scoreString fontName:@"Helvetica" fontSize:22];
    scoreLabel.tag = INFOLAYER_TAG_SCORE;
    [infoLayer addChild:scoreLabel];
    
    // スコアラベルの位置を設定する
    // アンカーポイントは左端に設定する
    scoreLabel.anchorPoint = ccp(0.0f, 0.5f);
    scoreLabel.position = ccp(SCORE_POS_X, SCORE_POS_Y);
    
    // ハイスコアファイルの読み込みを行う
    hiScoreFile = [[[AKHiScoreFile alloc] init] autorelease];
    [hiScoreFile read];
    
    // ハイスコアをメンバに設定する
    m_hiScore = hiScoreFile.hiscore;
    
    // ハイスコアラベルを生成する
    hiScoreString = [NSString stringWithFormat:HISCORE_FORMAT, m_hiScore];
    hiScoreLabel = [CCLabelTTF labelWithString:hiScoreString fontName:@"Helvetica" fontSize:22];
    hiScoreLabel.tag = INFOLAYER_TAG_HISCORE;
    [infoLayer addChild:hiScoreLabel];

    // ハイスコアラベルの位置を設定する。
    hiScoreLabel.position = ccp(HISCORE_POS_X, HISCORE_POS_Y);

    // 状態を初期化する
    [self resetAll];
    
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
    // 更新処理停止
    [self unscheduleUpdate];
    
    // リソースの解放
    self.playerShotPool = nil;
    self.enemyPool = nil;
    self.enemyShotPool = nil;
    self.effectPool = nil;
    self.background = nil;
    [self removeAllChildrenWithCleanup:YES];
    
    [super dealloc];
}

/*!
 @brief 更新処理

 ゲームの状態によって、更新処理を行う。
 @param dt フレーム更新間隔 
 */
- (void)update:(ccTime)dt
{
    // ゲームの状態によって処理を分岐する
    switch (m_state) {
        case GAME_STATE_START:      // ゲーム開始時
            [self updateStart:dt];
            break;
            
        case GAME_STATE_PLAYING:    // プレイ中
            [self updatePlaying:dt];
            break;
            
        case GAME_STATE_CLEAR:      // クリア
        {
            // ステージクリア画面を取得し、更新を行う
            AKResultLayer *result = (AKResultLayer *)[self getChildByTag:LAYER_POS_Z_RESULTLAYER];
            [result updateCalc:dt];
        }
            break;
            
        case GAME_STATE_GAMEOVER:   // ゲームオーバー
            // 画面に変化はないため無処理
            break;
            
        default:
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
    // ステージ構成スクリプトを読み込む
    [self readScriptOfStage:m_stageNo Wave:m_waveNo];
    
    // 状態をプレイ中へと進める
    m_state = GAME_STATE_PLAYING;
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
    AKHiScoreFile *hiScoreFile = nil;   // ハイスコアファイル
    BOOL isClear = NO;      // 敵、敵弾がすべていなくなっているか
    CCNode *baseLayer = nil;   // ベースレイヤー
    
    // 自機が破壊されている場合は復活までの時間をカウントする
    if (!self.player.isStaged) {
        
        m_rebirthInterval -= dt;
        
        // 復活までの時間が経過している場合は自機を復活する
        if (m_rebirthInterval < 0) {
            
            // 自機を復活させる
            [self.player rebirth];
        }
    }
    
    // 自機の移動
    // 自機にスクリーン座標は無関係なため、0をダミーで格納する。
    [self.player move:dt ScreenX:0 ScreenY:0];
    DBGLOG(0, @"m_player.abspos=(%f, %f)", self.player.absx, self.player.absy);
    
    // 移動後のスクリーン座標の取得
    scrx = [self.player getScreenPosX];
    scry = [self.player getScreenPosY];
    DBGLOG(0, @"x=%f y=%f", scrx, scry);
    
    // 自機弾の移動
    enumerator = [self.playerShotPool.pool objectEnumerator];
    for (character in enumerator) {
        [character move:dt ScreenX:scrx ScreenY:scry];
        DBGLOG(0 && character.isStaged, @"playerShot.abxpos=(%f, %f)",
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
            DBGLOG(0, @"enemy move start.");
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
        DBGLOG(0 && character.isStaged, @"effect=(%f, %f) player=(%f, %f)",
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
    baseLayer = [self getChildByTag:LAYER_POS_Z_BASELAYER];
    baseLayer.rotation = angle;
    DBGLOG(0, @"m_baseLayer angle=%f", baseLayer.rotation);
    
    // 敵と敵弾がひとつも存在しない場合は次のウェーブ開始までの時間をカウントする
    if (isClear) {
        // 次のウェーブ開始までの時間をカウントする
        m_waveInterval -= dt;
        
        // ウェーブ開始の間隔が経過した場合はウェーブクリア処理を行う
        if (m_waveInterval < 0.0f) {
            
            // ウェーブクリア処理を行う
            [self clearWave];
            
            // ウェーブ間隔をリセットする
            m_waveInterval = WAVE_INTERVAL;
        }
    }
    
    // ゲームオーバーになっていた場合はハイスコアをファイルに書き込む
    // (ゲームオーバーになった時点で書き込みを行わないのはupdateの途中でスコアが変動する可能性があるため)
    if (m_state == GAME_STATE_GAMEOVER) {
        // ハイスコアをファイルに書き込む
        hiScoreFile = [[[AKHiScoreFile alloc] init] autorelease];
        hiScoreFile.hiscore = m_hiScore;
        [hiScoreFile write];
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
    [m_player setVelocityX:vx Y:vy];
}

/*!
 @brief 自機弾の発射

 自機弾を発射する。
 */
- (void)filePlayerShot
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
        DBGLOG(1, @"自機弾プールに空きなし");
        assert(0);
        return;
    }
    
    // 発射する方向は自機の角度に回転速度を加算する
    angle = self.player.angle;
    
    // 自機弾を生成する
    // 位置と向きは自機と同じとする
    [shot createWithX:self.player.absx Y:self.player.absy Z:CHARA_POS_Z_PLAYERSHOT
                Angle:angle Parent:[self getChildByTag:LAYER_POS_Z_BASELAYER]];
}

/*!
 @brief 敵の生成

 敵を生成する。
 @param type 敵の種類
 @param posx 生成位置x座標
 @param posy 生成位置y座標
 @param angle 敵の向き
 */
- (void)entryEnemy:(enum ENEMY_TYPE)type PosX:(NSInteger)posx PosY:(NSInteger)posy Angle:(float)angle
{
    AKEnemy *enemy = nil;     // 敵
    SEL createEnemy = nil;  // 敵生成のメソッド
    
    DBGLOG(0, @"type=%d posx=%d posy=%d angle=%f", type, posx, posy, AKCnvAngleRad2Deg(angle));
    
    // プールから未使用のメモリを取得する
    enemy = [self.enemyPool getNext];
    if (enemy == nil) {
        // 空きがない場合は処理終了
        assert(0);
        DBGLOG(1, @"敵プールに空きなし");
        return;
    }
    
    // 敵の種類によって生成するメソッドを変える
    switch (type) {
        case ENEMY_TYPE_NORMAL:    // 雑魚
            createEnemy = @selector(createNoraml);
            break;
            
        default:        // その他
            // エラー
            assert(0);
            DBGLOG(1, @"不正な敵の種類:%d", type);
            
            // 仮に雑魚を設定
            createEnemy = @selector(createNoraml);
            break;
    }
    
    // 敵を生成する
    [enemy createWithX:posx Y:posy Z:CHARA_POS_Z_ENEMY Angle:angle
                Parent:[self getChildByTag:LAYER_POS_Z_BASELAYER] CreateSel:createEnemy];
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
    
    // 敵弾を生成する
    [enemyShot createWithType:type X:posx Y:posy Z:CHARA_POS_Z_ENEMYSHOT
                        Angle:angle Parent:[self getChildByTag:LAYER_POS_Z_BASELAYER]];
}

/*!
 @brief 画面効果の生成
 
 画面効果を生成する。
 @param particle 画面効果のパーティクル
 @param time 画面効果の生存時間
 @param posx 画面効果の絶対座標x座標
 @param posy 画面効果の絶対座標y座標
 */
- (void)entryEffect:(CCParticleSystem *)particle Time:(float)time PosX:(float)posx PosY:(float)posy
{
    AKEffect *effect = nil;     // 画面効果
    
    // プールから未使用のメモリを取得する
    effect = [self.effectPool getNext];
    if (effect == nil) {
        // 空きがない場合は処理終了
        DBGLOG(1, @"画面効果プールに空きなし");
        assert(0);
        return;
    }
    
    // 画面効果にパーティクルを追加する
    particle.autoRemoveOnFinish = YES;
    particle.position = ccp(0, 0);
    particle.positionType = kCCPositionTypeRelative;
    [effect.image addChild:particle];
    
    DBGLOG(0, @"player=(%f, %f) pos=(%f, %f)", self.player.absx, self.player.absy, posx, posy);
    // 画面効果を生成する
    [effect startEffect:time PosX:posx PosY:posy PosZ:CHARA_POS_Z_EFFECT
                 Parent:[self getChildByTag:LAYER_POS_Z_BASELAYER]];
}

/*!
 @brief 自機破壊時の処理
 
 自機が破壊されたときの処理を行う。残機の数を一つ減らして自機を復活させる。
 残機が0の場合はゲームオーバーとする。
 */
- (void)miss
{
    CCSprite *gameOverSprite = nil;     // ゲームオーバーのスプライト
    
    // 残機が残っている場合は残機を減らして復活する
    if (m_life > 0) {

        // ライフを一つ減らす
        m_life--;
        
        // 残機の表示を更新する
        [self.lifeMark updateImage:m_life];
        
        // 自機復活までの間隔を設定する
        m_rebirthInterval = REBIRTH_INTERVAL;
    }
    // 残機がなければゲームオーバーとする
    else {
        
        // ゲームの状態をゲームオーバーに変更する
        m_state = GAME_STATE_GAMEOVER;
        
        // ゲームオーバーの画像を読み込む
        gameOverSprite = [CCSprite spriteWithFile:@"GameOver.png"];
        gameOverSprite.tag = INFOLAYER_TAG_GAMEOVER;
        [[self getChildByTag:LAYER_POS_Z_INFOLAYER] addChild:gameOverSprite];
        
        // 画面の中心に配置する
        gameOverSprite.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    }
}

/*!
 @brief ゲーム状態リセット
 
 ゲームの状態を初期状態にリセットする。
 */
- (void)resetAll
{
    NSString *scoreString = nil;    // スコアの文字列
    CCLabelTTF *scoreLabel = nil;   // スコアのラベル
    CCNode *infoLayer = nil;       // 情報レイヤー

    // 各種メンバを初期化する
    m_state = GAME_STATE_START;
    m_stageNo = 1;
    m_waveNo = 1;
    m_life = START_LIFE_COUNT;
    m_rebirthInterval = 0.0f;
    m_waveInterval = WAVE_INTERVAL;
    m_score = 0;
    
    // 残機マークの初期個数を反映させる
    [self.lifeMark updateImage:m_life];
    
    // 情報レイヤーを取得する
    infoLayer = [self getChildByTag:LAYER_POS_Z_INFOLAYER];
    
    // ラベルの内容を更新する
    scoreString = [NSString stringWithFormat:SCORE_FORMAT, m_score];
    scoreLabel = (CCLabelTTF *)[infoLayer getChildByTag:INFOLAYER_TAG_SCORE];
    [scoreLabel setString:scoreString];

    // 自機の状態を初期化する
    [self.player reset];

    // 画面上の全キャラクターを削除する
    [self.playerShotPool reset];
    [self.enemyPool reset];
    [self.effectPool reset];
    
    // ゲームオーバーの表示を削除する
    [infoLayer removeChildByTag:INFOLAYER_TAG_GAMEOVER cleanup:YES];
}

/*!
 @brief スコア加算
 
 スコアを加算する。
 */
- (void)addScore:(NSInteger)score
{
    NSString *scoreString = nil;    // スコアの文字列
    NSString *hiScoreString = nil;  // ハイスコアの文字列
    CCLabelTTF *scoreLabel = nil;   // スコアのラベル
    CCLabelTTF *hiScoreLabel = nil; // ハイスコアのラベル
    CCNode *infoLayer = nil;        // 情報レイヤー
    
    // スコアを加算する
    m_score += score;
    
    // 情報レイヤーを取得する
    infoLayer = [self getChildByTag:LAYER_POS_Z_INFOLAYER];
    ;
    // ラベルの内容を更新する
    scoreString = [NSString stringWithFormat:SCORE_FORMAT, m_score];
    scoreLabel = (CCLabelTTF *)[infoLayer getChildByTag:INFOLAYER_TAG_SCORE];
    [scoreLabel setString:scoreString];
    
    // ハイスコアを更新している場合はハイスコアを設定する
    if (m_score > m_hiScore) {
        
        // ハイスコアにスコアの値を設定する
        m_hiScore = m_score;
        
        // ラベルの内容を更新する
        hiScoreString = [NSString stringWithFormat:HISCORE_FORMAT, m_hiScore];
        hiScoreLabel = (CCLabelTTF *)[infoLayer getChildByTag:INFOLAYER_TAG_HISCORE];
        [hiScoreLabel setString:hiScoreString];
    }
}

/*!
 @brief ポーズ
 
 プレイ中の状態からゲームを一時停止する。
 */
- (void)pause
{
    AKCharacter *character = nil;   // キャラクター
    NSEnumerator *enumerator = nil; // キャラクター操作用列挙子
    CCSprite *pauseSprite = nil;    // 一時停止中の画像
    
    // プレイ中から以外の変更の場合はエラー
    assert(m_state == GAME_STATE_PLAYING);
    
    // ゲーム状態を一時停止に変更する
    m_state = GAME_STATE_PUASE;
    
    // すべてのキャラクターのアニメーションを停止する
    // 自機
    [self.player.image pauseSchedulerAndActions];

    // 自機弾
    enumerator = [self.playerShotPool.pool objectEnumerator];
    for (character in enumerator) {
        [character.image pauseSchedulerAndActions];
    }
    
    // 敵
    enumerator = [self.enemyPool.pool objectEnumerator];
    for (character in enumerator) {
        [character.image pauseSchedulerAndActions];
    }

    // 敵弾
    enumerator = [self.enemyShotPool.pool objectEnumerator];
    for (character in enumerator) {
        [character.image pauseSchedulerAndActions];
    }

    // 画面効果
    enumerator = [self.effectPool.pool objectEnumerator];
    for (character in enumerator) {
        [character.image pauseSchedulerAndActions];
    }
    
    // 一時停止中の画像を読み込む
    pauseSprite = [CCSprite spriteWithFile:@"Pause.png"];
    pauseSprite.tag = INFOLAYER_TAG_PAUSE;

    // 画面の中心に配置する
    pauseSprite.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    
    // 情報レイヤーに配置する
    [[self getChildByTag:LAYER_POS_Z_INFOLAYER] addChild:pauseSprite];
    
}

/*!
 @brief ゲーム再開
 
 一時停止中の状態からゲームを再会する。
 */
- (void)resume
{
    AKCharacter *character = nil;   // キャラクター
    NSEnumerator *enumerator = nil; // キャラクター操作用列挙子
    
    // 一時停止中から以外の変更の場合はエラー
    assert(m_state == GAME_STATE_PUASE);

    // ゲーム状態をプレイ中に変更する
    m_state = GAME_STATE_PLAYING;
    
    // すべてのキャラクターのアニメーションを再開する
    // 自機
    [self.player.image resumeSchedulerAndActions];

    // 自機弾
    enumerator = [self.playerShotPool.pool objectEnumerator];
    for (character in enumerator) {
        [character.image resumeSchedulerAndActions];
    }

    // 敵
    enumerator = [self.enemyPool.pool objectEnumerator];
    for (character in enumerator) {
        [character.image resumeSchedulerAndActions];
    }

    // 敵弾
    enumerator = [self.enemyShotPool.pool objectEnumerator];
    for (character in enumerator) {
        [character.image resumeSchedulerAndActions];
    }

    // 画面効果
    enumerator = [self.effectPool.pool objectEnumerator];
    for (character in enumerator) {
        [character.image resumeSchedulerAndActions];
    }
    
    // 一時停止中の画像を取り除く
    [[self getChildByTag:LAYER_POS_Z_INFOLAYER] removeChildByTag:INFOLAYER_TAG_PAUSE cleanup:YES];
}

/*!
 @brief スクリプト読込
 
 ステージ構成のスクリプトファイルを読み込んで敵を配置する。
 @param stage ステージ番号
 @param wave ウェーブ番号
 */
- (void)readScriptOfStage:(NSInteger)stage Wave:(NSInteger)wave
{
    NSRange lineRange = {0};        // 処理対象の行の範囲
    NSString *fileName = nil;       // ステージ定義ファイルのファイル名
    NSString *filePath = nil;       // ステージ定義ファイルのパス
    NSString *stageScript = nil;    // ステージ定義ファイルの内容
    NSString *line = nil;           // 処理対象の行の文字列
    NSError *error = nil;           // ファイル読み込みエラー内容
    NSBundle *bundle = nil;         // バンドル
    NSArray *params = nil;          // ステージ定義ファイルの1行のパラメータ
    NSString *param = nil;          // ステージ定義ファイルの1個のパラメータ
    enum ENEMY_TYPE enemyType = 0;  // 敵の種類
    NSInteger enemyPosX = 0;        // 敵の配置位置x座標
    NSInteger enemyPosY = 0;        // 敵の配置位置y座標
    float enemyAngle = 0.0f;        // 敵の向き
    
    // ファイル名をステージ番号、ウェイブ番号から決定する
    fileName = [NSString stringWithFormat:@"stage%d_%d", stage, wave];
    DBGLOG(0, @"fileName=%@", fileName);
    
    // ファイルパスをバンドルから取得する
    bundle = [NSBundle mainBundle];
    filePath = [bundle pathForResource:fileName ofType:@"txt"];
    DBGLOG(0, @"filePath=%@", filePath);
    
    // ステージ定義ファイルを読み込む
    stageScript = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding
                                               error:&error];
    // ファイル読み込みエラー
    if (stageScript == nil && error != nil) {
        DBGLOG(0, @"%@", [error localizedDescription]);
    }
    
    // ステージ定義ファイルの範囲の間は処理を続ける
    while (lineRange.location < stageScript.length) {
        
        // 1行の範囲を取得する
        lineRange = [stageScript lineRangeForRange:lineRange];
        
        // 1行の文字列を取得する
        line = [stageScript substringWithRange:lineRange];
        DBGLOG(0, @"%@", line);
        
        // 1文字目が"#"の場合は処理を飛ばす
        if ([[line substringToIndex:1] isEqualToString:@"#"]) {
            DBGLOG(0, @"コメント:%@", line);
        }
        // コメントでない場合はパラメータを読み込む
        else {
            // カンマ区切りでパラメータを分割する
            params = [line componentsSeparatedByString:@","];
            
            // 1個目のパラメータは敵の種類として扱う。
            param = [params objectAtIndex:0];
            enemyType = [param integerValue];
            
            // 敵の種類は0始まりとするため、-1する。
            enemyType--;
            
            // 2個目のパラメータはx座標として扱う
            param = [params objectAtIndex:1];
            enemyPosX = [param integerValue];
            
            // 3個目のパラメータはy座標として扱う
            param = [params objectAtIndex:2];
            enemyPosY = [param integerValue];
            
            DBGLOG(0, @"type=%d posx=%d posy=%d", enemyType, enemyPosX, enemyPosY);
            
            // 角度を自機のいる位置に設定する
            // スクリプト上の座標は自機の位置からの相対位置なので目標座標は(0, 0)
            enemyAngle = AKCalcDestAngle(enemyPosX, enemyPosY, 0, 0);
            
            DBGLOG(0, @"angle=%f", AKCnvAngleRad2Deg(enemyAngle));
            
            // 生成位置は自機の位置からの相対位置とする
            enemyPosX += m_player.absx;
            enemyPosY += m_player.absy;
            
            // 敵を生成する
            [self entryEnemy:(enum ENEMY_TYPE)enemyType PosX:enemyPosX PosY:enemyPosY Angle:enemyAngle];
        }
        
        // 次の行へ処理を進める
        lineRange.location = lineRange.location + lineRange.length;
        lineRange.length = 0;
    }
}

/*!
 @brief ウェーブクリア
 
 ウェーブクリア時の処理。次のウェーブのスクリプトを読み込む。
 すべてのウェーブをクリアしている場合はステージクリア画面を表示する。
 */
- (void)clearWave
{
    AKResultLayer *resultLayer = nil;   // ステージクリア結果画面
    
    // ウェーブを進める
    m_waveNo++;
    
    // ステージのウェーブ個数を超えている場合はステージクリア
    if (m_waveNo > WAVE_COUNT) {
        
        // 状態をゲームクリアに移行する
        m_state = GAME_STATE_CLEAR;
        
        // 結果画面を生成する
        resultLayer = [AKResultLayer node];
        resultLayer.tag = LAYER_POS_Z_RESULTLAYER;
        [self addChild:resultLayer z:LAYER_POS_Z_RESULTLAYER];
        
        // 各種パラメータを設定する
        [resultLayer setScore:m_score andTime:100 andHit:50 andRest:m_life];
    }
    // ステージクリアでない場合は次のウェーブのスクリプトを読み込む
    else {
        [self readScriptOfStage:m_stageNo Wave:m_waveNo];
    }
}

/*!
 @brief ステージクリア結果スキップ
 
 ステージクリア画面の表示更新をスキップする。
 すてに表示が完了している場合は次のステージを開始する。
 */
- (void)skipResult
{
    AKResultLayer *resultLayer = nil;   // ステージクリア結果画面
    
    // ステージクリア結果画面を取得する
    resultLayer = (AKResultLayer *)[self getChildByTag:LAYER_POS_Z_RESULTLAYER];
    
    // ステージクリア画面の表示が完了している場合は次のステージを開始する
    if (resultLayer.isFinish) {
        [self clearStage];
    }
    // ステージクリア画面の表示が完了していない場合は強制的に進める
    else {
        [resultLayer finish];
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
    NSString *scoreString = nil;    // スコアの文字列
    NSString *hiScoreString = nil;  // ハイスコアの文字列
    CCLabelTTF *scoreLabel = nil;   // スコアのラベル
    CCLabelTTF *hiScoreLabel = nil; // ハイスコアのラベル
    CCNode *infoLayer = nil;        // 情報レイヤー
    
    // ステージ番号を進める
    m_stageNo++;
    
    // ステージクリア結果画面を削除する
    [self removeChildByTag:LAYER_POS_Z_RESULTLAYER cleanup:YES];
    
    // まだ全ステージをクリアしていない場合は次のステージを開始する
    if (m_stageNo < STAGE_COUNT) {
        
        // ゲームの状態をプレイ中に変更する
        m_state = GAME_STATE_PLAYING;
        
        // ウェーブ番号を初期化する
        m_waveNo = 1;
    
        // 自機復活までのインターバルを初期化する
        m_rebirthInterval = 0.0f;

        // 残機マークを更新する
        [self.lifeMark updateImage:m_life];

        // 情報レイヤーを取得する
        infoLayer = [self getChildByTag:LAYER_POS_Z_INFOLAYER];

        // スコアラベルの内容を更新する
        scoreString = [NSString stringWithFormat:SCORE_FORMAT, m_score];
        scoreLabel = (CCLabelTTF *)[infoLayer getChildByTag:INFOLAYER_TAG_SCORE];
        [scoreLabel setString:scoreString];
        
        // ハイスコアラベルの内容を更新する
        hiScoreString = [NSString stringWithFormat:HISCORE_FORMAT, m_hiScore];
        hiScoreLabel = (CCLabelTTF *)[infoLayer getChildByTag:INFOLAYER_TAG_HISCORE];
        [hiScoreLabel setString:hiScoreString];
        
        // 自機の状態を初期化する
        [self.player reset];
        
        // 画面上の全キャラクターを削除する
        [self.playerShotPool reset];
        [self.enemyPool reset];
        [self.effectPool reset];
        
        // 次のステージのスクリプトを読み込む
        [self readScriptOfStage:m_stageNo Wave:m_waveNo];
    }
    // 全ステージクリアしている場合はエンディング画面の表示を行う
    else {
        // [TODO] 全ステージクリア処理を実装する
    }
    
}
@end
