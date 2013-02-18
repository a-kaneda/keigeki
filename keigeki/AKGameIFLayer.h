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
 @file AKGameIFLayer.h
 @brief ゲームプレイ画面インターフェース定義
 
 ゲームプレイ画面のインターフェースを管理するを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKInterface.h"
#import "AKCommon.h"

/// ゲームプレイ中のタグ
extern NSUInteger kAKGameIFTagPlaying;
/// 一時停止中のタグ
extern NSUInteger kAKGameIFTagPause;
/// 終了メニュー表示中のタグ
extern NSUInteger kAKGameIFTagQuit;
/// ゲームオーバー時のタグ
extern NSUInteger kAKGameIFTagGameOver;
/// ゲームクリア時のタグ
extern NSUInteger kAKGameIFTagGameClear;
/// リザルト表示時のタグ
extern NSUInteger kAKGameIFTagResult;
/// 待機中のタグ
extern NSUInteger kAKGameIFTagWait;

// ゲームプレイ画面インターフェースクラス
@interface AKGameIFLayer : AKInterface {
    /// ポーズ解除ボタン
    AKLabel *resumeButton_;
    /// 終了ボタン
    AKLabel *quitButton_;
    /// 終了メニューNoボタン
    AKLabel *quitNoButton_;
}

/// ポーズ解除ボタン
@property (nonatomic, retain)AKLabel *resumeButton;
/// 終了ボタン
@property (nonatomic, retain)AKLabel *quitButton;
/// 終了メニューNoボタン
@property (nonatomic, retain)AKLabel *quitNoButton;

// ゲームプレイ中のメニュー項目作成
- (void)createPlayingMenu;
// ポーズ時のメニュー項目作成
- (void)createPauseMenu;
// 終了メニュー項目作成
- (void)createQuitMenu;
// ゲームオーバー時のメニュー項目作成
- (void)createGameOverMenu;
// ゲームクリア時のメニュー項目作成
- (void)createGameClearMenu;
// リザルト表示時のメニュー項目作成
- (void)createResultMenu;

@end
