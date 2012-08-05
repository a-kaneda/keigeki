//
//  Background.h
//  keigeki
//
//  Created by 金田 明浩 on 12/06/03.
//  Copyright 2012年 KANEDA Akihiro. All rights reserved.
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
@interface Background : CCNode {
    // 背景画像
    CCSprite *m_image;
}

// 移動処理
- (void)moveWithScreenX:(NSInteger)scrx ScreenY:(NSInteger)scry;

@end
