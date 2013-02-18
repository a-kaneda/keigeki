/*
 * Copyright (c) 2012-2013 Akihiro Kaneda.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   1.Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *   2.Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *   3.Neither the name of the Monochrome Soft nor the names of its contributors
 *     may be used to endorse or promote products derived from this software
 *     without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
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
    
    // iPadの場合はサイズを倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        width_ *= 2;
        height_ *= 2;
    }
    
    // 状態を初期化する
    [self reset];
    
    // アニメーションの間隔を初期化する
    animationTime_ = 0.0f;
    
    // 画像サイズを決める
    NSInteger imageSize = kAKPlayerImageSize;
    
    // iPadの場合はサイズを倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        imageSize *= 2;
    }
    
    // 画像の読込
    self.image = [CCSprite spriteWithFile:@"Player.png" rect:CGRectMake(0, 0, imageSize, imageSize)];
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
    
    // 画像サイズを決める
    NSInteger imageSize = kAKPlayerImageSize;
    
    // iPadの場合はサイズを倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        imageSize *= 2;
    }

    // アニメーションの間隔をカウントする
    animationTime_ += dt;
    // アニメーション間隔の経過時間によって表示するフレームを切り替える
    if (animationTime_ < kAKAnimationFrameDelay) {
        [(CCSprite *)self.image setTextureRect:CGRectMake(playerDirection * imageSize,
                                                          0,
                                                          imageSize,
                                                          imageSize)];
    }
    else if (animationTime_ < kAKAnimationFrameDelay * 2) {
        [(CCSprite *)self.image setTextureRect:CGRectMake((playerDirection + 1) * imageSize,
                                                          0,
                                                          imageSize,
                                                          imageSize)];
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
