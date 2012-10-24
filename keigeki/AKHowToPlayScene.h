/*!
 @file AKHowToPlayScene.h
 @brief プレイ方法画面シーンクラスの定義
 
 プレイ方法画面シーンクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKInterface.h"
#import "AKLabel.h"

// プレイ方法画面シーン
@interface AKHowToPlayScene : CCScene {
    /// ページ番号
    NSInteger pageNo_;
}

// インターフェース取得
- (AKInterface *)interface;
// 前ページボタン取得
- (CCNode *)prevButton;
// 次ページボタン取得
- (CCNode *)nextButton;
// ページ番号ラベル取得
- (AKLabel *)pageLabel;
// メッセージラベルの取得
- (AKLabel *)messageLabel;
/// ページ番号取得
- (NSInteger)pageNo;
// ページ番号設定
- (void)setPageNo:(NSInteger)pageNo;
// 前ページ次ページボタン表示非表示更新
- (void)updatePageButton;
// ページ番号表示更新
- (void)updatePageLabel;
// 前ページ表示
- (void)goPrevPage;
// 次ページ表示
- (void)goNextPage;
// タイトルへ戻る
- (void)backToTitle;

@end
