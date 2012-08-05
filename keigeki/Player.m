//
//  Player.m
//  keigeki
//
//  Created by 金田 明浩 on 12/05/16.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import "Player.h"
#import <math.h>

@implementation Player

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
    
    // 初期角度は垂直上向き
    m_angle = M_PI / 2;
    
    // HPの設定
    m_hitPoint = 1;
    
    // ステージ配置フラグを立てる
    m_isStaged = YES;
    
    // 画像の読込
    self.image = [CCSprite spriteWithFile:@"Player.png"];
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
    // スーパークラスの移動処理
    [super move:dt ScreenX:scrx ScreenY:scry];
    
    // 自機の表示座標は画面中央下部に固定
    self.position = ccp(PLAYER_POS_X, PLAYER_POS_Y);
    
    DBGLOG(0, @"player pos=(%f, %f)", self.position.x, self.position.y);
    DBGLOG(0, @"player angle=%f", m_angle);
}

/*!
 @method スクリーン座標(x座標)の取得
 @abstruct 自機の絶対座標からスクリーン座標を計算して返す。x座標を求める。
 @return スクリーン座標(x座標)
 */
- (float)getScreenPosX
{
    return RangeCheckLF(m_absx + SCREEN_WIDTH / 2 - PLAYER_POS_X, STAGE_WIDTH);
}

/*!
 @method スクリーン座標(y座標)の取得
 @abstruct 自機の絶対座標からスクリーン座標を計算して返す。x座標を求める。
 @return スクリーン座標(y座標)
 */
- (float)getScreenPosY
{
    return RangeCheckLF(m_absy + SCREEN_HEIGHT / 2 - PLAYER_POS_Y, STAGE_HEIGHT);
}

/*!
 @method 速度の設定
 @abstruct 速度を設定する。-0.1〜0.1の範囲で指定する。
 @param vx x軸方向の速度
 @param vy y軸方向の速度
 */
- (void)setVelocityX:(float)vx Y:(float)vy
{
    // スピードは縦方向の傾きから決定する
    m_speed = (vy + 1.5) * PLAYER_SPEED;
    
    // 角速度は横方向の傾きから決定する
    m_rotSpeed = -1 * vx * PLAYER_ROT_SPEED;
}

@end
