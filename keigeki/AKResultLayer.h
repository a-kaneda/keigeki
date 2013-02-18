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
 @file AKResultLayer.h
 @brief ステージクリア結果レイヤー
 
 ステージクリア結果画面のレイヤーを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/// ステージクリア結果画面の状態
enum AKResultState {
    kAKstateScoreView = 0,    ///< 初期スコア表示中
    kAKstateTimeView,         ///< タイム表示中
    kAKstateHitView,          ///< 命中率表示中
    kAKstateRestView,         ///< 残機表示中
    kAKstateTimeBonus,        ///< タイムボーナス計算中
    kAKstateHitBonus,         ///< 命中率ボーナス計算中
    kAKstateRestBonus,        ///< 残機ボーナス計算中
    kAKstateFinish            ///< 計算完了
};

// ステージクリア結果レイヤー
@interface AKResultLayer : CCNode {
    /// 計算状態
    enum AKResultState state_;
    /// クリア時の残機
    NSInteger rest_;
    /// クリアタイム
    NSInteger time_;
    /// 命中率
    NSInteger hit_;
    /// 表示中のスコア
    NSInteger score_;
    /// 表示中の残機ボーナス
    NSInteger restBonus_;
    /// 表示中のタイムボーナス
    NSInteger timeBonus_;
    /// 表示中の命中率ボーナス
    NSInteger hitBonus_;
    /// 残機ボーナスの計算値
    NSInteger restBonusTarget_;
    /// タイムボーナスの計算値
    NSInteger timeBonusTarget_;
    /// 命中率ボーナスの計算値
    NSInteger hitBonusTarget_;
    /// 表示更新待ち時間
    float delay_;
}

/// 表示が完了しているかどうか
@property (nonatomic, readonly)BOOL isFinish;

// パラメータの設定
- (void)setParameterStage:(NSInteger)stage
                    score:(NSInteger)score
                     time:(NSInteger)time
                      hit:(NSInteger)hit
                     rest:(NSInteger)rest
               enemyCount:(NSInteger)enemyCount;
// タグ指定ラベル生成
- (void)createLabelWithTag:(NSInteger)tag pos:(CGPoint)pos;
// 文字列指定ラベル生成
- (void)createLabelWithString:(NSString *)str pos:(CGPoint)pos;
// 表示アイテムの更新
- (NSInteger)updateItemWithTag:(NSInteger)tag
                  currentValue:(NSInteger)current
                   targetValue:(NSInteger)target
                incrementValue:(NSInteger)increment
                    isAddScore:(BOOL)isAddScore
                    isLongWait:(BOOL)isLongWait
                        withSE:(BOOL)withSE;
// 計算更新処理
- (void)updateCalc:(ccTime)dt;
// 計算の強制終了
- (void)finish;
@end
