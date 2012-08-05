//
//  Background.m
//  keigeki
//
//  Created by 金田 明浩 on 12/06/03.
//  Copyright 2012年 KANEDA Akihiro. All rights reserved.
//

#import "Background.h"


@implementation Background

/*!
 @method オブジェクト生成処理
 @abstruct オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // タイルの生成
    m_image = [CCSprite spriteWithFile:@"Back.png"];
    [self addChild:m_image z:1];
    
    // 位置の設定
    [self moveWithScreenX:0 ScreenY:0];
    
    return self;
}

/*!
 @method インスタンス解放時処理
 @abstruct インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    // 背景画像の解放
    [m_image release];
    m_image = nil;
    
    // スーパークラスの解放処理
    [super dealloc];
}

/*!
 @method 移動処理
 @abstruct スクリーン座標から背景画像の位置を決める。
 @param scrx スクリーン座標x
 @param scry スクリーン座標y
 */
- (void)moveWithScreenX:(NSInteger)scrx ScreenY:(NSInteger)scry
{
    float pos = 0.0f; /* 背景画像のx座標 */
    float posy = 0.0f; /* 背景画像のy座標 */

    // 自機の配置位置を中心とする。
    // そこからタイルサイズ分の範囲でスクロールする。(-32 〜 +32)
    pos = PLAYER_POS_X + TILE_SIZE / 2 + (-scrx % TILE_SIZE);
    posy = PLAYER_POS_Y + TILE_SIZE / 2 + (-scry % TILE_SIZE);
    DBGLOG(0, @"basex=%f basey=%f", pos, posy);
    
    // 背景画像の位置を移動する。
    m_image.position = ccp(pos, posy);
}

@end
