//
//  Enemy+NoramlDevil.m
//  keigeki
//
//  Created by 金田 明浩 on 2012/08/10.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import <stdlib.h>
#import "Enemy+Noraml.h"

@implementation Enemy (Noraml)

/*!
 @method 雑魚生成
 @abstruct 雑魚のパラメータを設定する。
 */
- (void)createNoraml
{
    // 動作処理を設定する
    m_action = @selector(actionNoraml:);
    
    // 破壊処理を設定する
    m_destroy = @selector(destroyNormal);
    
    // 画像を読み込む
    self.image = [CCSprite spriteWithFile:@"Enemy_1.png"];
    assert(m_image != nil);
    
    // 画像をノードに追加する
    [self addChild:self.image];
    
    // 速度を設定する
    m_speed = ENEMY_NORMAL_SPEED;
    
    // HPを設定する
    m_hitPoint = 1;
    
    DBGLOG(0, @"angle=%f", CnvAngleRad2Deg(m_angle));
}

/*!
 @method 雑魚動作
 @abstruct 自機を追う。一定間隔で自機を狙う1-way弾発射。
 @param dt フレーム更新間隔
 */
- (void)actionNoraml:(ccTime)dt
{
    int rotdirect = 0;  // 回転方向
    
    // 回転方向を自機のある方に決定する
    rotdirect = CalcRotDirect(m_angle, self.position.x, self.position.y, PLAYER_POS_X, PLAYER_POS_Y);
    
    // 自機の方に向かって向きを回転する
    self.rotSpeed = rotdirect * ENEMY_NORAML_ROTSPEED;
    DBGLOG(0, @"rotspeed=%f roddirect=%d", m_rotSpeed, rotdirect);
    
    // 一定時間経過しているときは自機を狙う1-way弾を発射する
    if (m_time > ENEMY_NORMAL_ACTIONTIME) {
        // [TODO] 弾発射処理を作成する
        
        // 動作時間の初期化を行う
        m_time = 0.0f;
    }
    
    DBGLOG(0, @"pos=(%f, %f) angle=%f", self.position.x, self.position.y, CnvAngleRad2Deg(m_angle));
}

/*!
 @method 雑魚破壊処理
 @abstruct 破壊エフェクトを発生させる。
 */
- (void)destroyNormal
{
    // [TODO] 破壊エフェクト発生処理を作成する
}
@end
