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
 @file AKScreenSize.h
 @brief 画面サイズ管理クラス
 
 画面サイズ管理クラスを定義する。
 */

#import <Foundation/Foundation.h>

// 画面サイズ管理クラス
@interface AKScreenSize : NSObject

// 画面サイズ取得
+ (CGSize)screenSize;
// ステージサイズ取得
+ (CGSize)stageSize;
// 中央座標取得
+ (CGPoint)center;
// 左からの比率で座標取得
+ (NSInteger)positionFromLeftRatio:(float)ratio;
// 右からの比率で座標取得
+ (NSInteger)positionFromRightRatio:(float)ratio;
// 上からの比率で座標取得
+ (NSInteger)positionFromTopRatio:(float)ratio;
// 下からの比率で座標取得
+ (NSInteger)positionFromBottomRatio:(float)ratio;
// 左からの位置で座標取得
+ (NSInteger)positionFromLeftPoint:(float)point;
// 右からの位置で座標取得
+ (NSInteger)positionFromRightPoint:(float)point;
// 上からの位置で座標取得
+ (NSInteger)positionFromTopPoint:(float)point;
// 下からの位置で座標取得
+ (NSInteger)positionFromBottomPoint:(float)point;
// 中心からの横方向の位置で座標取得
+ (NSInteger)positionFromHorizontalCenterPoint:(float)point;
// 中心からの縦方向の位置で座標取得
+ (NSInteger)positionFromVerticalCenterPoint:(float)point;
@end
