/*!
 @file AKTitleLayer.h
 @brief タイトルレイヤークラスの定義
 
 タイトルシーンを管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// タイトルレイヤークラス
@interface AKTitleLayer : CCScene {
    
}

// ゲームの開始
- (void)startGame:(id)sender;
// 遊び方画面の開始
- (void)startHowTo:(id)sender;
// クレジット画面の開始
- (void)startCredit:(id)sender;

@end
