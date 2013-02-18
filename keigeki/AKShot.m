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
 @file AKShot.m
 @brief 弾クラス定義
 
 弾を管理するクラスを定義する。
 */

#import "AKShot.h"
#import "AKCommon.h"

/// 弾の射程距離
static const NSInteger kAKShotRange = 600;

/*!
 @brief 弾クラス
 
 弾を管理するクラス。一定距離まっすぐ進んだあとに消える。
 */
@implementation AKShot

/*!
 @brief キャラクター固有の動作
 
 射程距離を外れたとき画面から取り除く。
 @param dt フレーム更新間隔
 */
- (void)action:(ccTime)dt
{
    // 移動距離をカウントする
    distance_ -= speed_ * dt;
    AKLog(0, @"m_distance=%f", distance_);
    
    // 移動距離が射程距離を超えた場合は弾を削除する
    if (distance_ < 0.0f) {
        hitPoint_ = -1.0f;
        AKLog(0, @"shot delete.");
    }
}

/*!
 @brief 生成処理
 
 弾を生成する。
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param z 生成位置z座標
 @param angle 弾の進行方向
 @param parent 弾を配置する親ノード
 */
- (void)createWithX:(NSInteger)x Y:(NSInteger)y Z:(NSInteger)z Angle:(float)angle
             Parent:(CCNode *)parent
{
    // パラメータの内容をメンバに設定する
    self.absx = x;
    self.absy = y;
    self.angle = angle;
    
    // メンバの初期値を設定する
    hitPoint_ = 1;
    isStaged_ = YES;
    distance_ = kAKShotRange;
    
    assert(self.image != nil);
    
    // レイヤーに配置する
    [parent addChild:self.image z:z];
}
@end
