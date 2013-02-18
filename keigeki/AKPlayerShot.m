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
 @file AKPlayerShot.m
 @brief 自機弾クラス定義
 
 自機弾を管理するクラスを定義する。
 */

#import "AKPlayerShot.h"
#import "AKGameScene.h"
#import "AKCommon.h"

/// 自機弾のスピード
static const NSInteger kAKPlayerShotSpeed = 1200;
/// 自機弾の幅
static const CGSize kAKPlayerShotSize = {2, 8};

/*!
 @brief 自機弾クラス

 自機弾を管理するクラス。
 */
@implementation AKPlayerShot

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
    
    // 画像の読込
    self.image = [CCSprite spriteWithFile:@"PlayerShot.png"];
    assert(image_ != nil);
    
    // 各種パラメータを設定する
    speed_ = kAKPlayerShotSpeed;
    width_ = kAKPlayerShotSize.width;
    height_ = kAKPlayerShotSize.height;
    
    // iPadの場合はサイズを倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        width_ *= 2;
        height_ *= 2;
    }
    
    return self;
}

/*!
 @brief 破壊処理
 
 ショット発射数をカウントする。
 射程距離がまだ残っている場合は敵に命中したと判断して命中数をカウントする。
 */
- (void)destroy
{
    // ゲームプレイシーンクラスを取得する
    AKGameScene *gameScene = [AKGameScene getInstance];
    
    // ショット発射数をカウントする
    gameScene.shotCount++;
    
    // 射程距離が残っていれば命中数をカウントする
    if (distance_ > 0.0f) {
        gameScene.hitCount++;
    }
    AKLog(0, @"hitCount=%d shotCount=%d", gameScene.hitCount, gameScene.shotCount);
    
    // スーパークラスの処理を行う
    [super destroy];
}
@end
