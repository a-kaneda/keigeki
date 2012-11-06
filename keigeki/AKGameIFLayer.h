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
// リザルト表示時のメニュー項目作成
- (void)createResultMenu;

@end
