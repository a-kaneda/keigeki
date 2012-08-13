//
//  AKRadar.h
//  keigeki:傾撃
//
//  Created by 金田 明浩 on 2012/08/14.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "common.h"

// レーダーのサイズ
#define RADAR_SIZE 128
// レーダーの配置位置x座標
#define RADAR_POS_X (SCREEN_WIDTH - 80)
// レーダーの配置位置y座標
#define RADAR_POS_Y (SCREEN_HEIGHT - 130)

/*!
 @class レーダークラス
 @abstruct 敵のいる方向を示すレーダーを管理するクラス。
 */
@interface AKRadar : CCNode {
    // レーダーの画像
    CCSprite *m_image;
}

@property (nonatomic, retain)CCSprite *image;

@end
