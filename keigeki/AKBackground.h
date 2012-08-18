/*!
 @file AKBackground.h
 @brief 背景クラス定義
 
 背景の描画を行うクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "common.h"

/// タイルのサイズ
#define TILE_SIZE 64

// 背景クラス
@interface AKBackground : CCNode {
    /// 背景画像
    CCSprite *m_image;
}

/// 背景画像
@property (nonatomic, retain)CCSprite *image;

// 移動処理
- (void)moveWithScreenX:(NSInteger)scrx ScreenY:(NSInteger)scry;

@end
