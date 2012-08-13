//
//  AKBackground.h
//  keigeki:傾撃
//
//  Created by 金田 明浩 on 2012/06/03.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "common.h"

// タイルのサイズ
#define TILE_SIZE 64

/*!
 @class 背景クラス
 @abstruct 背景の描画を行う
 */
@interface AKBackground : CCNode {
    // 背景画像
    CCSprite *m_image;
}

@property (nonatomic, retain)CCSprite *image;

// 移動処理
- (void)moveWithScreenX:(NSInteger)scrx ScreenY:(NSInteger)scry;

@end
