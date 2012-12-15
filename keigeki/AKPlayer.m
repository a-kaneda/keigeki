/*!
 @file AKPlayer.m
 @brief 自機クラス定義
 
 自機を管理するクラスを定義する。
 */

#import <math.h>
#import "AKPlayer.h"
#import "AKGameScene.h"
#import "AKScreenSize.h"
#import "SimpleAudioEngine.h"

/// 速度の最大値
static const NSInteger kAKPlayerSpeed = 240;
/// 自機の回転速度
static const float kAKPlayerRotSpeed = 1.0f;
/// 自機のサイズ
static const NSInteger kAKPlayerSize = 16;
/// 復活後の無敵状態の時間
static const float kAKInvincibleTime = 2.0f;

/// 爆発エフェクト画像のファイル名
static NSString *kAKExplosion = @"Explosion.png";
/// 爆発エフェクトの位置とサイズ
static const CGRect kAKExplosionRect = {0, 0, 32, 32};
/// 爆発エフェクトのフレーム数
static const NSInteger kAKExplosionFrameCount = 8;
/// 爆発エフェクトのフレーム更新間隔
static const float kAKExplosionFrameDelay = 0.2f;

/// アニメーションのフレーム更新間隔
static const float kAKAnimationFrameDelay = 0.1f;
/// 1フレームの画像サイズ
static const float kAKPlayerImageSize = 32;
/// 左右の画像への切り替える角速度
static const float kAKFrameChangeRotSpeed = 0.8f;

/// 直進画像のフレーム位置
static const NSInteger kAKPlayerImagePosStraight = 0;
/// 左向き画像のフレーム位置
static const NSInteger kAKPlayerImagePosLeft = 2;
/// 右向き画像のフレーム位置
static const NSInteger kAKPlayerImagePosRight = 4;

/// 破壊時の効果音
static NSString *kAKHitSE = @"Hit.caf";

/*!
 @brief 自機クラス

 自機を管理する。
 */
@implementation AKPlayer

@synthesize isInvincible = isInvincible_;

/*!
 @brief オブジェクト生成処理

 オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }

    // 速度の設定
    speed_ = kAKPlayerSpeed;
    
    // サイズを設定する
    width_ = kAKPlayerSize;
    height_ = kAKPlayerSize;
    
    // 状態を初期化する
    [self reset];
    
    // アニメーションの間隔を初期化する
    animationTime_ = 0.0f;
    
    // 画像の読込
    self.image = [CCSprite spriteWithFile:@"Player.png" rect:CGRectMake(0, 0, kAKPlayerImageSize, kAKPlayerImageSize)];
    assert(image_ != nil);
    
    return self;
}

/*!
 @brief キャラクター固有の動作

 速度によって位置を移動する。自機の表示位置は固定とする。
 @param dt フレーム更新間隔
 */
- (void)action:(ccTime)dt
{
    // 無敵状態の時は無敵時間をカウントする
    if (isInvincible_) {
        invincivleTime_ -= dt;
        
        // 無敵時間が切れている場合は通常状態に戻す
        if (invincivleTime_ < 0) {
            isInvincible_ = NO;
        }
    }
    
    // 自機の表示座標は画面中央下部に固定
    self.image.position = ccp(AKPlayerPosX(), AKPlayerPosY());
    
    // 回転速度から表示画像を切り替える
    NSInteger playerDirection = 0;
    if (rotSpeed_ < -kAKFrameChangeRotSpeed) {
        playerDirection = kAKPlayerImagePosRight;
    }
    else if (rotSpeed_ > kAKFrameChangeRotSpeed) {
        playerDirection = kAKPlayerImagePosLeft;
    }
    else {
        playerDirection = kAKPlayerImagePosStraight;
    }
    
    // アニメーションの間隔をカウントする
    animationTime_ += dt;
    // アニメーション間隔の経過時間によって表示するフレームを切り替える
    if (animationTime_ < kAKAnimationFrameDelay) {
        [(CCSprite *)self.image setTextureRect:CGRectMake(playerDirection * kAKPlayerImageSize,
                                                          0,
                                                          kAKPlayerImageSize,
                                                          kAKPlayerImageSize)];
    }
    else if (animationTime_ < kAKAnimationFrameDelay * 2) {
        [(CCSprite *)self.image setTextureRect:CGRectMake((playerDirection + 1) * kAKPlayerImageSize,
                                                          0,
                                                          kAKPlayerImageSize,
                                                          kAKPlayerImageSize)];
    }
    else {
        animationTime_ = 0.0f;
    }
    
    AKLog(0, @"player pos=(%f, %f)", self.image.position.x, self.image.position.y);
    AKLog(0, @"player angle=%f speed=%f", angle_, speed_);
}

/*!
 @brief 破壊処理
 
 HPが0になったときに爆発エフェクトを生成する。
 */
- (void)destroy
{
    // 破壊時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKHitSE];

    // 画面効果を生成する
    [[AKGameScene getInstance] entryEffect:kAKExplosion
                                 startRect:kAKExplosionRect
                                frameCount:kAKExplosionFrameCount
                                     delay:kAKExplosionFrameDelay
                                      posX:self.absx posY:self.absy];
    
    // 配置フラグを落とす
    self.isStaged = NO;
    
    // 非表示とする
    self.image.visible = NO;
    
    // 自機破壊時の処理を行う
    [[AKGameScene getInstance] miss];
}

/*!
 @brief スクリーン座標(x座標)の取得

 自機の絶対座標からスクリーン座標を計算して返す。x座標を求める。
 @return スクリーン座標(x座標)
 */
- (float)getScreenPosX
{
    return AKRangeCheckLF(self.absx + [AKScreenSize screenSize].width / 2 - AKPlayerPosX(),
                          0.0f,
                          [AKScreenSize stageSize].width);
}

/*!
 @brief スクリーン座標(y座標)の取得

 自機の絶対座標からスクリーン座標を計算して返す。x座標を求める。
 @return スクリーン座標(y座標)
 */
- (float)getScreenPosY
{
    return AKRangeCheckLF(self.absy + [AKScreenSize screenSize].height / 2 - AKPlayerPosY(),
                          0.0f,
                          [AKScreenSize stageSize].height);
}

/*!
 @brief 速度の設定

 速度を設定する。-0.1〜0.1の範囲で指定する。
 @param vx x軸方向の速度
 @param vy y軸方向の速度
 */
- (void)setVelocityX:(float)vx Y:(float)vy
{
    // スピードは縦方向の傾きから決定する
    speed_ = (vy + 1.2) * kAKPlayerSpeed;
    
    // 角速度は横方向の傾きから決定する
    rotSpeed_ = -1 * vx * kAKPlayerRotSpeed;
}

/*!
 @brief 復活
 
 破壊された自機を復活させる。
 */
- (void)rebirth
{    
    // HPの設定
    hitPoint_ = 1;
    
    // ステージ配置フラグを立てる
    isStaged_ = YES;
    
    // 表示させる
    self.image.visible = YES;
    
    // 無敵状態にする
    isInvincible_ = YES;
    invincivleTime_ = kAKInvincibleTime;
    
    // 無敵中はブリンクする
    CCBlink *blink = [CCBlink actionWithDuration:kAKInvincibleTime blinks:kAKInvincibleTime * 8];
    [self.image runAction:blink];
}

/*!
 @brief 初期化
 
 状態を初期化する。
 */
- (void)reset
{
    // 初期位置は原点
    self.image.position = ccp(0, 0);
    
    // 初期角度は垂直上向き
    angle_ = M_PI / 2;
    
    // HPの設定
    hitPoint_ = 1;
    
    // ステージ配置フラグを立てる
    isStaged_ = YES;
    
    // 表示させる
    self.image.visible = YES;
    
    // 無敵状態はOFFにする
    isInvincible_ = NO;
    invincivleTime_ = 0.0f;
    
    // アクションはすべて停止する
    [self.image stopAllActions];
}
@end
