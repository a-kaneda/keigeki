//
//  GameScene.m
//  keigeki
//
//  Created by 金田 明浩 on 12/05/03.
//  Copyright 2012年 KANEDA Akihiro. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

// シングルトンオブジェクト
static GameScene *g_scene = nil;

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
    m_baseLayer = [CCLayer node];
    [self addChild:m_baseLayer z:0];
    
    // 自機を中心に画面を回転させるためにアンカーポイントを自機の位置に移動する
    anchor_x = ((float)SCREEN_WIDTH / SCREEN_HEIGHT) * ((float)PLAYER_POS_X / SCREEN_WIDTH);
    anchor_y = ((float)SCREEN_HEIGHT / SCREEN_WIDTH) * ((float)PLAYER_POS_Y / SCREEN_HEIGHT);
    m_baseLayer.anchorPoint = ccp(anchor_x, anchor_y);
    DBGLOG(0, @"m_baseLayer.contentSize=(%f, %f)", m_baseLayer.contentSize.width, m_baseLayer.contentSize.height);
    DBGLOG(0, @"m_baseLayer.anchorPoint=(%f, %f)", m_baseLayer.anchorPoint.x, m_baseLayer.anchorPoint.y);
    
    // インターフェースレイヤーを貼り付ける
    m_interface = [GameIFLayer node];
    [m_baseLayer addChild:m_interface z:0];
    
    // 背景の生成
    m_background = [Background node];
    [m_baseLayer addChild:m_background z:1];
    
    // 自機の生成
    m_player = [Player node];
    [m_background addChild:m_player z:50];
    
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
    g_scene = nil;
    
    [m_player release];
    m_player = nil;
    
    [m_background release];
    m_background = nil;
    
    [m_interface release];
    m_interface = nil;
    
    [m_baseLayer release];
    m_baseLayer = nil;
    
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
    
    // 自機の移動
    // 自機にスクリーン座標は無関係なため、0をダミーで格納する。
    [m_player move:dt ScreenX:0 ScreenY:0];
    
    // 移動後のスクリーン座標の取得
    scrx = [m_player getScreenPosX];
    scry = [m_player getScreenPosY];
    DBGLOG(0, @"x=%f y=%f", scrx, scry);
    
    // 背景の移動
    [m_background moveWithScreenX:scrx ScreenY:scry];

    // 自機の向きの取得
    // 自機の向きと反対方向に画面を回転させるため、符号反転
    angle = -1 * CnvAngleRad2Scr(m_player.angle);
    
    // 画面の回転
    m_baseLayer.rotation = angle;
    DBGLOG(1, @"m_baseLayer angle=%f", m_baseLayer.rotation);
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
@end
