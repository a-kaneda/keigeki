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
 @file AKGameCenterHelper.h
 @brief Game Center管理
 
 Game Centerの入出力を管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

/// 実績ノーミスクリアのID
extern NSString *kAKGCNoMissID;
/// 実績短時間クリアのID
extern NSString *kAKGCShortTimeID;
/// 実績背後からの撃墜のID
extern NSString *kAKGCBackShootID;
/// 実績命中率100%のID
extern NSString *kAKGCInfallibleShoot;
/// 実績1UPのID
extern NSString *kAKGC1UpID;
/// 実績プレイ回数のID
extern NSString *kAKGCPlayCountID;

// Game Center管理
@interface AKGameCenterHelper : NSObject {
    /// 解除済みの実績
    NSMutableDictionary *localAchievments_;
}

/// 解除済みの実績
@property (retain, nonatomic)NSMutableDictionary *localAchievements;

// シングルトンオブジェクトを取得する
+ (AKGameCenterHelper *)sharedHelper;
// 解除済みの実績読み込み
- (void)readLocalAchievements;
// 解除済みの実績書き込み
- (void)writeLocalAchievements;
// ユーザー認証
- (void)authenticateLocalPlayer;
// 送信に失敗したデータを再送信する
- (void)reSendData:(NSDictionary *)networkAchievements;
// 実績取得
- (void)loadAchievements;
// ハイスコア送信
- (void)reportHiScore:(NSInteger)score;
// 実績送信
- (void)reportAchievements:(NSString *)identifier;
// 達成率増加分を指定して実績送信
- (void)reportAchievements:(NSString *)identifier percentIncrement:(float)percent;
// ステージクリア送信
- (void)reportStageClear:(NSInteger)stage;
// Leaderboard表示
- (void)showLeaderboard;
// Achievements表示
- (void)showAchievements;
@end
