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
 @file AKCharacter.h
 @brief キャラクタークラス定義
 
 当たり判定を持つオブジェクトの基本クラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// キャラクタークラス
@interface AKCharacter : NSObject {
    /// 画像
    CCNode *image_;
    /// 当たり判定サイズ幅
    NSInteger width_;
    /// 当たり判定サイズ高さ
    NSInteger height_;
    /// 絶対座標x
    float absx_;
    /// 絶対座標y
    float absy_;
    /// 速度
    float speed_;
    /// 向き
    float angle_;
    /// 回転速度
    float rotSpeed_;
    /// HP
    NSInteger hitPoint_;
    /// ステージ上に存在しているかどうか
    BOOL isStaged_;
}

/// 画像
@property (nonatomic, retain)CCNode *image;
/// 当たり判定サイズ幅
@property (nonatomic)NSInteger width;
/// 当たり判定サイズ高さ
@property (nonatomic)NSInteger height;
/// 絶対座標x
@property (nonatomic)float absx;
/// 絶対座標y
@property (nonatomic)float absy;
/// 速度
@property (nonatomic)float speed;
/// 向き
@property (nonatomic)float angle;
/// 回転速度
@property (nonatomic)float rotSpeed;
/// HP
@property (nonatomic)NSInteger hitPoint;
/// ステージ上に存在しているかどうか
@property (nonatomic)BOOL isStaged;

// 移動処理
- (void)move:(ccTime)dt ScreenX:(NSInteger)scrx ScreenY:(NSInteger)scry;
// キャラクター固有の動作
- (void)action:(ccTime)dt;
// 破壊処理
- (void)destroy;
// 衝突判定
- (void)hit:(const NSEnumerator *)characters;
@end
