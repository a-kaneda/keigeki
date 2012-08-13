//
//  GameScene.m
//  keigeki
//
//  Created by 金田 明浩 on 12/05/03.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import "GameScene.h"
#import "PlayerShot.h"
#import "Enemy.h"

@implementation GameScene

// シングルトンオブジェクト
static GameScene *g_scene = nil;

@synthesize baseLayer = m_baseLayer;
@synthesize infoLayer = m_infoLayer;
@synthesize interface = m_interface;
@synthesize background = m_background;
@synthesize player = m_player;
@synthesize playerShotPool = m_playerShotPool;
@synthesize enemyPool = m_enemyPool;
@synthesize rader = m_radar;

/*!
 @method シングルトンオブジェクト取得
 @abstruct シングルトンオブジェクトを返す。初回呼び出し時はオブジェクトを作成して返す。
 @return シングルトンオブジェクト
 */
+ (GameScene *)sharedInstance
{
    // シングルトンオブジェクトが作成されていない場合は作成する。
    if (g_scene == nil) {
        g_scene = [GameScene node];
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
    
    // シーンの状態、ステージ番号、ウェイブ番号を初期化する
    m_state = GAME_STATE_START;
    m_stageNo = 1;
    m_waveNo = 1;
    
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
    self.interface = [GameIFLayer node];
    [self addChild:self.interface z:2];
    
    // 背景の生成
    self.background = [Background node];
    [self.baseLayer addChild:self.background z:1];
    
    // 自機の生成
    self.player = [Player node];
    [self.background addChild:self.player z:PLAYER_POS_Z];
    
    // 自機弾プールの生成
    self.playerShotPool = [[[CharacterPool alloc] initWithClass:[PlayerShot class]
                                                           Size:MAX_PLAYER_SHOT_COUNT] autorelease];
    
    // 敵プールの生成
    self.enemyPool = [[[CharacterPool alloc] initWithClass:[Enemy class]
                                                      Size:MAX_ENEMY_COUNT] autorelease];

    // レーダーの画像を読み込む
    self.rader = [CCSprite spriteWithFile:@"Radar.png"];
    assert(self.rader != nil);
    
    // レーダーをレイヤーに配置する
    [self.infoLayer addChild:self.rader];
    
    // レーダーの位置を設定する
    self.rader.position = ccp(RADAR_POS_X, RADAR_POS_Y);
        
    // 更新処理開始
    [self scheduleUpdate];
    
    return self;
}

/*!
 @method インスタンス解放時処理
 @abstruct インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    // 更新処理停止
    [self unscheduleUpdate];
    
    // リソースの解放
    [self.playerShotPool release];
    [self.background removeChild:self.player cleanup:YES];
    [self.infoLayer removeChild:self.rader cleanup:YES];
    [self.baseLayer removeChild:self.background cleanup:YES];
    [self removeChild:self.interface cleanup:YES];
    [self removeChild:self.baseLayer cleanup:YES];
    [self removeChild:self.infoLayer cleanup:YES];
    
    [super dealloc];
}

/*!
 @method 更新処理
 @abstruct ゲームの状態によって、更新処理を行う。
 @param dt フレーム更新間隔 
 */
- (void)update:(ccTime)dt
{
    // ゲームの状態によって処理を分岐する
    switch (m_state) {
        case GAME_STATE_START:   // ゲーム開始時
            [self updateStart:dt];
            break;
            
        case GAME_STATE_PLAYING:        // プレイ中
            [self updatePlaying:dt];
            break;
            
        default:
            break;
    }
}

/*!
 @method ゲーム開始時の更新処理
 @abstruct ステージ定義ファイルを読み込み、敵を配置する。
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
            
            DBGLOG(1, @"type=%d posx=%d posy=%d", enemyType, enemyPosX, enemyPosY);
            
            // 角度を自機のいる位置に設定する
            // スクリプト上の座標は自機の位置からの相対位置なので目標座標は(0, 0)
            enemyAngle = CalcDestAngle(enemyPosX, enemyPosY, 0, 0);
            
            DBGLOG(1, @"angle=%f", CnvAngleRad2Deg(enemyAngle));
            
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
 @method プレイ中の更新処理
 @abstruct 各キャラクターの移動処理、衝突判定を行う。
 @param dt フレーム更新間隔
 */
- (void)updatePlaying:(ccTime)dt
{
    float scrx = 0.0f;      // スクリーン座標x
    float scry = 0.0f;      // スクリーン座標y
    float angle = 0.0f;     // スクリーンの向き
    NSEnumerator *enumerator = nil;   // キャラクター操作用列挙子
    Character *character = nil;       // キャラクター操作作業用バッファ
    
    // 自機の移動
    // 自機にスクリーン座標は無関係なため、0をダミーで格納する。
    [m_player move:dt ScreenX:0 ScreenY:0];
    DBGLOG(0, @"m_player.abspos=(%f, %f)", m_player.absx, m_player.absy);
    
    // 移動後のスクリーン座標の取得
    scrx = [m_player getScreenPosX];
    scry = [m_player getScreenPosY];
    DBGLOG(0, @"x=%f y=%f", scrx, scry);
    
    // 自機弾の移動
    enumerator = [m_playerShotPool.pool objectEnumerator];
    for (character in enumerator) {
        [character move:dt ScreenX:scrx ScreenY:scry];
        DBGLOG(0 && character.isStaged, @"playerShot.abxpos=(%f, %f)",
               character.absx, character.absy);
    }
    
    // 敵の移動
    enumerator = [m_enemyPool.pool objectEnumerator];
    for (character in enumerator) {
        DBGLOG(0 && character.isStaged, @"enemy move start.");
        [character move:dt ScreenX:scrx ScreenY:scry];
    }
    
    // 背景の移動
    [m_background moveWithScreenX:scrx ScreenY:scry];
    
    // 自機の向きの取得
    // 自機の向きと反対方向に画面を回転させるため、符号反転
    angle = -1 * CnvAngleRad2Scr(m_player.angle);
    
    // 画面の回転
    m_baseLayer.rotation = angle;
    DBGLOG(0, @"m_baseLayer angle=%f", m_baseLayer.rotation);
}

/*!
 @method 自機の移動
 @abstruct 自機の速度を-1.0〜1.0の範囲で設定する。
 @param ax x軸方向の速度
 @param ay y軸方向の速度
 */
- (void)movePlayerByVX:(float)vx VY:(float)vy
{
    [m_player setVelocityX:vx Y:vy];
}

/*!
 @method 自機弾の発射
 @abstruct 自機弾を発車する。
 */
- (void)filePlayerShot
{
    float angle = 0.0f;     // 発射の方向
    PlayerShot *shot = nil; // 自機弾
    
    // プールから未使用のメモリを取得する
    shot = [m_playerShotPool getNext];
    if (shot == nil) {
        // 空きがない場合は処理終了
        DBGLOG(1, @"自機弾プールに空きなし");
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
 @method 敵の生成
 @abstruct 敵を生成する。
 @param type 敵の種類
 @param posx 生成位置x座標
 @param posy 生成位置y座標
 @param angle 敵の向き
 */
- (void)entryEnemy:(enum ENEMY_TYPE)type PosX:(NSInteger)posx PosY:(NSInteger)posy Angle:(float)angle
{
    Enemy *enemy = nil;     // 敵
    SEL createEnemy = nil;  // 敵生成のメソッド
    
    DBGLOG(1, @"type=%d posx=%d posy=%d angle=%f", type, posx, posy, CnvAngleRad2Deg(angle));
    
    // プールから未使用のメモリを取得する
    enemy = [m_enemyPool getNext];
    if (enemy == nil) {
        // 空きがない場合は処理終了
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
@end
