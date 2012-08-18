/*!
 @file AKEnemy+Normal.m
 @brief 雑魚クラス定義
 
 雑魚敵を定義する。
 */

#import <stdlib.h>
#import "AKGameScene.h"
#import "AKEnemy+Normal.h"

/*!
 @brief 雑魚クラス
 
 雑魚。自機に向かって移動、1-way弾を定期的に撃つ。
 */
@implementation AKEnemy (Normal)

/*!
 @brief 雑魚生成

 雑魚のパラメータを設定する。
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
    
    // 当たり判定サイズを設定する
    self.width = ENEMY_NORMAL_SIZE;
    self.height = ENEMY_NORMAL_SIZE;
    
    // 画像をノードに追加する
    [self addChild:self.image];
    
    // 速度を設定する
    m_speed = ENEMY_NORMAL_SPEED;
    
    // HPを設定する
    m_hitPoint = 1;
    
    DBGLOG(0, @"angle=%f", AKCnvAngleRad2Deg(m_angle));
}

/*!
 @brief 雑魚動作

 自機を追う。一定間隔で自機を狙う1-way弾発射。
 @param dt フレーム更新間隔
 */
- (void)actionNoraml:(ccTime)dt
{
    int rotdirect = 0;  // 回転方向
    
    // 回転方向を自機のある方に決定する
    rotdirect = AKCalcRotDirect(m_angle, self.position.x, self.position.y, PLAYER_POS_X, PLAYER_POS_Y);
    
    // 自機の方に向かって向きを回転する
    self.rotSpeed = rotdirect * ENEMY_NORAML_ROTSPEED;
    DBGLOG(0, @"rotspeed=%f roddirect=%d", m_rotSpeed, rotdirect);
    
    // 一定時間経過しているときは自機を狙う1-way弾を発射する
    if (m_time > ENEMY_NORMAL_ACTIONTIME) {
        // [TODO] 弾発射処理を作成する
        
        // 動作時間の初期化を行う
        m_time = 0.0f;
    }
    
    DBGLOG(0, @"pos=(%f, %f) angle=%f", self.position.x, self.position.y, AKCnvAngleRad2Deg(m_angle));
}

/*!
 @brief 雑魚破壊処理

 破壊エフェクトを発生させる。
 */
- (void)destroyNormal
{
    CCParticleSystem *bomb = nil;   // 爆発エフェクト
    
    DBGLOG(0, @"destroyNormal start.");
    
    // 爆発エフェクトを生成する
    bomb = [CCParticleSun node];
    bomb.duration = 0.3f;
    bomb.life = 0.5f;
    bomb.speed = 40;
    bomb.scale = 1.5f;
    bomb.position = self.position;
    bomb.autoRemoveOnFinish = YES;
    
    // ゲームシーンのレイヤーに配置する
    [[AKGameScene sharedInstance].baseLayer addChild:bomb z:BOMB_POS_Z];
}
@end
