/*!
 @file AKGameScene.m
 @brief ゲームプレイシーンクラス定義
 
 ゲームプレイのメインのシーンを管理するクラスを定義する。
 */

#import "AKGameScene.h"
#import "AKPlayerShot.h"
#import "AKEnemy.h"
#import "AKEffect.h"

/*!
 @brief ゲームプレイシーン
 
 ゲームプレイのメインのシーンを管理する。
 */
@implementation AKGameScene

// シングルトンオブジェクト
static AKGameScene *g_scene = nil;

@synthesize state = m_state;
@synthesize baseLayer = m_baseLayer;
@synthesize infoLayer = m_infoLayer;
@synthesize interface = m_interface;
@synthesize background = m_background;
@synthesize player = m_player;
@synthesize playerShotPool = m_playerShotPool;
@synthesize enemyPool = m_enemyPool;
@synthesize rader = m_radar;
@synthesize effectPool = m_effectPool;
@synthesize lifeMark = m_lifeMark;
@synthesize scoreLabel = m_scoreLabel;

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
    
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // キャラクターを配置するレイヤーを生成する
    self.baseLayer = [CCLayer node];
    [self addChild:self.baseLayer z:0];
    
    // 画面回転時の中心点を求める
    // CCLayerのサイズは320x480だが、画面サイズはLandscape時は480x320のため、
    // 画面右上の点が(480 / 320, 320 / 480)となる。
    // 中心点座標のCCLayer上での比率に上の値をかけて、画面上での比率を求める。
    anchor_x = ((float)PLAYER_POS_X / SCREEN_WIDTH) * ((float)SCREEN_WIDTH / SCREEN_HEIGHT);
    anchor_y = ((float)PLAYER_POS_Y / SCREEN_HEIGHT) * ((float)SCREEN_HEIGHT / SCREEN_WIDTH);
    
    // 画面回転時の中心点を設定する
    self.baseLayer.anchorPoint = ccp(anchor_x, anchor_y);
    
    // キャラクター以外の情報を配置するレイヤーを生成する
    self.infoLayer = [CCLayer node];
    [self addChild:self.infoLayer z:1];
    
    // インターフェースレイヤーを貼り付ける
    self.interface = [AKGameIFLayer node];
    [self addChild:self.interface z:2];
    
    // 背景の生成
    self.background = [AKBackground node];
    [self.baseLayer addChild:self.background z:1];
    
    // 自機の生成
    self.player = [AKPlayer node];
    [self.background addChild:self.player z:PLAYER_POS_Z];
    
    // 自機弾プールの生成
    self.playerShotPool = [[[AKCharacterPool alloc] initWithClass:[AKPlayerShot class]
                                                             Size:MAX_PLAYER_SHOT_COUNT] autorelease];
    
    // 敵プールの生成
    self.enemyPool = [[[AKCharacterPool alloc] initWithClass:[AKEnemy class]
                                                        Size:MAX_ENEMY_COUNT] autorelease];

    // 画面効果プールの生成
    self.effectPool = [[[AKCharacterPool alloc] initWithClass:[AKEffect class]
                                                         Size:MAX_EFFECT_COUNT] autorelease];
    
    // レーダーの生成
    self.rader = [AKRadar node];
    
    // レーダーをレイヤーに配置する
    [self.infoLayer addChild:self.rader];
    
    // 残機マークの生成
    self.lifeMark = [AKLifeMark node];
    
    // 残機マークをレイヤーに配置する
    [self.infoLayer addChild:self.lifeMark];
    
    // スコアラベルを生成する
    self.scoreLabel = [CCLabelTTF labelWithString:@"SCORE:00000000" fontName:@"Helvetica" fontSize:22];
    self.scoreLabel.position = ccp(SCORE_POS_X, SCORE_POS_Y);
    [self.infoLayer addChild:self.scoreLabel];

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
    self.effectPool = nil;
    self.gameOverImage = nil;
    [self.background removeAllChildrenWithCleanup:YES];
    [self.infoLayer removeAllChildrenWithCleanup:YES];
    [self.baseLayer removeAllChildrenWithCleanup:YES];
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
    fileName = [NSString stringWithFormat:@"stage%d_%d", m_stageNo, m_waveNo];
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
    
    // 敵の移動
    enumerator = [self.enemyPool.pool objectEnumerator];
    for (character in enumerator) {
        DBGLOG(0 && character.isStaged, @"enemy move start.");
        [character move:dt ScreenX:scrx ScreenY:scry];
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
    }
    
    // 画面効果の移動
    enumerator = [self.effectPool.pool objectEnumerator];
    for (character in enumerator) {
        [character move:dt ScreenX:scrx ScreenY:scry];
        DBGLOG(0 && character.isStaged, @"effect=(%f, %f) player=(%f, %f)", character.position.x,
               character.position.y, self.player.position.x, self.player.position.y);
    }
    
    // 背景の移動
    [self.background moveWithScreenX:scrx ScreenY:scry];
    
    // レーダーの更新
    [self.rader updateMarker:self.enemyPool.pool ScreenAngle:self.player.angle];
    
    // 自機の向きの取得
    // 自機の向きと反対方向に画面を回転させるため、符号反転
    angle = -1 * AKCnvAngleRad2Scr(self.player.angle);
    
    // 画面の回転
    self.baseLayer.rotation = angle;
    DBGLOG(0, @"m_baseLayer angle=%f", self.baseLayer.rotation);
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
    shot = [m_playerShotPool getNext];
    if (shot == nil) {
        // 空きがない場合は処理終了
        DBGLOG(1, @"自機弾プールに空きなし");
        assert(0);
        return;
    }
    
    // 発射する方向は自機の角度に回転速度を加算する
    angle = m_player.angle;
    
    // 自機弾を生成する
    // 位置と向きは自機と同じとする
    [shot createWithX:m_player.absx Y:m_player.absy Z:PLAYER_SHOT_POS_Z
                Angle:angle Parent:m_background];
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
    enemy = [m_enemyPool getNext];
    if (enemy == nil) {
        // 空きがない場合は処理終了
        assert(0);
        DBGLOG(1, @"敵プールに空きなし");
        return;
    }
    
    // 敵の種類によって生成するメソッドを変える
    switch (type) {
        case NORMAL:    // 雑魚
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
    [enemy createWithX:posx Y:posy Z:ENEMY_POS_Z Angle:angle
                Parent:m_background CreateSel:createEnemy];
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
    [effect addChild:particle];
    
    DBGLOG(0, @"player=(%f, %f) pos=(%f, %f)", self.player.absx, self.player.absy, posx, posy);
    // 画面効果を生成する
    [effect startEffect:time PosX:posx PosY:posy PosZ:EFFECT_POS_Z Parent:m_background];
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
        m_rebirthInterval = REBIRTH_INTERVAL;
    }
    // 残機がなければゲームオーバーとする
    else {
        
        // ゲームの状態をゲームオーバーに変更する
        m_state = GAME_STATE_GAMEOVER;
        
        // ゲームオーバーの画像を読み込む
        self.gameOverImage = [CCSprite spriteWithFile:@"GameOver.png"];
        [self.infoLayer addChild:self.gameOverImage];
        
        // 画面の中心に配置する
        self.gameOverImage.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    }
}

/*!
 @brief ゲーム状態リセット
 
 ゲームの状態を初期状態にリセットする。
 */
- (void)resetAll
{
    NSString *scoreString = nil;    // スコアの文字列

    // 各種メンバを初期化する
    m_state = GAME_STATE_START;
    m_stageNo = 1;
    m_waveNo = 1;
    m_life = START_LIFE_COUNT;
    m_rebirthInterval = 0.0f;
    m_score = 0;
    
    // 残機マークの初期個数を反映させる
    [self.lifeMark updateImage:m_life];
    
    // ラベルの内容を更新する
    scoreString = [NSString stringWithFormat:@"SCORE:%08d", m_score];
    [self.scoreLabel setString:scoreString];

    // 自機の状態を初期化する
    [self.player reset];

    // 画面上の全キャラクターを削除する
    [self.playerShotPool reset];
    [self.enemyPool reset];
    [self.effectPool reset];
    
    // ゲームオーバーを表示している場合は削除する
    if (self.gameOverImage != nil) {
        [self.infoLayer removeChild:self.gameOverImage cleanup:YES];
        self.gameOverImage = nil;
    }
}

/*!
 @brief スコア加算
 
 スコアを加算する。
 */
- (void)addScore:(NSInteger)score
{
    NSString *scoreString = nil;    // スコアの文字列
    
    // スコアを加算する
    m_score += score;
    
    // ラベルの内容を更新する
    scoreString = [NSString stringWithFormat:@"SCORE:%08d", m_score];
    [self.scoreLabel setString:scoreString];
}
@end
