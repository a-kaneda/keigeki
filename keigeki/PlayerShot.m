//
//  PlayerShot.m
//  keigeki
//
//  Created by 金田 明浩 on 12/07/23.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import "PlayerShot.h"
#import "common.h"

@implementation PlayerShot

/*!
 @method オブジェクト生成処理
 @abstruct オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 画像の読込
    self.image = [CCSprite spriteWithFile:@"PlayerShot.png"];
    [self addChild:m_image];
    
    return self;
}

/*!
 @method 移動処理
 @abstruct 速度によって位置を移動する。自機の表示位置は固定とする。
 @param dt フレーム更新間隔
 @param scrx スクリーン座標x
 @param scry スクリーン座標y
 */
- (void)move:(ccTime)dt ScreenX:(NSInteger)scrx ScreenY:(NSInteger)scry
{
    // 画面に配置されていないときは無処理
    if (!m_isStaged) {
        return;
    }
    
    // 移動距離をカウントする
    m_distance += m_speed * dt;
    
    // 移動距離が射程距離を超えた場合は弾を削除する
    if (m_distance > PLAYER_SHOT_RANGE) {
        m_hitPoint = -1.0f;
    }

    // スーパークラスの移動処理
    [super move:dt ScreenX:scrx ScreenY:scry];

    DBGLOG(0, @"pos_y=%f abs_y=%f scr_y=%d", self.position.y, m_absy, scry);
    DBGLOG(0, @"m_distance=%f isStaged=%d", m_distance, m_isStaged);
}

/*!
 @method 生成処理
 @abstruct 自機弾を生成する。
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param z 生成位置z座標
 @param angle 自機弾の進行方向
 @param parent 自機弾を配置する親ノード
 */
- (void)createWithX:(NSInteger)x Y:(NSInteger)y Z:(NSInteger)z Angle:(float)angle
              Parent:(CCNode *)parent
{
    // パラメータの内容をメンバに設定する
    m_absx = x;
    m_absy = y;
    m_angle = angle;
    
    // メンバの初期値を設定する
    m_hitPoint = 1;
    m_speed = PLAYER_SHOT_SPEED;
    m_width = PLAYER_SHOT_WIDTH;
    m_height = PLAYER_SHOT_HEIGHT;
    m_isStaged = YES;
    m_distance = 0.0f;
    
    // レイヤーに配置する
    [parent addChild:self z:z];
}
@end
