/*!
 @file AKTitleScene.h
 @brief タイトルシーンクラスの定義
 
 タイトルシーンを管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "AKInterface.h"
#import "cocos2d.h"

// タイトルシーンクラス
@interface AKTitleScene : CCScene {
    
}

// インターフェースレイヤーの取得
- (AKInterface *)interface;
// ゲームの開始
- (void)startGame;
// 遊び方画面の開始
- (void)startHowTo;
// クレジット画面の開始
- (void)startCredit;

@end
