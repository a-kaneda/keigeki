//
//  Enemy+NoramlDevil.m
//  keigeki
//
//  Created by 金田 明浩 on 2012/08/10.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import <stdlib.h>
#import "Enemy+NoramlDevil.h"

@implementation Enemy (NoramlDevil)

/*!
 @method 雑魚悪魔生成
 @abstruct 雑魚悪魔のパラメータを設定する。
 */
- (void)createNoramlDevil
{
    // 動作処理を設定する
    m_action = @selector(actionNoramlDevil:);
    
    // 破壊処理を設定する
    m_destroy = @selector(destroyNormalDevil);
    
    // 画像を読み込む
    self.image = [CCSprite spriteWithFile:@"Enemy_1.png"];
    [self addChild:self.image];
    
    // 速度を設定する
    m_speed = NORMALDEVIL_SPEED;
    
    // 角度を設定する
    m_angle = (rand() % ENEMY_ANGLE_UNIT) * 2 * M_PI;
}

/*!
 @method 雑魚悪魔動作
 @abstruct 一定間隔で方向転換を行う。
 @param dt フレーム更新間隔
 */
- (void)actionNoramlDevil:(ccTime)dt
{
    // 方向転換を行う時間が経過している時は方向を変える
    if (m_time > NORMALDEVIL_ACTIONTIME) {
        
        // 角度を設定する
        m_angle = (rand() % ENEMY_ANGLE_UNIT) * 2 * M_PI;
    }
}

/*!
 @method 雑魚悪魔破壊処理
 @abstruct 破壊エフェクトを発生させる。
 */
- (void)destroyNormalDevil
{
    // [TODO]:破壊エフェクト発生処理を作成する
}
@end
