/*!
 @file AKGameIFLayer.h
 @brief ゲームプレイ画面インターフェース定義
 
 ゲームプレイ画面のインターフェースを管理するを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "common.h"

// ゲームプレイ画面インターフェースクラス
@interface AKGameIFLayer : CCLayer {

}

// ゲームプレイ中のタッチ開始処理
- (void)touchBeganInPlaying:(UITouch *)touch;
@end
