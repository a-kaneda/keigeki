/*!
 @file AKOptionScene.h
 @brief オプション画面シーンクラスの定義
 
 オプション画面シーンクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKInterface.h"
#import "AKLabel.h"
#import "AKCommon.h"

// オプション画面シーン
@interface AKOptionScene : CCScene {
    /// Leaderboardボタン
    AKLabel *leaderboardButton_;
    /// Achievementsボタン
    AKLabel *achievementsButton_;
    /// Twitter連携自動ボタン
    AKLabel *twitterAutoButton_;
    /// Twitter連携手動ボタン
    AKLabel *twitterManualButton_;
    /// Twitter連携Offボタン
    AKLabel *twitterOffButton_;
}

/// Leaderboardボタン
@property (nonatomic, retain)AKLabel *leaderboardButton;
/// Achievementsボタン
@property (nonatomic, retain)AKLabel *achievementsButton;
/// Twitter連携自動ボタン
@property (nonatomic, retain)AKLabel *twitterAutoButton;
/// Twitter連携手動ボタン
@property (nonatomic, retain)AKLabel *twitterManualButton;
/// Twitter連携Offボタン
@property (nonatomic, retain)AKLabel *twitterOffButton;

// Leaderboardボタン選択時の処理
- (void)selectLeaerboard;
// Achievementsボタン選択時の処理
- (void)selectAchievements;
// Twitter連携自動ボタン選択時の処理
- (void)selectTwitterAuto;
// Twitter連携手動ボタン選択時の処理
- (void)selectTwitterManual;
// Twitter連携Offボタン選択時の処理
- (void)selectTwitterOff;
// 戻るボタン選択時の処理
- (void)selectBack;
// Leaderboard表示
- (void)showLeaderboard;
// Achievements表示
- (void)showAchievements;
// Twitter連携ボタン表示更新
- (void)updateTwitterButton;

@end
