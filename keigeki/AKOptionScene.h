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
    /// 購入ボタン
    AKLabel *buyButton_;
    /// リストアボタン
    AKLabel *restoreButton_;
    /// ページ番号
    NSInteger pageNo_;
    /// 最大ページ番号
    NSInteger maxPage_;
    /// 通信中かどうか
    BOOL isConnecting_;
    /// 通信中ビュー
    UIView *connectingView_;
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
/// 購入ボタン
@property (nonatomic, retain)AKLabel *buyButton;
/// リストアボタン
@property (nonatomic, retain)AKLabel *restoreButton;
/// 通信中ビュー
@property (nonatomic, retain)UIView *connectingView;

// ページ共通の項目作成
- (void)initCommonItem:(AKInterface *)interface;
// Game Centerページの項目作成
- (void)initGameCenterPage:(AKInterface *)interface adMarginRatio:(float)adMarginRatio;
// Twitterページの項目作成
- (void)initTwitterPage:(AKInterface *)interface adMarginRatio:(float)adMarginRatio;
// Storeページの項目作成
- (void)initStorePage:(AKInterface *)interface adMarginRatio:(float)adMarginRatio adMarginPoint:(float)adMarginPoint;
// ページ番号取得
- (NSInteger)pageNo;
// ページ番号設定
- (void)setPageNo:(NSInteger)pageNo;
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
// 前ページ表示
- (void)selectPrevPage;
// 次ページ表示
- (void)selectNextPage;
// 戻るボタン選択時の処理
- (void)selectBack;
// Leaderboard表示
- (void)showLeaderboard;
// Achievements表示
- (void)showAchievements;
// Twitter連携ボタン表示更新
- (void)updateTwitterButton;
// 購入ボタン選択時の処理
- (void)selectBuy;
// リストアボタン選択時の処理
- (void)selectRestore;
// 通信開始
- (void)startConnect;
// 通信終了
- (void)endConnect;
// インターフェース有効タグ取得
- (NSUInteger)interfaceTag:(NSInteger)page;

@end
