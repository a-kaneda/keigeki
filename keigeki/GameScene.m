//
//  GameScene.m
//  keigeki
//
//  Created by 金田 明浩 on 12/05/03.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import "GameScene.h"
#import "PlayerShot.h"

@implementation GameScene

// シングルトンオブジェクト
static GameScene *g_scene = nil;

@synthesize baseLayer = m_baseLayer;
@synthesize interface = m_interface;
@synthesize background = m_background;
@synthesize player = m_player;
@synthesize playerShotPool = m_playerShotPool;

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
    float anchor_x = 0.0f;  // 画面回転の中心点x座標
    float anchor_y = 0.0f;  // 画面回転の中心点y座標
    
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // キャラクターを配置するレイヤーを生成する
    self.baseLayer = [CCLayer node];
    [self addChild:m_baseLayer z:0];
    
    // 自機を中心に画面を回転させるためにアンカーポイントを自機の位置に移動する
    anchor_x = ((float)SCREEN_WIDTH / SCREEN_HEIGHT) * ((float)PLAYER_POS_X / SCREEN_WIDTH);
    anchor_y = ((float)SCREEN_HEIGHT / SCREEN_WIDTH) * ((float)PLAYER_POS_Y / SCREEN_HEIGHT);
    m_baseLayer.anchorPoint = ccp(anchor_x, anchor_y);
    DBGLOG(0, @"m_baseLayer.contentSize=(%f, %f)", m_baseLayer.contentSize.width, m_baseLayer.contentSize.height);
    DBGLOG(0, @"m_baseLayer.anchorPoint=(%f, %f)", m_baseLayer.anchorPoint.x, m_baseLayer.anchorPoint.y);
    
    // インターフェースレイヤーを貼り付ける
    self.interface = [GameIFLayer node];
    [self addChild:m_interface z:1];
    
    // 背景の生成
    self.background = [Background node];
    [m_baseLayer addChild:m_background z:1];
    
    // 自機の生成
    self.player = [Player node];
    [m_background addChild:m_player z:PLAYER_POS_Z];
    
    // 自機弾プールの生成
    self.playerShotPool = [[[CharacterPool alloc] initWithClass:[PlayerShot class]
                    Size:MAX_PLAYER_SHOT_COUNT] autorelease];
    
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
    [m_playerShotPool release];
    [m_background removeChild:m_player cleanup:YES];
    [m_baseLayer removeChild:m_background cleanup:YES];
    [self removeChild:m_interface cleanup:YES];
    [self removeChild:m_baseLayer cleanup:YES];
    
    [super dealloc];
}

/*!
 @method 更新処理
 @abstruct 各キャラクターの移動処理、衝突判定を行う。
 @param dt フレーム更新間隔 
 */
- (void)update:(ccTime)dt
{
    float scrx = 0.0f;      // スクリーン座標x
    float scry = 0.0f;      // スクリーン座標y
    float angle = 0.0f;     // スクリーンの向き
    NSEnumerator *enumerator;   // キャラクター操作用列挙子
    Character *character;       // キャラクター操作作業用バッファ
    
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
        DBGLOG(0 && character.isStaged, @"playerShot.abxpos=(%f, %f)", character.absx, character.absy);
    }
    
    // 背景の移動
    [m_background moveWithScreenX:scrx ScreenY:scry];

    // 自機の向きの取得
    // 自機の向きと反対方向に画面を回転させるため、符号反転
    angle = -1 * CnvAngleRad2Scr(m_player.angle);
    
    // 画面の回転
//    m_baseLayer.rotation = angle;
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
    PlayerShot *shot = nil;   // 自機弾
    
    // プールから未使用のメモリを取得する
    shot = [m_playerShotPool getNext];
    if (shot == nil) {
        // 空きがない場合は処理終了
        DBGLOG(1, @"自機弾プールに空きなし");
        return;
    }
    
    // 自機弾を生成する
    // 位置と向きは自機と同じとする
    [shot createWithX:m_player.absx Y:m_player.absy Z:PLAYER_SHOT_POS_Z
                Angle:m_player.angle Parent:m_background];
}
@end
