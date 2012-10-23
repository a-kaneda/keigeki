/*!
 @file AKOptionScene.h
 @brief オプション画面シーンクラスの定義
 
 オプション画面シーンクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKInterface.h"
#import "common.h"

// オプション画面シーン
@interface AKOptionScene : CCScene {
    
}

// Leaderboardボタン取得
- (CCNode *)leaderboard;
// Achievementsボタン取得
- (CCNode *)achievements;
// Leaderboardボタン選択時の処理
- (void)selectLeaerboard;
// Achievementsボタン選択時の処理
- (void)selectAchievements;
// Twitter連携Offボタン選択時の処理
- (void)selectTwitterOff;
// Twitter連携Onボタン選択時の処理
- (void)selectTwitterOn;
// 戻るボタン選択時の処理
- (void)selectBack;
// Leaderboard表示
- (void)showLeaderboard;
// Achievements表示
- (void)showAchievements;

@end
