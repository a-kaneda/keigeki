//
//  AKGameIFLayer.h
//  keigeki:傾撃
//
//  Created by 金田 明浩 on 2012/05/20.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "common.h"

// ショットボタンのサイズ
#define SHOT_BUTTON_SIZE 64
// ショットボタンの配置位置y座標
#define SHOT_BUTTON_POS_Y 50
// ショットボタンの配置位置x座標
#define SHOT_BUTTON_POS_X (SCREEN_WIDTH - SHOT_BUTTON_POS_Y)

/*!
 @class ゲームプレイ画面インターフェース
 @abstruct ゲームプレイ画面のインターフェースを管理する。
 */
@interface AKGameIFLayer : CCLayer {
    // ショットボタンの画像
    CCSprite *m_shotButton;
}

@property (nonatomic, retain)CCSprite *shotButton;

@end
