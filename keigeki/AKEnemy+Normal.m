/*!
 @file AKEnemy+Normal.m
 @brief 雑魚クラス定義
 
 雑魚敵を定義する。
 */

#import <stdlib.h>
#import "AKGameScene.h"
#import "AKEnemy+Normal.h"

/// 雑魚の移動速度
static const NSInteger kAKEnemySpeed = 240;
/// 雑魚の回転速度
static const float kAKEnemyRotSpeed = 0.5f;
/// 雑魚の弾発射の時間
static const NSInteger kAKEnemyActionTime = 5;
/// 雑魚の敵のサイズ
static const NSInteger kAKEnemySize = 16;

/// 爆発エフェクト画像のファイル名
static NSString *kAKExplosion = @"Explosion.png";
/// 爆発エフェクトの位置とサイズ
static const CGRect kAKExplosionRect = {0, 0, 32, 32};
/// 爆発エフェクトのフレーム数
static const NSInteger kAKExplosionFrameCount = 8;
/// 爆発エフェクトのフレーム更新間隔
static const float kAKExplosionFrameDelay = 0.2f;

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
    action_ = @selector(actionNoraml:);
    
    // 破壊処理を設定する
    destroy_ = @selector(destroyNormal);
    
    // 画像を読み込む
    self.image = [CCSprite spriteWithFile:@"Enemy1.png"];
    assert(image_ != nil);
    
    // 当たり判定サイズを設定する
    self.width = kAKEnemySize;
    self.height = kAKEnemySize;
        
    // 速度を設定する
    speed_ = kAKEnemySpeed;
    
    // HPを設定する
    hitPoint_ = 1;
    
    AKLog(0, @"angle=%f", AKCnvAngleRad2Deg(angle_));
}

/*!
 @brief 雑魚動作

 自機を追う。一定間隔で自機を狙う1-way弾発射。
 @param dt フレーム更新間隔
 */
- (void)actionNoraml:(ccTime)dt
{
    int rotdirect = 0;      // 回転方向
    
    // 回転方向を自機のある方に決定する
    rotdirect = AKCalcRotDirect(angle_, self.image.position.x, self.image.position.y,
                                AKPlayerPosX(), AKPlayerPosY());
    
    // 自機の方に向かって向きを回転する
    self.rotSpeed = rotdirect * kAKEnemyRotSpeed;
    AKLog(0, @"rotspeed=%f roddirect=%d", rotSpeed_, rotdirect);
    
    // 一定時間経過しているときは自機を狙う1-way弾を発射する
    if (time_ > kAKEnemyActionTime) {
        
        // 弾を発射する
        [self fireNormal];
        
        // 動作時間の初期化を行う
        time_ = 0.0f;
    }
    
    AKLog(0, @"pos=(%f, %f) angle=%f", self.image.position.x, self.image.position.y,
           AKCnvAngleRad2Deg(angle_));
}

/*!
 @brief 雑魚破壊処理

 破壊エフェクトを発生させる。
 */
- (void)destroyNormal
{
    // 画面効果を生成する
    [[AKGameScene sharedInstance] entryEffect:kAKExplosion
                                    startRect:kAKExplosionRect
                                   frameCount:kAKExplosionFrameCount
                                        delay:kAKExplosionFrameDelay
                                         posX:self.absx posY:self.absy];
}

/*!
 @brief 通常弾の発射
 
 通常弾の発射を行う。
 */
- (void)fireNormal
{
    // 通常弾を生成する
    [[AKGameScene sharedInstance] fireEnemyShot:ENEMY_SHOT_TYPE_NORMAL
                                           PosX:self.absx PosY:self.absy Angle:self.angle];
}
@end
