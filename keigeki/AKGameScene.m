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

/// 情報レイヤーに配置するノードのタグ
enum {
    kAKInfoTagPause1 = 0,   ///< 一時停止(1行目)
    kAKInfoTagPause2,       ///< 一時停止(2行目)
    kAKInfoTagGameClear,    ///< ゲームクリア
    kAKInfoTagGameOver,     ///< ゲームオーバー
    kAKInfoTagScore,        ///< スコア
    kAKInfoTagHiScore,      ///< ハイスコア
    kAKInfoTagHit,          ///< 命中率
    kAKInfoTagTime          ///< プレイ時間
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
static const NSInteger kAKStartLifeCount = 3;
/// 自機復活までの間隔
static const float kAKRebirthInterval = 1.0f;

/// 1ステージのウェイブの数
static const NSInteger kAKWaveCount = 10;
/// ステージの数
static const NSInteger kAKStageCount = 5;
/// ウェイブが始まるまでの間隔
static const float kAKWaveInterval = 2.0f;

/// スコアの表示位置
static const CGPoint kAKScorePos = {10, 300};
/// ハイスコアの表示位置
static const CGPoint kAKHiScorePos = {240, 300};
/// 命中率の表示位置
static const CGPoint kAKHitPos = {10, 280};
/// プレイ時間の表示位置
static const CGPoint kAKTimePos = {200, 280};
/// 一時停止メッセージの表示位置(1行目)
static const CGPoint kAKPauseMessagePos1 = {240, 200};
/// 一時停止メッセージの表示位置(2行目)
static const CGPoint kAKPauseMessagePos2 = {240, 150};

/// ゲームクリア画面の画像ファイル名
static NSString *kAKGameClearImageFile = @"GameClear.png";

/// スコア表示のフォーマット
static NSString *kAKScoreFormat = @"SCORE:%08d";
/// ハイスコア表示のフォーマット
static NSString *kAKHiScoreFormat = @"HI:%08d";
/// 命中率表示のフォーマット
static NSString *kAKHitFormat = @"HIT:%3d%%";
/// プレイ時間のフォーマット
static NSString *kAKTimeFormat = @"TIME:%02d:%02d:%02d";
/// ハイスコアファイル名
static NSString *kAKDataFileName = @"hiscore.dat";
/// ハイスコアファイルのエンコードキー名
static NSString *kAKDataFileKey = @"hiScoreData";

/// 一時停止中の表示文字列(1行目)
static NSString *kAKPauseString1 = @"PAUSE";
/// 一時停止中の表示文字列(2行目)
static NSString *kAKPauseString2 = @"TOUCH SCREEN TO RESUME.";

/// ゲームオーバー時の表示文字列
static NSString *kAKGameOverString = @"GAME OVER";
/// ゲームクリア時の表示文字列
static NSString *kAKGameClearString = @"GAME CLEAR";

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
@synthesize shotCount = m_shotCount;
@synthesize hitCount = m_hitCount;

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
 @brief オブジェクト生成処理
 
 オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
        
    // キャラクターを配置するレイヤーを生成する
    CCLayer *baseLayer = [CCLayer node];
    baseLayer.tag = kAKLayerPosZBase;
    [self addChild:baseLayer z:kAKLayerPosZBase];
    
    // 画面回転時の中心点を求める
    // CCLayerのサイズは320x480だが、画面サイズはLandscape時は480x320のため、
    // 画面右上の点が(480 / 320, 320 / 480)となる。
    // 中心点座標のCCLayer上での比率に上の値をかけて、画面上での比率を求める。
    float anchor_x = ((float)kAKPlayerPos.x / kAKScreenSize.width) * ((float)kAKScreenSize.width / kAKScreenSize.height);
    float anchor_y = ((float)kAKPlayerPos.y / kAKScreenSize.height) * ((float)kAKScreenSize.height / kAKScreenSize.width);
    
    // 画面回転時の中心点を設定する
    baseLayer.anchorPoint = ccp(anchor_x, anchor_y);
    
    // キャラクター以外の情報を配置するレイヤーを生成する
    CCLayer *infoLayer = [CCLayer node];
    infoLayer.tag = kAKLayerPosZInfo;
    [self addChild:infoLayer z:kAKLayerPosZInfo];
    
    // インターフェースレイヤーを貼り付ける
    AKGameIFLayer *interface = [AKGameIFLayer node];
    [self addChild:interface z:kAKLayerPosZInterface];
    
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
    
    {
        // ショットボタンの画像を読み込む
        CCSprite *shotButton = [CCSprite spriteWithFile:@"ShotButton.png"];
        assert(shotButton != nil);
        
        // ショットボタンの位置を設定する
        shotButton.position = ccp(kAKShotButtonPos.x, kAKShotButtonPos.y);
        
        // ショットボタンをレイヤーに配置する
        [infoLayer addChild:shotButton];
    }

    {
        // ポーズボタンの画像を読み込む
        CCSprite *pauseButton = [CCSprite spriteWithFile:@"PauseButton.png"];
        assert(pauseButton != nil);
        
        // ポーズボタンの位置を設定する
        pauseButton.position = ccp(kAKPauseButtonPos.x, kAKPauseButtonPos.y);
        
        // ポーズボタンをレイヤーに配置する
        [infoLayer addChild:pauseButton];
    }
    
    // レーダーの生成
    self.rader = [AKRadar node];
    
    // レーダーをレイヤーに配置する
    [infoLayer addChild:self.rader];
    
    // 残機マークの生成
    self.lifeMark = [AKLifeMark node];
    
    // 残機マークをレイヤーに配置する
    [infoLayer addChild:self.lifeMark];
    
    // スコアラベルを生成する
    [self setLabelToInfoLayer:[NSString stringWithFormat:kAKScoreFormat, m_score]
                        atPos:kAKScorePos tag:kAKInfoTagScore isCenter:NO];
    
    // ハイスコアファイルの読み込みを行う
    [self readHiScore];

    // ハイスコアラベルを生成する
    [self setLabelToInfoLayer:[NSString stringWithFormat:kAKHiScoreFormat, m_hiScore]
                        atPos:kAKHiScorePos tag:kAKInfoTagHiScore isCenter:NO];
        
    // 命中率ラベルを生成する
    [self setLabelToInfoLayer:[NSString stringWithFormat:kAKHitFormat, 100]
                        atPos:kAKHitPos tag:kAKInfoTagHit isCenter:NO];

    // プレイ時間ラベルを生成する
    [self setLabelToInfoLayer:[NSString stringWithFormat:kAKTimeFormat, 0, 0, 0]
                        atPos:kAKTimePos tag:kAKInfoTagTime isCenter:NO];

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
        case kAKGameStateStart:      // ゲーム開始時
            [self updateStart:dt];
            break;
            
        case kAKGameStatePlaying:    // プレイ中
            [self updatePlaying:dt];
            break;
            
        case kAKGameClear:      // クリア
        {
            // ステージクリア画面を取得し、更新を行う
            AKResultLayer *result = (AKResultLayer *)[self getChildByTag:kAKLayerPosZResult];
            [result updateCalc:dt];
        }
            break;
            
        case kAKGameStateGameOver:   // ゲームオーバー
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
    m_state = kAKGameStatePlaying;
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
    baseLayer = [self getChildByTag:kAKLayerPosZBase];
    baseLayer.rotation = angle;
    DBGLOG(0, @"m_baseLayer angle=%f", baseLayer.rotation);
    
    // 命中率の表示を更新する
    [self updateHit];
    
    // プレイ時間を更新する
    m_playTime += dt;
    [self updateTime];
    
    // 敵と敵弾がひとつも存在しない場合は次のウェーブ開始までの時間をカウントする
    if (isClear) {
        // 次のウェーブ開始までの時間をカウントする
        m_waveInterval -= dt;
        
        // ウェーブ開始の間隔が経過した場合はウェーブクリア処理を行う
        if (m_waveInterval < 0.0f) {
            
            // ウェーブクリア処理を行う
            [self clearWave];
            
            // ウェーブ間隔をリセットする
            m_waveInterval = kAKWaveInterval;
        }
    }
    
    // ゲームオーバーになっていた場合はハイスコアをファイルに書き込む
    // (ゲームオーバーになった時点で書き込みを行わないのはupdateの途中でスコアが変動する可能性があるため)
    if (m_state == kAKGameStateGameOver) {
        // ハイスコアをファイルに書き込む
        [self writeHiScore];
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
        DBGLOG(1, @"自機弾プールに空きなし");
        assert(0);
        return;
    }
    
    // 発射する方向は自機の角度に回転速度を加算する
    angle = self.player.angle;
    
    // 初回の移動更新処理が終わるまでは非表示とする
    shot.image.visible = NO;
    
    // 自機弾を生成する
    // 位置と向きは自機と同じとする
    [shot createWithX:self.player.absx Y:self.player.absy Z:kAKCharaPosZPlayerShot
                Angle:angle Parent:[self getChildByTag:kAKLayerPosZBase]];
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
        case kAKEnemyTypeNormal:    // 雑魚
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
    
    // 初回の移動更新処理が終わるまでは非表示とする
    enemy.image.visible = NO;
    
    // 敵を生成する
    [enemy createWithX:posx Y:posy Z:kAKCharaPosZEnemy Angle:angle
                Parent:[self getChildByTag:kAKLayerPosZBase] CreateSel:createEnemy];
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
    
    // 初回の移動更新処理が行われるまでは非表示とする
    enemyShot.image.visible = NO;
    
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
    if (m_life > 0) {

        // ライフを一つ減らす
        m_life--;
        
        // 残機の表示を更新する
        [self.lifeMark updateImage:m_life];
        
        // 自機復活までの間隔を設定する
        m_rebirthInterval = kAKRebirthInterval;
    }
    // 残機がなければゲームオーバーとする
    else {
        
        // ゲームの状態をゲームオーバーに変更する
        m_state = kAKGameStateGameOver;
        
        // ゲームオーバーのラベルを生成する
        [self setLabelToInfoLayer:kAKGameOverString atPos:ccp(kAKScreenSize.width / 2, kAKScreenSize.height / 2)
                              tag:kAKInfoTagGameOver isCenter:YES];
    }
}

/*!
 @brief ゲーム状態リセット
 
 ゲームの状態を初期状態にリセットする。
 */
- (void)resetAll
{
    // 各種メンバを初期化する
    m_state = kAKGameStateStart;
    m_stageNo = 1;
    m_waveNo = 1;
    m_life = kAKStartLifeCount;
    m_rebirthInterval = 0.0f;
    m_waveInterval = kAKWaveInterval;
    m_score = 0;
    m_shotCount = 0;
    m_hitCount = 0;
    m_playTime = 0.0f;
    
    // 残機マークの初期個数を反映させる
    [self.lifeMark updateImage:m_life];
    
    // 情報レイヤーを取得する
    CCNode *infoLayer = [self getChildByTag:kAKLayerPosZInfo];
    
    // ラベルの内容を更新する
    NSString *scoreString = [NSString stringWithFormat:kAKScoreFormat, m_score];
    AKLabel *scoreLabel = (AKLabel *)[infoLayer getChildByTag:kAKInfoTagScore];
    [scoreLabel setString:scoreString];

    // 自機の状態を初期化する
    [self.player reset];

    // 画面上の全キャラクターを削除する
    [self.playerShotPool reset];
    [self.enemyPool reset];
    [self.effectPool reset];
    
    // ゲームオーバーの表示を削除する
    [infoLayer removeChildByTag:kAKInfoTagGameOver cleanup:YES];
    
    // ゲームクリアの表示を削除する
    [infoLayer removeChildByTag:kAKInfoTagGameClear cleanup:YES];
}

/*!
 @brief スコア加算
 
 スコアを加算する。
 */
- (void)addScore:(NSInteger)score
{    
    // スコアを加算する
    m_score += score;
    
    // 情報レイヤーを取得する
    CCNode *infoLayer = [self getChildByTag:kAKLayerPosZInfo];
    
    // ラベルの内容を更新する
    NSString *scoreString = [NSString stringWithFormat:kAKScoreFormat, m_score];
    AKLabel *scoreLabel = (AKLabel *)[infoLayer getChildByTag:kAKInfoTagScore];
    [scoreLabel setString:scoreString];
    
    // ハイスコアを更新している場合はハイスコアを設定する
    if (m_score > m_hiScore) {
        
        // ハイスコアにスコアの値を設定する
        m_hiScore = m_score;
        
        // ラベルの内容を更新する
        NSString *hiScoreString = [NSString stringWithFormat:kAKHiScoreFormat, m_hiScore];
        AKLabel *hiScoreLabel = (AKLabel *)[infoLayer getChildByTag:kAKInfoTagHiScore];
        [hiScoreLabel setString:hiScoreString];
    }
}

/*!
 @brief ポーズ
 
 プレイ中の状態からゲームを一時停止する。
 */
- (void)pause
{
    // プレイ中から以外の変更の場合はエラー
    assert(m_state == kAKGameStatePlaying);
    
    // ゲーム状態を一時停止に変更する
    m_state = kAKGameStatePause;
    
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
    
    // 一時停止中のラベルを作成する(1行目)
    [self setLabelToInfoLayer:kAKPauseString1 atPos:kAKPauseMessagePos1 tag:kAKInfoTagPause1 isCenter:YES];
    
    // 一時停止中のラベルを作成する(2行目)
    [self setLabelToInfoLayer:kAKPauseString2 atPos:kAKPauseMessagePos2 tag:kAKInfoTagPause2 isCenter:YES];
}

/*!
 @brief ゲーム再開
 
 一時停止中の状態からゲームを再会する。
 */
- (void)resume
{    
    // 一時停止中から以外の変更の場合はエラー
    assert(m_state == kAKGameStatePause);

    // ゲーム状態をプレイ中に変更する
    m_state = kAKGameStatePlaying;
    
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
    
    // 一時停止中のラベルを取り除く
    [[self getChildByTag:kAKLayerPosZInfo] removeChildByTag:kAKInfoTagPause1 cleanup:YES];
    [[self getChildByTag:kAKLayerPosZInfo] removeChildByTag:kAKInfoTagPause2 cleanup:YES];
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
    enum AKEnemyType enemyType = 0;  // 敵の種類
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
            [self entryEnemy:(enum AKEnemyType)enemyType PosX:enemyPosX PosY:enemyPosY Angle:enemyAngle];
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
    // ウェーブを進める
    m_waveNo++;
    
    // ステージのウェーブ個数を超えている場合はステージクリア
    if (m_waveNo > kAKWaveCount) {
        
        // 状態をゲームクリアに移行する
        m_state = kAKGameClear;
        
        // 結果画面を生成する
        AKResultLayer *resultLayer = [AKResultLayer node];
        resultLayer.tag = kAKLayerPosZResult;
        [self addChild:resultLayer z:kAKLayerPosZResult];
        
        // 命中率を計算する。1発も発射していない場合は100%とする。
        NSInteger hit = 0;
        if (m_shotCount == 0) {
            hit = 100;
        }
        else {
            hit = (float)m_hitCount / m_shotCount * 100.0f;
        }
        
        // 各種パラメータを設定する
        [resultLayer setScore:m_score andTime:(NSInteger)m_playTime andHit:hit andRest:m_life];
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
    resultLayer = (AKResultLayer *)[self getChildByTag:kAKLayerPosZResult];
    
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
    // ステージ番号を進める
    m_stageNo++;
    
    // ステージクリア結果画面を削除する
    [self removeChildByTag:kAKLayerPosZResult cleanup:YES];
    
    // まだ全ステージをクリアしていない場合は次のステージを開始する
    if (m_stageNo < kAKStageCount) {
        
        // ゲームの状態をプレイ中に変更する
        m_state = kAKGameStatePlaying;
        
        // ウェーブ番号を初期化する
        m_waveNo = 1;
    
        // 自機復活までのインターバルを初期化する
        m_rebirthInterval = 0.0f;
        
        // 命中率を初期化する
        m_shotCount = 0;
        m_hitCount = 0;
        
        // ステージのプレイ時間を初期化する
        m_playTime = 0.0f;

        // 残機マークを更新する
        [self.lifeMark updateImage:m_life];

        // 情報レイヤーを取得する
        CCNode *infoLayer = [self getChildByTag:kAKLayerPosZInfo];

        // スコアラベルの内容を更新する
        {
            NSString *scoreString = [NSString stringWithFormat:kAKScoreFormat, m_score];
            AKLabel *scoreLabel = (AKLabel *)[infoLayer getChildByTag:kAKInfoTagScore];
            [scoreLabel setString:scoreString];
        }
        
        // ハイスコアラベルの内容を更新する
        {
            NSString *hiScoreString = [NSString stringWithFormat:kAKHiScoreFormat, m_hiScore];
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
        [self readScriptOfStage:m_stageNo Wave:m_waveNo];
    }
    // 全ステージクリアしている場合はエンディング画面の表示を行う
    else {
        
        // ゲームの状態をゲームオーバーに変更する
        m_state = kAKGameStateGameOver;
        
        // 背景画像を読み込む
        CCSprite *back = [CCSprite spriteWithFile:kAKBaseColorImage];
        
        // タグを設定する
        back.tag = kAKInfoTagGameClear;
        
        // 表示位置を設定する
        back.position = ccp(kAKScreenSize.width / 2, kAKScreenSize.height / 2);

        // ゲームクリアのラベルを作成する
        AKLabel *label = [AKLabel labelWithString:kAKGameClearString maxLength:kAKGameClearString.length maxLine:1];
        
        // 表示位置を設定する
        label.position = ccp((kAKScreenSize.width - label.width) / 2, kAKScreenSize.height / 2);
        
        // ラベルを背景画像に貼り付ける
        [back addChild:label];

        // 情報レイヤーへ配置する
        [[self getChildByTag:kAKLayerPosZInfo] addChild:back];
    }
}

/*!
 @brief ハイスコアファイルの読込
 
 ハイスコアファイルを読み込む。
 */
- (void)readHiScore
{
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
        m_hiScore = hiScore.hiscore;
    }
}

/*!
 @brief ハイスコアファイルの書込
 
 ハイスコアファイルを書き込む。
 */
- (void)writeHiScore
{
    // HOMEディレクトリのパスを取得する
    NSString *homeDir = NSHomeDirectory();
    
    // Documentsディレクトリへのパスを作成する
    NSString *docDir = [homeDir stringByAppendingPathComponent:@"Documents"];
    
    // ファイルパスを作成する
    NSString *filePath = [docDir stringByAppendingPathComponent:kAKDataFileName];
    
    // ハイスコアファイルオブジェクトを生成する
    AKHiScoreFile *hiScore = [[[AKHiScoreFile alloc] init] autorelease];
    
    // ハイスコアを設定する
    hiScore.hiscore = m_hiScore;
    
    // エンコーダーを生成する
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *encoder = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    
    // ファイル内容をエンコードする
    [encoder encodeObject:hiScore forKey:kAKDataFileKey];
    
    // エンコードを完了する
    [encoder finishEncoding];
    
    // ファイルを書き込む
    [data writeToFile:filePath atomically:YES];
}

/*!
 @brief 命中率更新
 
 命中率のラベルを更新する。
 */
- (void)updateHit
{
    // 命中率を計算する。1発も発射していない場合は100%とする。
    NSInteger hit = 0;
    if (m_shotCount == 0) {
        hit = 100;
    }
    else {
        hit = (float)m_hitCount / m_shotCount * 100.0f;
    }
    DBGLOG(0, @"hitCount=%d shotCount=%d hit=%d", m_hitCount, m_shotCount, hit);
    
    // 情報レイヤーを取得する
    CCNode *infoLayer = [self getChildByTag:kAKLayerPosZInfo];
    
    // 命中率ラベルを取得する
    AKLabel *hitLabel = (AKLabel *)[infoLayer getChildByTag:kAKInfoTagHit];
    
    // 命中率ラベルを更新する
    NSString *hitString = [NSString stringWithFormat:kAKHitFormat, hit];
    [hitLabel setString:hitString];
    
    DBGLOG(0, @"str=%@", hitString);
}

/*!
 @brief プレイ時間更新
 
 プレイ時間のラベルを更新する。
 */
- (void)updateTime
{
    // プレイ時間を分、秒、ミリ秒に分割する
    // 分を計算する
    NSInteger min = ((NSInteger)m_playTime) / 60;
    
    // 秒を計算する
    NSInteger sec = ((NSInteger)m_playTime) % 60;
    
    // ミリ秒を計算する
    NSInteger millisec = ((NSInteger)(m_playTime * 100.0f)) % 100;
    
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
 @param isCenter 中央揃えをするかどうか
 */
- (void)setLabelToInfoLayer:(NSString *)str atPos:(CGPoint)pos tag:(NSInteger)tag isCenter:(BOOL)isCenter
{
    // ラベルを生成する
    AKLabel *label = [AKLabel labelWithString:str maxLength:str.length maxLine:1];
    
    // タグを設定する
    label.tag = tag;
    
    // 中央揃えをする場合は位置を半分左にずらす
    if (isCenter) {
        pos.x -= label.width / 2;
    }
    
    // 表示位置を設定する
    label.position = pos;
    
    // 情報レイヤーに配置する
    [[self getChildByTag:kAKLayerPosZInfo] addChild:label];
}
@end
