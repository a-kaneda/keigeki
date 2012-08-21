/*!
 @file AKGameIFLayer.h
 @brief ゲームプレイ画面インターフェース定義
 
 ゲームプレイ画面のインターフェースを管理するを定義する。
 */


#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "common.h"

/// ショットボタンのサイズ
#define SHOT_BUTTON_SIZE 64
/// ショットボタンの配置位置y座標
#define SHOT_BUTTON_POS_Y 50
/// ショットボタンの配置位置x座標
#define SHOT_BUTTON_POS_X (SCREEN_WIDTH - SHOT_BUTTON_POS_Y)

/// ポーズボタンのサイズ
#define PAUSE_BUTTON_SIZE 32
/// ポーズボタンの配置位置x座標
#define PAUSE_BUTTON_POS_X (SCREEN_WIDTH - PAUSE_BUTTON_SIZE / 2- 10)
/// ポーズボタンの配置位置y座標
#define PAUSE_BUTTON_POS_Y (SCREEN_HEIGHT - PAUSE_BUTTON_SIZE / 2- 10)

// ゲームプレイ画面インターフェースクラス
@interface AKGameIFLayer : CCLayer {
    /// ショットボタンの画像
    CCSprite *m_shotButton;
    /// ポーズボタンの画像
    CCSprite *m_pauseButton;
}

/// ショットボタンの画像
@property (nonatomic, retain)CCSprite *shotButton;
/// ポーズボタンの画像
@property (nonatomic, retain)CCSprite *pauseButton;

// ゲームプレイ中のタッチ開始処理
- (void)touchBeganInPlaying:(UITouch *)touch;
@end
