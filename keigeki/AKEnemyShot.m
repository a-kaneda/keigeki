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
 @file AKEnemyShot.m
 @brief 敵弾クラス定義
 
 敵弾を管理するクラスを定義する。
 */

#import "AKEnemyShot.h"

/// 敵弾の画像
static const char *ENEMY_SHOT_IMAGE[ENEMY_SHOT_TYPE_COUNT] = {
    "EnemyShot.png"
};

/// 敵弾のスピード
static const int ENEMY_SHOT_SPEED[ENEMY_SHOT_TYPE_COUNT] = {
    600
};

/// 敵弾の幅
static const int ENEMY_SHOT_WIDTH[ENEMY_SHOT_TYPE_COUNT] = {
    4
};

/// 敵弾の高さ
static const int ENEMY_SHOT_HEIGHT[ENEMY_SHOT_TYPE_COUNT] = {
    4
};

/*!
 @brief 敵弾クラス
 
 敵弾を管理するクラス。
 */
@implementation AKEnemyShot

/*!
 @brief 生成処理
 
 弾を生成する。
 @param type 敵弾の種類
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param z 生成位置z座標
 @param angle 弾の進行方向
 @param parent 弾を配置する親ノード
 */
- (void)createWithType:(enum ENEMY_SHOT_TYPE)type X:(NSInteger)x Y:(NSInteger)y Z:(NSInteger)z
                 Angle:(float)angle Parent:(CCNode *)parent
{
    // 画像を開放する
    [self.image removeFromParentAndCleanup:YES];
    
    // 画像を読み込む
    NSString *fileName = [NSString stringWithUTF8String:ENEMY_SHOT_IMAGE[type]];
    self.image = [CCSprite spriteWithFile:fileName];
    assert(image_ != nil);
    
    // 各種パラメータを設定する
    speed_ = ENEMY_SHOT_SPEED[type];
    width_ = ENEMY_SHOT_WIDTH[type];
    height_ = ENEMY_SHOT_HEIGHT[type];
    
    // iPadの場合はサイズを倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        width_ *= 2;
        height_ *= 2;
    }
    
    // 親クラスの生成処理を実行する
    [super createWithX:x Y:y Z:z Angle:angle Parent:parent];    
}
@end
