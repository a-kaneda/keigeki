/*!
 @file AKTitleScene.h
 @brief タイトルシーンクラスの定義
 
 タイトルシーンを管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// タイトルシーンクラス
@interface AKTitleScene : CCScene {
    
}

// ゲームの開始
- (void)startGame;
// 遊び方画面の開始
- (void)startHowTo;
// クレジット画面の開始
- (void)startCredit;
// メニュー項目の追加
- (void)addMenuWithString:(NSString*)menuString atPosition:(NSInteger)pos action:(SEL)action;

@end
