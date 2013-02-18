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
 @file AKEnemy.h
 @brief 敵クラス定義
 
 敵キャラクターのクラスの定義をする。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKCharacter.h"
#import "AKCommon.h"

// 敵クラス
@interface AKEnemy : AKCharacter {
    /// 動作開始からの経過時間(各敵種別で使用)
    ccTime time_;
    /// 動作状態(各敵種別で使用)
    NSInteger state_;
    /// 動作処理のセレクタ
    SEL action_;
    /// 破壊処理のセレクタ
    SEL destroy_;
}

// 生成処理
- (void)createWithX:(NSInteger)x Y:(NSInteger)y Z:(NSInteger)z Angle:(float)angle
             Parent:(CCNode*)parent CreateSel:(SEL)create;
// 雑魚生成処理
- (void)createNoraml;
// 高速移動生成
- (void)createHighSpeed;
// 高速旋回生成
- (void)createHighTurn;
// 高速ショット生成
- (void)createHighShot;
// 3-Way弾発射生成
- (void)create3WayShot;
// 大砲生成
- (void)createCanon;
// 雑魚動作処理
- (void)actionNoraml:(ccTime)dt;
// 高速移動動作処理
- (void)actionHighSpeed:(ccTime)dt;
// 高速旋回動作処理
- (void)actionHighTurn:(ccTime)dt;
// 高速ショット処理
- (void)actionHighShot:(ccTime)dt;
// 3-Way弾発射処理
- (void)action3WayShot:(ccTime)dt;
// 大砲動作処理
- (void)actionCanon:(ccTime)dt;
// 雑魚破壊処理
- (void)destroyNormal;
// 雑魚通常弾発射
- (void)fireNormal;
// n-Way弾発射
- (void)fireNWay:(NSInteger)way;
@end
