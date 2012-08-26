/*!
 @file AKBackground.m
 @brief 背景クラス定義
 
 背景の描画を行うクラスを定義する。
 */

#import "AKBackground.h"

/// タイルのサイズ
static const NSInteger kAKTileSize = 64;

/*!
 @brief 背景クラス
 
 背景の描画を行う。
 */
@implementation AKBackground

@synthesize image = m_image;

/*!
 @brief オブジェクト生成処理

 オブジェクトの生成を行う。
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
    self.image = [CCSprite spriteWithFile:@"Back.png"];
    assert(self.image != nil);
        
    // 位置の設定
    [self moveWithScreenX:0 ScreenY:0];
    
    return self;
}

/*!
 @brief インスタンス解放時処理
 
 インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    // 背景画像の解放
    [self.image removeFromParentAndCleanup:YES];
    self.image = nil;
    
    // スーパークラスの解放処理
    [super dealloc];
}

/*!
 @brief 移動処理
 
 スクリーン座標から背景画像の位置を決める。
 @param scrx スクリーン座標x
 @param scry スクリーン座標y
 */
- (void)moveWithScreenX:(NSInteger)scrx ScreenY:(NSInteger)scry
{
    float posx = 0.0f; /* 背景画像のx座標 */
    float posy = 0.0f; /* 背景画像のy座標 */

    // 自機の配置位置を中心とする。
    // そこからタイルサイズ分の範囲でスクロールする。(-32 〜 +32)
    posx = kAKPlayerPos.x + kAKTileSize / 2 + (-scrx % kAKTileSize);
    posy = kAKPlayerPos.y + kAKTileSize / 2 + (-scry % kAKTileSize);
    DBGLOG(0, @"basex=%f basey=%f", posx, posy);
    
    // 背景画像の位置を移動する。
    self.image.position = ccp(posx, posy);
}

@end
