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
 @file AKScreenSize.m
 @brief 画面サイズ管理クラス
 
 画面サイズ管理クラスを定義する。
 */

#import "AKScreenSize.h"

/*!
 @brief 画面サイズ管理クラス
 
 画面サイズを管理する。
 */
@implementation AKScreenSize

/*!
 @brief 画面サイズ取得
 
 デバイスの画面サイズを取得する。
 @return 画面サイズ
 */
+ (CGSize)screenSize
{
    // Landscapeのため、画面の幅と高さを入れ替えて返す
    return CGSizeMake([[UIScreen mainScreen] bounds].size.height,
                      [[UIScreen mainScreen] bounds].size.width);
}

/*!
 @brief ステージサイズ取得
 
 ゲームステージのサイズを取得する。
 @return ステージサイズ
 */
+ (CGSize)stageSize
{
    // ステージサイズは画面サイズの64倍とする
    const NSInteger kAKStageSizeParam = 64;
    
    return CGSizeMake([AKScreenSize screenSize].width * kAKStageSizeParam,
                      [AKScreenSize screenSize].height * kAKStageSizeParam);
}

/*!
 @brief 中央座標取得
 
 画面の中央の座標を取得する。
 @return 中央座標
 */
+ (CGPoint)center
{
    return CGPointMake([AKScreenSize screenSize].width / 2,
                       [AKScreenSize screenSize].height / 2);
}

/*!
 @brief 左からの比率で座標取得
 
 左からの画面サイズの比率で距離を指定したときのデバイススクリーン座標を返す。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromLeftRatio:(float)ratio
{
    return [AKScreenSize screenSize].width * ratio;
}

/*!
 @brief 右からの比率で座標取得
 
 右からの画面サイズの比率で距離を指定したときのデバイススクリーン座標を返す。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromRightRatio:(float)ratio
{
    return [AKScreenSize screenSize].width * (1 - ratio);
}

/*!
 @brief 上からの比率で座標取得
 
 上からの画面サイズの比率で距離を指定したときのデバイススクリーン座標を返す。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromTopRatio:(float)ratio
{
    return [AKScreenSize screenSize].height * (1 - ratio);
}

/*!
 @brief 下からの比率で座標取得
 
 下からの画面サイズの比率で距離を指定したときのデバイススクリーン座標を返す。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromBottomRatio:(float)ratio
{
    return [AKScreenSize screenSize].height * ratio;
}

/*!
 @brief 左からの位置で座標取得
 
 左からの座標で距離を指定したときのデバイススクリーン座標を返す。
 iPadの場合は座標を倍にして処理する。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromLeftPoint:(float)point
{
    // iPadの場合は座標を倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        point *= 2.0f;
    }
    
    return point;
}

/*!
 @brief 右からの位置で座標取得
 
 右からの座標で距離を指定したときのデバイススクリーン座標を返す。
 iPadの場合は座標を倍にして処理する。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromRightPoint:(float)point
{
    // iPadの場合は座標を倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        point *= 2.0f;
    }
    
    return [AKScreenSize screenSize].width - point;
}

/*!
 @brief 上からの位置で座標取得
 
 上からの座標で距離を指定したときのデバイススクリーン座標を返す。
 iPadの場合は座標を倍にして処理する。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromTopPoint:(float)point
{
    // iPadの場合は座標を倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        point *= 2.0f;
    }
    
    return [AKScreenSize screenSize].height - point;
}

/*!
 @brief 下からの位置で座標取得
 
 下からの座標で距離を指定したときのデバイススクリーン座標を返す。
 iPadの場合は座標を倍にして処理する。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromBottomPoint:(float)point
{
    // iPadの場合は座標を倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        point *= 2.0f;
    }
    
    return point;
}

/*!
 @brief 中心からの横方向の位置で座標取得

 中心からの横方向の座標で距離を指定したときのデバイススクリーン座標を返す。
 iPadの場合は座標を倍にして処理する。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromHorizontalCenterPoint:(float)point
{
    // iPadの場合は座標を倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        point *= 2.0f;
    }
    
    return [AKScreenSize center].x + point;
}

/*!
 @brief 中心からの縦方向の位置で座標取得
 
 中心からの縦方向の座標で距離を指定したときのデバイススクリーン座標を返す。
 iPadの場合は座標を倍にして処理する。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromVerticalCenterPoint:(float)point
{
    // iPadの場合は座標を倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        point *= 2.0f;
    }
    
    return [AKScreenSize center].y + point;
}

@end
