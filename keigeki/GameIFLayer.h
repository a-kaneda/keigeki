//
//  GameIFLayer.h
//  keigeki
//
//  Created by 金田 明浩 on 12/05/20.
//  Copyright 2012年 KANEDA Akihiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// ショットボタンのサイズ
#define SHOT_BUTTON_SIZE 64
// ショットボタンの配置位置x座標
#define SHOT_BUTTON_POS_X 430
// ショットボタンの配置位置y座標
#define SHOT_BUTTON_POS_Y 50

/*!
 @class ゲームプレイ画面インターフェース
 @abstruct ゲームプレイ画面のインターフェースを管理する。
 */
@interface GameIFLayer : CCLayer {
    // ショットボタンの画像
    CCSprite *m_shotButton;
}

@property (nonatomic, retain)CCSprite *shotButton;

@end
